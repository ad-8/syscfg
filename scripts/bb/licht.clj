#!/usr/bin/env bb
(ns licht
  (:require [clojure.string :as str]
            [clojure.edn]
            [babashka.process :refer [shell process]])
  (:import java.net.InetAddress))


(defn get-hostname []
  (.getHostName (InetAddress/getLocalHost)))

(def host-config
  ; ax-bee: IDs are ddcutil display numbers — run `ddcutil detect` to see model names and verify mapping
  ; LG-4K=display 2/bus 13, Acer=display 1/bus 4 — ordered LG-first so preset vectors read [LG-val Acer-val]
  ; :buses (when present) selects the --bus fast path; --bus skips display enumeration ddcutil otherwise does per call
  {"ax-bee" {:internal false :displays [2 1] :display-names {2 "LG" 1 "Acer"} :buses [13 4]}
   "ax-mac" {:internal true  :displays :detect}
   "ax-t14" {:internal true  :displays :detect}})


(defn light-screen [brightness]
  (let [res (shell {:continue true :err :string} "light" "-S" (str brightness))]
    (when (not= 0 (:exit res))
      (println "warn: light-screen failed (device may not exist)"))))

; light -L lists available devices
; :err :string suppresses light's device-not-found warnings so only our warn: line shows
(defn light-keyboard [brightness]
  (let [res (shell {:continue true :err :string} "light" "-s" "sysfs/leds/smc::kbd_backlight" "-S" (str brightness))]
    (when (not= 0 (:exit res))
      (println "warn: light-keyboard failed (device may not exist)"))))

(defn get-light-screen []
  (let [res (shell {:continue true :out :string} "light" "-G")]
    (if (= 0 (:exit res)) (str/trim (:out res)) "err")))

(defn get-light-keyboard []
  (let [res (shell {:continue true :out :string} "light" "-s" "sysfs/leds/smc::kbd_backlight" "-G")]
    (if (= 0 (:exit res)) (str/trim (:out res)) "err")))


(defn extract-vcp-value [s code]
  (last (re-find (re-pattern (str "(?i)VCP code 0x" code ".*?current value =\\s*(\\d+)")) s)))


