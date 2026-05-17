#!/usr/bin/env bb
(ns wayland
  (:require [clojure.string :as str]
            [babashka.process :refer [shell]]
            [cheshire.core :as json]))


(defn err-unknow-action []
  (println "error-unknown-action"))

(defn- stdout! [cmd]
  (-> (shell {:out :string} cmd) :out str/trim))

(defn- status! [cmd]
  (-> (shell {:out :string :continue true} "sh -c" cmd) :exit))


(defn- volume-up []
  (println "volume +")
  (let [status0 (status! "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
        status1 (status! "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+")]
    (println "exit codes:" status0, status1)))

(defn- volume-down []
  (println "volume -")
  (let [status0 (status! "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0")
        status1 (status! "wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-")]
    (println "exit codes:" status0, status1)))

(defn- volume-mute []
  (println "volume MUTE")
  (let [status0 (status! "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")]
    (println "exit code:" status0)))

(defn- current-volume
  "Returns the current volume as an Integer between *0-100* (...), 
   as well as the stdout of the `wpctl` command."
  []
  (let [vol-str (stdout! "wpctl get-volume @DEFAULT_AUDIO_SINK@") ; Volume: 0.42 
        vol-digits (->> vol-str
                        (filter #(Character/isDigit %))
                        (apply str))
        vol (or (parse-long (str/replace vol-digits #"^0+" "")) 0)]
    [vol vol-str]))

(defn- volume-send-notification
  "Sends a volume notification using dunstify."
  [volume muted?]
  (let [icon (cond
               muted? "muted"
               (< volume 33) "low"
               (< volume 66) "medium"
               :else "high")
        text (if muted?
               "Currently muted"
               (str "Currently at " volume "%"))]
    (shell "dunstify"
           "-a" "Volume"
           "-r" "9993"
           "-h" (str "int:value:" volume)
           "-i" (str "audio-volume-" icon)
           "Volume.clj"
           text
           "-t" "2000"
           "-u" "low")))

(defn volume
  "Increment, decrement, or mute the volume using Pipewire and send a notification.
   
   Original script by `https://github.com/ericmurphyxyz/dotfiles`
   as first seen on `https://www.youtube.com/watch?v=XWlbaERuDP4`."
  [action]
  (println "action = " action)

  ;; set volume
  (case action
    :up (volume-up)
    :down (volume-down)
    :mute (volume-mute))

  ;; determine new volume && send notification
  (let [[vol vol-str] (current-volume)]
    (case action
      :mute (if (str/includes? vol-str "MUTED")
              (volume-send-notification vol true)
              (volume-send-notification vol false))
      (volume-send-notification vol false))))


(let [action (first *command-line-args*)]
  (case action
    "volume-up" (volume :up)
    "volume-down" (volume :down)
    "volume-mute" (volume :mute)
    (err-unknow-action)))
