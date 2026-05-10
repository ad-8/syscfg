#!/usr/bin/env bb
(ns licht
  (:require [clojure.string :as str]
            [clojure.edn]
            [babashka.process :refer [shell process]])
  (:import java.net.InetAddress))


(defn get-hostname []
  (.getHostName (InetAddress/getLocalHost)))

(def host-config
  {"ax-bee" {:internal false :displays [1 2]}
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
  (-> (shell {:out :string} "light" "-G") :out str/trim))

(defn get-light-keyboard []
  (-> (shell {:out :string} "light" "-s" "sysfs/leds/smc::kbd_backlight" "-G") :out str/trim))


(defn shell-out [cmd]
  (-> (shell {:out :string} cmd) :out str/trim))

(defn extract-vcp-value [s]
  (last (re-find #"\bcurrent value =\s*(\d+)\b" s)))

(comment
  (re-find #"\bcurrent value =\s*(\d+)\b" "VCP code 0x10 (Brightness                    ): current value =   100, max value =   100")

  (->> (shell-out "ddcutil detect")
       str/split-lines
       (map str/trim)
       (map-indexed (fn [idx s] [idx s])))
  )

(defn detect-display-ids []
  (->> (shell-out "ddcutil detect")
       str/split-lines
       (map str/trim)
       (filter #(re-matches #"Display \d+" %))
       (map #(Integer/parseInt (re-find #"\d+" %)))))

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
    (let [res (shell {:continue true} "ddcutil" "--display" (str d) "setvcp" (str vcp-code) (str (ext-val-for-display val idx)))]
      (when (not= 0 (:exit res))
        (println (format "warn: ddcutil setvcp failed for display %d (exit %d)" d (:exit res)))))))

(defn get-ext-display-vals [d]
  (let [b (-> (shell-out (format "ddcutil --display %d getvcp 10" d)) extract-vcp-value)
        c (-> (shell-out (format "ddcutil --display %d getvcp 12" d)) extract-vcp-value)]
    {:display d :brightness b :contrast c}))

(defn print-ext-vals [displays]
  (doseq [{:keys [display brightness contrast]} (map get-ext-display-vals displays)]
    (println (format "Display %d — brightness: %s  contrast: %s" display brightness contrast))))


(defn set-color-temp [n]
  (try (shell "pkill" "-f" "hyprsunset")
       (catch Exception _e (println "warn: could not kill hyprsunset")))
  (Thread/sleep 500)
  (process ["hyprsunset" "-t" (str n)]))


(defn heading [s]
  (let [line (apply str (repeat (count s) "-"))]
    (format "%s\n%s\n%s" line s line)))


(defn print-all-the-light-we-can-see []
  (let [{:keys [internal]} (host-config (get-hostname))
        displays (get-displays)]
    (when internal
      (printf "%s\nDisplay:  %s\nKeyboard: %s\n\n"
              (heading "Internal") (get-light-screen) (get-light-keyboard)))
    (println (heading "External"))
    (print-ext-vals displays)))

(defn illuminate! [{:keys [internal keyboard ext-b ext-c col-temp]}]
  (let [displays (get-displays)]
    (light-screen internal)
    (light-keyboard keyboard)
    (set-ext-vcp displays 10 ext-b)
    (set-ext-vcp displays 12 ext-c)
    (set-color-temp col-temp)))


(def settings
  {"aus"  {:name "AUS"
           :vals {:internal 0  :keyboard 0  :ext-b 0   :ext-c 0   :col-temp 0}}
   "hi+"  {:name "High+"
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
           :vals {:internal 100 :keyboard 0 :ext-b 100 :ext-c 100 :col-temp 6500}}})


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


(defn ask-user []
  (let [echo-proc (process ["echo" "-e" (str/join "\n" (into (sorted-map) settings))])]
    (-> (process {:prev echo-proc
                  :out :string
                  :cmd ["wmenu" "-i" "-l" "15" "-p" "licht"
                        "-f" "HackNerdFont 15" "-N" (:polar1 nord) "-M" (:orange nord)
                        "-m" (:snow3 nord) "-S" (:orange nord) "-s" (:snow3 nord)]})
        deref :out str/trim clojure.edn/read-string first)))


(defn set-lights! [first-arg]
  (let [valid-arg (get settings first-arg)
        user-choice (if valid-arg first-arg (ask-user))]
    (if-not user-choice
      (println "no selection, exiting")
      (let [selected-value (get settings user-choice)
            ntfy (format "notify-send Licht %s --app-name dwm-licht --expire-time 4000 --icon brightness-high-symbolic --replace-id 126" (:name selected-value))]
        (illuminate! (:vals selected-value))
        (spit "/tmp/licht-curr-val" (str user-choice "\n"))
        (shell ntfy)))))


(let [fst (first *command-line-args*)]
  (if (= "get" fst)
    (print-all-the-light-we-can-see)
    (set-lights! fst)))
