#!/usr/bin/env bb
(ns licht
  (:require [clojure.string :as str]
            [clojure.edn]
            [babashka.process :refer [shell process]])
  (:import java.net.InetAddress))



(defn get-hostname []
  (.getHostName (InetAddress/getLocalHost)))


(defn light-screen [brightness]
  (let [res (shell {:continue true} "light" "-S" (str brightness))]
    (when (not= 0 (:exit res))
      (println "warn: light-screen failed (device may not exist)"))))

; light -L lists available devices
(defn light-keyboard [brightness]
  (let [res (shell {:continue true} "light" "-s" "sysfs/leds/smc::kbd_backlight" "-S" (str brightness))]
    (when (not= 0 (:exit res))
      (println "warn: light-keyboard failed (device may not exist)"))))

(defn get-light-screen []
  (-> (shell {:out :string} "light" "-G") :out str/trim))

(defn get-light-keyboard []
  (-> (shell {:out :string} "light" "-s" "sysfs/leds/smc::kbd_backlight" "-G") :out str/trim))

(defn set-two-monitors [what val]
  (let [vcp-number (case what
                     :brightness 10
                     :contrast   12
                     (throw (ex-info "invalid type for `what`" {:valid-types [:brightness :contrast]})))
        set-display1 (format "ddcutil --display 1 setvcp %d %s" vcp-number val)
        set-display2 (format "ddcutil --display 2 setvcp %d %s" vcp-number (+ val 0))]
    (shell set-display1)
    (Thread/sleep 500)
    (shell set-display2)))

(defn set-one-monitor [what val]
  (let [vcp-number (case what
                     :brightness 10
                     :contrast   12
                     (throw (ex-info "invalid type for `what`" {:valid-types [:brightness :contrast]})))]
    (shell "ddcutil" "setvcp" vcp-number val)))

(comment
  (try (set-two-monitors :foo 23)
       (catch Exception e (println (.getMessage e) "\n" (ex-data e)))) 
  ;;
  )

;; TODO by night +10 (day +0)
(defn set-ext-brightness [val]
  (case (get-hostname)
    "ax-bee" (set-two-monitors :brightness val)
    "ax-mac" (set-one-monitor :brightness val)
    "ax-x1c" (set-one-monitor :brightness val)
    (do (shell "notify-send 'fatal error in licht.clj' 'set-ext-brightness: no setup for this hostname'")
        (System/exit 1))))

;; TODO by night +15 (day +10)
(defn set-ext-contrast [val]
  (case (get-hostname)
    "ax-bee" (set-two-monitors :contrast val)
    "ax-mac" (set-one-monitor :contrast val)
    "ax-x1c" (set-one-monitor :contrast val)
    (do (shell "notify-send 'fatal error in licht.clj' 'set-ext-contrast: no setup for this hostname'")
        (System/exit 1))))

(defn shell-out [cmd]
  (-> (shell {:out :string} cmd) :out str/trim))

