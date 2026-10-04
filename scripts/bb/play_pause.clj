#!/usr/bin/env bb

(ns play-pause
  (:require [clojure.string :as str]
            [babashka.process :refer [sh shell]]))

(def players "strawberry,fooyin,emms,%any")

(def state->actions
  {:play  [(str "timeout 2 playerctl -p " players " play")
           "notify-send playerctl Playing... --app-name=dwm-play-pause --expire-time=2000 --icon exaile-play --replace-id=123 --urgency=low"]
   :pause [(str "timeout 2 playerctl -p " players " pause")
           "notify-send playerctl Pausing... --app-name=dwm-play-pause --expire-time=2000 --icon exaile-pause --replace-id=123 --urgency=low"]})

(defn execute-commands [cmds]
  (every? #(zero? (:exit (shell {:continue true} %))) cmds))

(defn set-player [new-state]
  (if-let [commands (get state->actions new-state)]
    (execute-commands commands)
    :error))

(let [res (sh "timeout" "2" "playerctl" "-p" players "status")]
  (when (zero? (:exit res))
    (case (str/trim (:out res))
      "Playing" (set-player :pause)
      ("Paused" "Stopped") (set-player :play)
      :unknown-status)))
