#!/usr/bin/env bb
(ns dwm-toggle-notifications
  (:require [clojure.string :as str]
            [babashka.process :refer [shell]]))


(defn get-state []
  (let [paused? (-> (shell {:out :string} "dunstctl is-paused") :out str/trim)]
    (if (= "true" paused?)
      :paused
      :active)))


(defn ntfy [new-state]
  (let [icon (if (= :active new-state) "notification-active" "notification-disabled")
        cmd (format "notify-send Notifications %s --app-name dwm-notif --expire-time 2000 
                     --icon %s --replace-id 125" (name new-state) icon)]
    (shell cmd)))


(when (= *file* (System/getProperty "babashka.file"))
  (case (get-state)
    :active (and (ntfy :paused) (shell "sleep 2") (shell "dunstctl set-paused true"))
    :paused (and (shell "dunstctl set-paused false") (ntfy :active))))