(defn extract-vcp-value [s]
  (last (re-find #"\bcurrent value =\s*(\d+)\b" s)))

(comment 
  (re-find  #"\bcurrent value =\s*(\d+)\b" "VCP code 0x10 (Brightness                    ): current value =   100, max value =   100")

  (->> (shell-out "ddcutil detect")
       str/split-lines
       (map str/trim)
       (map-indexed (fn [idx s] [idx s])))
  )

(defn get-two-monitors []
  (let [monitors (->> (shell-out "ddcutil detect") str/split-lines (map str/trim))
        m1 (format "%s: %s (%s)" (nth monitors 0) (nth monitors 4) (nth monitors 9))
        m2 (format "%s: %s (%s)" (nth monitors 12) (nth monitors 16) (nth monitors 21))
        b1 (-> (shell-out  "ddcutil --display 1 getvcp 10") extract-vcp-value)
        b2 (-> (shell-out "ddcutil --display 2 getvcp 10") extract-vcp-value)
        c1 (-> (shell-out "ddcutil --display 1 getvcp 12") extract-vcp-value)
        c2 (-> (shell-out "ddcutil --display 2 getvcp 12") extract-vcp-value)]

    (println (str/replace m1 #"\s+" " "))
    (println "brightness:" b1)
    (println "contrast:  " c1)
    (println (str/replace m2 #"\s+" " "))
    (println "brightness:" b2)
    (println "contrast:  " c2)))


(defn get-one-monitor []
  (let [brigh (-> (shell {:out :string} "ddcutil" "getvcp" "10") :out extract-vcp-value)
        cont  (-> (shell {:out :string} "ddcutil" "getvcp" "12") :out extract-vcp-value)]
    (format "Brightness: %s\nContrast:   %s\n"  brigh cont)))

(defn get-ext-vals []
  (case (get-hostname)
    "ax-bee" (get-two-monitors)
    "ax-mac" (get-one-monitor)
    (do (shell "notify-send 'fatal error in licht.clj' 'get-ext-vals: no setup for this hostname'")
        (System/exit 1))))



(defn set-color-temp [n]
  (try (shell "pkill" "-f" "hyprsunset")
       (catch Exception _e (println "warn: could not kill hyprsunset")))
  (Thread/sleep 500)
  (process ["hyprsunset" "-t" (str n)]))



(defn heading [s]
  (let [line (apply str (repeat (count s) "-"))]
    (format "%s\n%s\n%s" line s line)))


(defn print-all-the-light-we-can-see []
  (case (get-hostname)
    "ax-bee" (get-two-monitors)
    "ax-mac" (let [disp (get-light-screen)
                   keyb (get-light-keyboard)
                   ext  (get-ext-vals)]
               (printf "%s\nDisplay:  %s\nKeyboard: %s" (heading "Internal") disp keyb)
               (printf "\n\n%s\n%s" (heading "External") ext))
    (do (shell "notify-send 'fatal error in licht.clj' 'print-all-the-light-we-can-see: no setup for this hostname'")
        (System/exit 1))))

(defn illuminate! [int-b key-b ext-b ext-c col-t]
  (light-screen int-b) (light-keyboard key-b)
  (set-ext-brightness ext-b) (set-ext-contrast ext-c)
  (set-color-temp col-t))


(def settings {"aus"  {:name "AUS"
                       :vals [0 0 0 0 0]}
               "hi+"   {:name "High"
                       :vals [90 0 90 90 6500]}
               "hi"   {:name "High"
                       :vals [80 0 80 80 6000]}
               "hi2"  {:name "High2"
                       :vals [67 67 67 67 5500]}
               "hi3"  {:name "High3"
                       :vals [59 59 59 59 4900]}
               "lo"   {:name "Low"
                       :vals [23 25 40 33 3750]}
               "ul1"  {:name "Ultra-Low-1"
                       :vals [20 20 35 25 3000]}
               "ul2"  {:name "Ultra-Low-2"
                       :vals [10 10 15 15 3000]}
               "ni"  {:name "night"
                      :vals [2 2 15 15 3000]}
               "ni2"  {:name "night"
                       :vals [2 2 8 8 2000]}
               "max"  {:name "Max"
                       :vals [100 0 100 100 6500]}
               ;; "max-e" {:name "Max-External"
               ;;          :vals [50 0 100 100 6500]}
               "med" {:name "Medium"
                      :vals [50 50 50 50 4250]}
               ;; "kl"   {:name "Kino-Low"
               ;;         :vals [0 5 50 40 3333]}
               ;; "kl2"   {:name "Kino-Low-2"
               ;;          :vals [0 5 25 25 3333]}
               ;; "kh"   {:name "Kino-High"
               ;;         :vals [0 5 80 80 6000]}
               ;; "km"   {:name "Kino-Max"
               ;;         :vals [0 0 100 100 6500]}
               })


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
  (-> (process ["echo" "-e" (str/join "\n" (into (sorted-map) settings))])
      (process {:out :string} ["wmenu" "-i" "-l" "15" "-p" "licht"
                               "-f" "HackNerdFont 15" "-N" (:polar1 nord) "-M" (:orange nord)
                               "-m" (:snow3 nord) "-S" (:orange nord) "-s" (:snow3 nord)])
      deref :out str/trim clojure.edn/read-string first))


(defn set-lights! [first-arg]
  (let [valid-arg (get settings first-arg)
        user-choice (if valid-arg first-arg (ask-user))
        selected-value (get settings user-choice)
        ntfy (format "notify-send Licht %s --app-name dwm-licht --expire-time 4000 --icon 
                      brightness-high-symbolic --replace-id 126" (:name selected-value))]
    (apply illuminate! (:vals selected-value))
    (spit "/tmp/licht-curr-val" (str user-choice "\n"))
    (shell ntfy)))


(let [fst (first *command-line-args*)]
  (if (= "get" fst)
    (print-all-the-light-we-can-see)
    (set-lights! fst)))