(defn detect-display-ids []
  (->> (shell {:continue true :out :string} "ddcutil" "detect")
       :out
       str/split-lines
       (map str/trim)
       (filter #(re-matches #"Display \d+" %))
       (map #(parse-long (re-find #"\d+" %)))))

(defn get-displays []
  (let [displays (:displays (host-config (get-hostname)))]
    (if (= :detect displays)
      (detect-display-ids)
      displays)))

(defn ext-val-for-display [val idx]
  (if (vector? val) (get val idx (last val)) val))

(defn set-ext-vcp [displays vcp-code val]
  (doseq [[idx d] (map-indexed vector displays)]
    (when (pos? idx) (Thread/sleep 500))
    (let [res (shell {:continue true} "ddcutil" "--skip-ddc-checks" "--display" (str d) "setvcp" (str vcp-code) (str (ext-val-for-display val idx)))]
      (when (not= 0 (:exit res))
        (println (format "warn: ddcutil setvcp failed for display %d (exit %d)" d (:exit res)))))))

(defn get-ext-display-vals [d]
  (let [out (-> (shell {:continue true :out :string} "ddcutil" "--skip-ddc-checks" "--display" (str d) "getvcp" "10" "12") :out)]
    {:display    d
     :brightness (extract-vcp-value out "10")
     :contrast   (extract-vcp-value out "12")}))

(defn print-ext-vals [displays names]
  (let [rows  (mapv get-ext-display-vals displays)
        label (fn [{:keys [display]}]
                (let [n (get names display "")]
                  (str "Display " display (if (seq n) (str " (" n ")") ""))))
        w     (apply max (map (comp count label) rows))]
    (doseq [row rows]
      (let [{:keys [brightness contrast]} row]
        (println (format (str "%-" w "s — brightness: %s  contrast: %s")
                         (label row) brightness contrast))))))


; --- --bus fast path (used when host-config has :buses) ---
; ddcutil --bus N skips per-call display enumeration, materially faster than --display
; both paths also pass --skip-ddc-checks (skips per-invocation DDC capability tests, ~40% extra speedup)

(defn get-buses []
  (:buses (host-config (get-hostname))))

(defn display-for-bus [bus]
  (let [{:keys [displays buses]} (host-config (get-hostname))
        idx (.indexOf buses bus)]
    (when (>= idx 0) (get displays idx))))

(defn set-ext-vcp-bus [buses vcp-code val]
  (doseq [[idx b] (map-indexed vector buses)]
    (when (pos? idx) (Thread/sleep 500))
    (let [res (shell {:continue true} "ddcutil" "--skip-ddc-checks" "--bus" (str b) "setvcp" (str vcp-code) (str (ext-val-for-display val idx)))]
      (when (not= 0 (:exit res))
        (println (format "warn: ddcutil setvcp failed for bus %d (exit %d)" b (:exit res)))))))

(defn get-ext-bus-vals [bus]
  (let [out (-> (shell {:continue true :out :string} "ddcutil" "--skip-ddc-checks" "--bus" (str bus) "getvcp" "10" "12") :out)]
    {:bus        bus
     :brightness (extract-vcp-value out "10")
     :contrast   (extract-vcp-value out "12")}))

(defn print-ext-bus-vals [buses names]
  (let [rows  (mapv get-ext-bus-vals buses)
        label (fn [{:keys [bus]}]
                (let [d (display-for-bus bus)
                      n (get names d "")]
                  (str "Display " d (if (seq n) (str " (" n ")") ""))))
        w     (apply max (map (comp count label) rows))]
    (doseq [row rows]
      (let [{:keys [brightness contrast]} row]
        (println (format (str "%-" w "s — brightness: %s  contrast: %s")
                         (label row) brightness contrast))))))


(defn get-hyprsunset-temp []
  (let [res (shell {:continue true :out :string} "pgrep" "-a" "hyprsunset")]
    (when (= 0 (:exit res))
      (second (re-find #"-t\s+(\d+)" (:out res))))))

(defn set-color-temp [n]
  (shell {:continue true} "pkill" "-f" "hyprsunset")
  (Thread/sleep 500)
  (process ["hyprsunset" "-t" (str n)]))


(defn heading [s]
  (let [line (apply str (repeat (count s) "-"))]
    (format "%s\n%s\n%s" line s line)))


(defn print-all-the-light-we-can-see []
  (let [{:keys [internal display-names]} (host-config (get-hostname))]
    (when internal
      (printf "%s\nDisplay:  %s\nKeyboard: %s\n\n"
              (heading "Internal") (get-light-screen) (get-light-keyboard)))
    (println (heading "External"))
    (if-let [buses (get-buses)]
      (print-ext-bus-vals buses display-names)
      (print-ext-vals (get-displays) display-names))
    (printf "\nColor temp: %sK\n" (or (get-hyprsunset-temp) "unknown"))))

(defn notify-lights! []
  (shell "notify-send" "--app-name" "dwm-licht" "--expire-time" "8000"
         "--icon" "brightness-high-symbolic" "--replace-id" "127"
         "--" "Licht" (with-out-str (print-all-the-light-we-can-see))))

(defn illuminate! [{:keys [internal keyboard ext-b ext-c col-temp]}]
  (light-screen internal)
  (light-keyboard keyboard)
  (if-let [buses (get-buses)]
    (do (set-ext-vcp-bus buses 10 ext-b)
        (set-ext-vcp-bus buses 12 ext-c))
    (let [displays (get-displays)]
      (set-ext-vcp displays 10 ext-b)
      (set-ext-vcp displays 12 ext-c)))
  (set-color-temp col-temp))


(def settings
  {"hi+"  {:name "High+"
           :vals {:internal 90 :keyboard 0  :ext-b 90  :ext-c 90  :col-temp 6500}}
   "hi"   {:name "High"
           :vals {:internal 80 :keyboard 0  :ext-b 80  :ext-c 80  :col-temp 6000}}
   "hi2"  {:name "High2"
           :vals {:internal 67 :keyboard 67 :ext-b 67  :ext-c 67  :col-temp 5500}}
   "hi3"  {:name "High3"
           :vals {:internal 59 :keyboard 59 :ext-b 59  :ext-c 59  :col-temp 4900}}
   "med"  {:name "Medium"
           :vals {:internal 50 :keyboard 50 :ext-b 50  :ext-c 50  :col-temp 4250}}
   "lo"   {:name "Low"
           :vals {:internal 23 :keyboard 25 :ext-b 40  :ext-c 33  :col-temp 3750}}
   "ul1"  {:name "Ultra-Low-1"
           :vals {:internal 20 :keyboard 20 :ext-b 35  :ext-c 25  :col-temp 3000}}
   "ul2"  {:name "Ultra-Low-2"
           :vals {:internal 10 :keyboard 10 :ext-b 15  :ext-c 15  :col-temp 3000}}
   "ni"   {:name "Night"
           :vals {:internal 2  :keyboard 2  :ext-b 15  :ext-c 15  :col-temp 3000}}
   "ni2"  {:name "Night-2"
           :vals {:internal 2  :keyboard 2  :ext-b 8   :ext-c 8   :col-temp 2000}}
   "max"  {:name "Max"
           :vals {:internal 100 :keyboard 0 :ext-b 100 :ext-c 100 :col-temp 6500}}
   "fo1"  {:name "Focus-1"
           :vals {:internal 0 :keyboard 0 :ext-b [100 80] :ext-c [100 80] :col-temp 6500}}
   "fo2"  {:name "Focus-2"
           :vals {:internal 0 :keyboard 0 :ext-b [100 60] :ext-c [100 60] :col-temp 6500}}
   "fo3"  {:name "Focus-3"
           :vals {:internal 0 :keyboard 0 :ext-b [100 40] :ext-c [100 40] :col-temp 6500}}
   "fo4"  {:name "Focus-4"
           :vals {:internal 0 :keyboard 0 :ext-b [100 20] :ext-c [100 20] :col-temp 6500}}
   "fo5"  {:name "Focus-5"
           :vals {:internal 0 :keyboard 0 :ext-b [100 5]  :ext-c [100 5]  :col-temp 6500}}
   "cust" {:name "Custom"}
   "get"  {:name "Get current values"}})


(def nord
  {:polar1 "#2e3440"
   :polar2 "#3b4252"
   :polar3 "#434c5e"
   :polar4 "#4c566a"
   :snow1  "#d8dee9"
   :snow2  "#e5e9f0"
   :snow3  "#eceff4"
   :frost1 "#8fbcbb"
   :frost2 "#88c0d0"
   :frost3 "#81a1c1"
   :frost4 "#5e81ac"
   :red    "#bf616a"
   :orange "#d08770"
   :yellow "#ebcb8b"
   :green  "#a3be8c"
   :lila   "#b48ead"})


(defn ask-value [prompt options]
  (let [echo-proc (process ["echo" "-e" (str/join "\n" options)])
        result    (-> (process {:prev echo-proc
                                :out :string
                                :cmd ["wmenu" "-i" "-l" (str (count options)) "-p" prompt
                                      "-f" "HackNerdFont 15" "-N" (:polar1 nord) "-M" (:orange nord)
                                      "-m" (:snow3 nord) "-S" (:orange nord) "-s" (:snow3 nord)]})
                      deref :out str/trim)]
    (when-not (str/blank? result)
      (parse-long result))))

(defn set-custom-lights! []
  (let [b-opts  [100 80 60 40 20 5 0]
        ct-opts [6500 6000 5500 5000 4500 4000 3500 3000 2500 2000]
        lg   (ask-value "LG brightness" b-opts)
        acer (when lg   (ask-value "Acer brightness" b-opts))
        ct   (when acer (ask-value "color temp" ct-opts))]
    (when ct
      (illuminate! {:internal 0 :keyboard 0 :ext-b [lg acer] :ext-c [lg acer] :col-temp ct})
      (spit "/tmp/licht-curr-val" "cust\n")
      (shell "notify-send" "Licht" (format "Custom %d/%d %dK" lg acer ct)
             "--app-name" "dwm-licht" "--expire-time" "4000"
             "--icon" "brightness-high-symbolic" "--replace-id" "126"))))

(defn ask-user []
  (let [echo-proc (process ["echo" "-e" (str/join "\n" (into (sorted-map) settings))])]
    (-> (process {:prev echo-proc
                  :out :string
                  :cmd ["wmenu" "-i" "-l" (str (count settings)) "-p" "licht"
                        "-f" "HackNerdFont 15" "-N" (:polar1 nord) "-M" (:orange nord)
                        "-m" (:snow3 nord) "-S" (:orange nord) "-s" (:snow3 nord)]})
        deref :out str/trim clojure.edn/read-string first)))


(defn set-lights! [first-arg]
  (let [valid-arg (get settings first-arg)
        user-choice (if valid-arg first-arg (ask-user))]
    (if-not user-choice
      (println "no selection, exiting")
      (cond
        (= user-choice "cust") (set-custom-lights!)
        (= user-choice "get")  (notify-lights!)
        :else
        (let [selected-value (get settings user-choice)]
          (illuminate! (:vals selected-value))
          (spit "/tmp/licht-curr-val" (str user-choice "\n"))
          (shell "notify-send" "Licht" (:name selected-value)
                 "--app-name" "dwm-licht" "--expire-time" "4000"
                 "--icon" "brightness-high-symbolic" "--replace-id" "126"))))))


(let [fst (first *command-line-args*)]
  (if (= "get" fst)
    (print-all-the-light-we-can-see)
    (set-lights! fst)))
