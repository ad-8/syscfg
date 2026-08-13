#!/usr/bin/env bb

(ns kwm-status
  (:require [clojure.string :as str]
            [babashka.fs :as fs]
            [babashka.process :as p]))

;; escapes because literal glyphs get eaten when an llm edits this file.
;; :disk (U+F02CA) and :ram (U+F035B) are too big for one escape, so they take two.
(def icons
  {:licht    "\uf0eb"
   :load     "\uf2db"
   :vol      "\uf028"
   :vol-mute "\ueee8"
   :disk     "\udb80\udeca"
   :ram      "\udb80\udf5b"})

(def sep " \u2022 ")
(def ellipsis "\u2026")

(def scripts "/home/ax/syscfg/scripts")
(def runtime-dir (or (System/getenv "XDG_RUNTIME_DIR") "/tmp"))
(def status-fifo (or (first *command-line-args*) (str runtime-dir "/kwm-status")))
(def weather-cache (str runtime-dir "/kwm-weather"))
(def weather-script (str scripts "/bb/weather.clj"))

(def supported-players #{"strawberry" "fooyin" "emms"})
(def music-width 35)
(def tick-secs 2)

;; kwm's status buffer is 256 bytes and only gets terminated when the read comes
;; up short, so a line filling it exactly is read past the end (bar.zig:29).
(def line-max-bytes 254)
(def over-marker "!TOO LONG!")

(defn- first-line
  "First line of path, or nil when the file does not exist."
  [path]
  (when (fs/exists? path)
    (first (fs/read-all-lines path))))

(defn- byte-count [s] (count (.getBytes s "UTF-8")))

(defn- truncate
  "Cut to n code points, ellipsis if cut. Code points, not subs: subs cuts
  UTF-16 units and would split a surrogate pair on an emoji in a title."
  [s n]
  (if (<= (.codePointCount s 0 (count s)) n)
    s
    (str (subs s 0 (.offsetByCodePoints s 0 (dec n))) ellipsis)))

(defn- music
  "Playing track as N. Title, prefixed PAUSED when paused. Blank when nothing
  is playing or the player is not one of ours."
  []
  ;; playerctl is optional: missing means no field, not a dead loop
  (let [{:keys [exit out]}
        (try (p/sh "playerctl" "metadata" "--format"
                   "{{playerName}}|{{status}}|{{xesam:trackNumber}}|{{xesam:title}}")
             (catch Exception _ {:exit 1 :out ""}))
        [player status track title] (str/split (str/trim out) #"\|" 4)]
    (if (or (pos? exit)
            (not (supported-players player))
            (= "Stopped" status)
            (str/blank? title))
      ""
      (truncate (cond->> (if (str/blank? track)
                           title
                           (str track ". " title))
                  (= "Paused" status) (str "PAUSED "))
                music-width))))

;; never inline: a slow request would stall the clock too. publish only on
;; success -- weather.clj prints its errors to stdout -- and via a temp file so
;; a reader cannot catch a half-written cache.
(defn- weather-refresh!
  "Fetch the weather into the cache file. Publishes only on success, so a
  failed fetch leaves the last good reading in place."
  []
  (let [{:keys [exit out]} (p/sh "timeout" "30" weather-script "dwm")
        tmp (str weather-cache ".new")]
    (when (and (zero? exit) (not (str/blank? out)))
      (spit tmp out)
      (fs/move tmp weather-cache #{:replace-existing}))))

(defn- weather
  "Last cached weather reading, or -- when there is none yet."
  []
  (let [v (first-line weather-cache)]
    (if (str/blank? v)
      "--"
      v)))

(defn- volume
  "Default sink volume as a percentage, MUTED when muted, -- when pipewire
  does not answer."
  []
  (let [[_ v muted] (-> (:out (p/sh "wpctl" "get-volume" "@DEFAULT_AUDIO_SINK@"))
                        str/trim
                        (str/split #"\s+"))
        pct (some-> v parse-double (* 100))]
    (cond
      (nil? pct)          (format "%s  --" (:vol icons))
      (= "[MUTED]" muted) (format "%s  MUTED" (:vol-mute icons))
      :else               (format "%s  %.0f%%" (:vol icons) pct))))

(defn- licht
  "Screen brightness, from the cache licht.clj writes, or -- when absent."
  []
  (let [v (first-line "/tmp/licht-curr-val")]
    (format "%s %s" (:licht icons) (if (str/blank? v)
                                     "--"
                                     v))))

(defn- load-avg
  "One-minute load average from /proc/loadavg."
  []
  ;; not slurp: slurp and io/reader both fail on /proc with "Invalid argument"
  (let [one (-> (fs/read-all-lines "/proc/loadavg") first (str/split #"\s+") first)]
    (format "%s %s" (:load icons) one)))

(defn- disk
  "Space available on /, blank when df fails."
  []
  (let [out (:out (p/sh {:err :inherit} "df" "-h" "/" "--output=avail"))]
    (if-let [avail (second (str/split-lines out))]
      (format "%s %s" (:disk icons) (str/trim avail))
      "")))

(defn- ram
  "Memory in use as a percentage of total, blank when free fails."
  []
  (let [out (:out (p/sh {:err :inherit} "free" "-m"))
        [_ total used] (re-find #"Mem:\s+(\d+)\s+(\d+)" out)]
    (if (and total used)
      (format "%s %d%%" (:ram icons)
              (int (* (/ (double (parse-long used)) (parse-long total)) 100)))
      "")))

(defn- vpn
  "Active wireguard interfaces, or NO VPN. Rendered by freebsd/vpn.sh."
  []
  (str/trim-newline (:out (p/sh {:err :inherit} (str scripts "/freebsd/vpn.sh")))))

(defn- datetime
  "German weekday, date and time. Rendered by freebsd/datetime.sh."
  []
  (str/trim-newline (:out (p/sh {:err :inherit} (str scripts "/freebsd/datetime.sh")))))

(defn- due?
  "True when a field refreshing every secs is due on this tick. max 1 so a
  cadence below one tick means every tick rather than dividing by zero."
  [tick secs]
  (zero? (mod tick (max 1 (quot secs tick-secs)))))

;; bar order, left to right; every field states its own refresh rate in seconds
(def fields
  [{:render music    :secs tick-secs}
   {:render weather  :secs 10}
   {:render volume   :secs tick-secs}
   {:render licht    :secs tick-secs}
   {:render load-avg :secs 6}
   {:render disk     :secs 30}
   {:render ram      :secs 30}
   {:render vpn      :secs 10}
   {:render datetime :secs tick-secs}])

(comment
  ;; tick -- loop counter, one per tick-secs, so 15 is 30s in
  15

  ;; cache -- one string per entry in fields, same order and length.
  ;; glyphs written as <name> here only to keep this file pure ascii
  ["3. Blue Monday"
   "13C Clear sky WHV"
   "<vol> 38%"
   "<licht> 42"
   "<load> 0.31"
   "<disk> 29G"
   "<ram> 28%"
   "muc"
   "Mi 12.08.  19:38"]

  ;; back comes the same shape: fields that are due get re-rendered, the rest
  ;; carry their previous string through. music is "" when nothing is playing,
  ;; and the join in the loop drops every blank.
  (refresh 15 (vec (repeat (count fields) ""))))

(defn- refresh
  "Render every field whose cadence is due on this tick, carry the rest through."
  [tick cache]
  (mapv (fn [{:keys [render secs]} old]
          (if (due? tick secs)
            (render)
            old))
        fields cache))

(defn- drop-longest
  "parts without its longest entry."
  [parts]
  (let [longest (apply max-key byte-count parts)]
    (remove #(= longest %) parts)))

(defn- compose
  "Join the non-blank fields, so an absent field leaves no stray separator.
  Over budget, mark the line and drop the longest field until it fits, so the
  field that blew up is the one that disappears."
  [cache]
  (let [parts (remove str/blank? cache)
        line  (str/join sep parts)]
    (if (<= (byte-count line) line-max-bytes)
      line
      (loop [parts parts]
        (let [line (str/join sep (cons over-marker parts))]
          (if (<= (byte-count line) line-max-bytes)
            line
            (recur (drop-longest parts))))))))

(defn- run
  "Tick forever, writing the composed line to the status fifo on every change."
  []
  (when-not (fs/exists? status-fifo)
    (binding [*out* *err*]
      (println (str "kwm-status: " status-fifo " does not exist, is river's init running?")))
    (System/exit 1))

  (loop [tick  0
         prev  nil
         cache (vec (repeat (count fields) ""))]
    ;; 600s matches waybar; retry at 60s until the first fetch lands
    (when (or (due? tick 600)
              (and (not (fs/exists? weather-cache)) (due? tick 60)))
      (future (weather-refresh!)))

    (let [cache (refresh tick cache)
          line  (compose cache)]
      (when (not= line prev)
        (spit status-fifo (str line "\n")))

      (Thread/sleep (* tick-secs 1000))
      (recur (inc tick) line cache))))

(run)
