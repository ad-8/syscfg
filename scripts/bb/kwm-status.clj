#!/usr/bin/env bb

(ns kwm-status
  (:require [clojure.string :as str]
            [babashka.fs :as fs]
            [babashka.process :as p]))

;; glyphs as codepoints so this file stays pure ascii in transit
(defn- cp [n] (String. (Character/toChars n)))

(def ico-licht    (cp 0xf0eb))
(def ico-load     (cp 0xf2db))
(def ico-vol      (cp 0xf028))
(def ico-vol-mute (cp 0xeee8))
(def ico-disk     (cp 0xf02ca))
(def ico-ram      (cp 0xf035b))
(def sep          (str " " (cp 0x2022) " "))
(def ellipsis     (cp 0x2026))

(def scripts "/home/ax/syscfg/scripts")
(def runtime-dir (or (System/getenv "XDG_RUNTIME_DIR") "/tmp"))
(def status-fifo (or (first *command-line-args*) (str runtime-dir "/kwm-status")))
(def weather-cache (str runtime-dir "/kwm-weather"))
(def weather-script (str scripts "/bb/weather.clj"))

;; anything else on the mpris bus (a firefox video, say) would otherwise hijack
;; the field -- same filter waybar.clj uses
(def supported-players #{"strawberry" "fooyin" "emms"})
(def music-width 35)
(def tick-secs 2)

(when-not (fs/exists? status-fifo)
  (binding [*out* *err*]
    (println (str "kwm-status: " status-fifo " does not exist, is river's init running?")))
  (System/exit 1))

(defn- truncate
  "Cut to n code points, ellipsis if cut. Code points, not subs: subs cuts
  UTF-16 units and would split a surrogate pair on an emoji in a title."
  [s n]
  (if (<= (.codePointCount s 0 (.length s)) n)
    s
    (str (subs s 0 (.offsetByCodePoints s 0 (dec n))) ellipsis)))

(defn- music []
  ;; playerctl is the one optional dependency here, so a host without it degrades
  ;; to no field rather than taking the loop down
  (let [{:keys [exit out]}
        (try (p/sh "playerctl" "metadata" "--format"
                   "{{playerName}}|{{status}}|{{xesam:trackNumber}}|{{xesam:title}}")
             (catch Exception _ {:exit 1 :out ""}))
        [player status track title] (str/split (str/trim out) #"\|" 4)]
    (if (or (not (zero? exit))
            (not (supported-players player))
            (= "Stopped" status)
            (str/blank? title))
      ""
      (truncate (cond->> (if (str/blank? track) title (str track ". " title))
                  (= "Paused" status) (str "PAUSED "))
                music-width))))

;; weather.clj hits the network, so it never runs inline -- a slow request would
;; stall the whole bar, clock included. refresh detached, publish only on
;; success: weather.clj prints its errors to stdout, and a failed fetch should
;; leave the last good reading standing. write via a temp file so a reader can
;; never catch a half-written cache.
(defn- weather-refresh! []
  (let [{:keys [exit out]} (p/sh "timeout" "30" weather-script "dwm")
        tmp (str weather-cache ".new")]
    (when (and (zero? exit) (not (str/blank? out)))
      (spit tmp out)
      (fs/move tmp weather-cache #{:replace-existing}))))

(defn- weather []
  (let [v (when (fs/exists? weather-cache) (first (fs/read-all-lines weather-cache)))]
    (if (str/blank? v) "--" v)))

(defn- volume []
  (let [[_ v muted] (-> (:out (p/sh "wpctl" "get-volume" "@DEFAULT_AUDIO_SINK@"))
                        str/trim
                        (str/split #"\s+"))
        pct (some-> v parse-double (* 100))]
    (cond
      (nil? pct)          (format "%s  --" ico-vol)
      (= "[MUTED]" muted) (format "%s  MUTED" ico-vol-mute)
      :else               (format "%s  %.0f%%" ico-vol pct))))

(defn- licht []
  (let [path "/tmp/licht-curr-val"
        v (when (fs/exists? path) (first (fs/read-all-lines path)))]
    (format "%s %s" ico-licht (if (str/blank? v) "--" v))))

(defn- load-avg []
  ;; fs/read-all-lines, not slurp: slurp and io/reader both fail on /proc with
  ;; "IOException: Invalid argument"
  (let [one (first (str/split (first (fs/read-all-lines "/proc/loadavg")) #"\s+"))]
    (format "%s %s" ico-load one)))

(defn- disk []
  (let [out (:out (p/sh {:err :inherit} "df" "-h" "/" "--output=avail"))]
    (if-let [avail (second (str/split-lines out))]
      (format "%s %s" ico-disk (str/trim avail))
      "")))

(defn- ram []
  (let [out (:out (p/sh {:err :inherit} "free" "-m"))
        [_ total used] (re-find #"Mem:\s+(\d+)\s+(\d+)" out)]
    (if (and total used)
      (format "%s %d%%" ico-ram
              (int (* (/ (double (parse-long used)) (parse-long total)) 100)))
      "")))

(defn- vpn []
  (str/trim-newline (:out (p/sh {:err :inherit} (str scripts "/freebsd/vpn.sh")))))

(defn- datetime []
  (str/trim-newline (:out (p/sh {:err :inherit} (str scripts "/freebsd/datetime.sh")))))

(defn- due? [tick secs] (zero? (mod tick (quot secs tick-secs))))

;; bar order, left to right; no :secs = every tick
(def fields
  [{:render music}
   {:render weather  :secs 10}
   {:render volume}
   {:render licht}
   {:render load-avg :secs 6}
   {:render disk     :secs 30}
   {:render ram      :secs 30}
   {:render vpn      :secs 10}
   {:render datetime}])

(defn- refresh [tick cache]
  (mapv (fn [{:keys [render secs]} old]
          (if (or (nil? secs) (due? tick secs)) (render) old))
        fields cache))

(loop [tick 0, prev nil, cache (vec (repeat (count fields) ""))]
  ;; 600s matches waybar's custom/weather; retry each 60s until the first
  ;; fetch lands, so a login that beats the network isn't blank for 10min
  (when (or (due? tick 600)
            (and (not (fs/exists? weather-cache)) (due? tick 60)))
    (future (weather-refresh!)))

  ;; join over non-blank fields: music comes and goes, and a hardcoded
  ;; separator would leave a stray bullet behind when it does. also drops
  ;; the doubled separator disk/ram used to leave when df or free failed.
  (let [cache (refresh tick cache)
        line  (str/join sep (remove str/blank? cache))]
    (when (not= line prev)
      (spit status-fifo (str line "\n")))

    (Thread/sleep (* tick-secs 1000))
    (recur (inc tick) line cache)))
