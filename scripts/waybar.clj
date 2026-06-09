#!/usr/bin/env bb
(ns waybar
  (:require [clojure.string :as str]
            [babashka.fs :as fs]
            [babashka.process :refer [shell]]
            [cheshire.core :as json]))

(defn err-unknow-action []
  (println "error-unknown-action"))

(defn waybar-date []
  (let [date-str (-> (shell {:out :string} "date '+%a %d.%m.'")
                     :out
                     str/trim)]
    (println date-str)))

(defn- print-free-space [output-fmt]
  (let [free-space-on-root (->> (shell {:out :string} "df -h / --output=avail")
                                :out
                                str/split-lines
                                last
                                str/trim)
        fmt (format "󰋊 %s" free-space-on-root)
        free-space-int (or (some-> (re-find #"\d+" free-space-on-root) Integer/parseInt) 0)
        class (if (< free-space-int 25) :low :ok)
        json (json/encode {:text fmt :class class})]

    (if (= "json" output-fmt)
      (println json)
      (println fmt))))

(defn waybar-disk []
  (print-free-space "json"))

(defn waybar-licht []
  (let [path "/tmp/licht-curr-val"
        licht-val (if (fs/exists? path) (slurp path) "--")]
    (printf " %s" licht-val)))


(defn waybar-load []
  (let [num-cores (.availableProcessors (Runtime/getRuntime))
        loadavg (-> (shell {:out :string} "sh -c 'cat /proc/loadavg'")
                    :out
                    str/trim)
        load-one-min (-> loadavg (str/split #"\s") first)
        loadf (parse-double load-one-min)
        class (cond
                (>= loadf num-cores) :crit
                (>= loadf (* 0.5 num-cores)) :warn
                :else :ok)]
    (println (json/encode {:text (format " %s" load-one-min)
                           :class class}))))


(defn determine-memory
  "returns total and used memory [GiB] as reported by `free -m`"
  []
  (let [[_full-match total used]
        (re-find #"Mem:\s+(\d+)\s+(\d+)" (:out (shell {:out :string} "free -m")))]
    [(/ (parse-long total) 1024.0)
     (/ (parse-long used) 1024.0)]))

(defn- determine-css-class [total used]
  (if (> used (* 0.8 total))
    :low
    :ok))

(defn- print-memory-info [output-fmt]
  (let [[total used] (determine-memory)
        class (determine-css-class total used)
        fmt (format "󰍛 %.1f/%.1f" used total)
        json (json/encode {:text fmt :class class})]
    (if (= "json" output-fmt)
      (println json)
      (println fmt))))

(comment
  (determine-memory)
  (format "%.0f" 15.6)
  (print-memory-info "json")
  ;;
  )

(defn waybar-memory []
  (print-memory-info "json"))

(defn- stdout! [cmd]
  (-> (shell {:out :string} cmd) :out str/trim))

(defn- print-curr-playing []
  (let [out (stdout! "playerctl metadata --format '{{status}}|{{xesam:trackNumber}}|{{xesam:title}}'")
        [status track-number title] (str/split out #"\|" 3)
        out-str (if (str/blank? track-number)
                  title
                  (format "%s. %s" track-number title))]
    (case status
      "Playing" (printf "%s" out-str)
      "Paused" (printf "PAUSED %s" out-str)
      "Stopped" (printf "") ;; does not show up on waybar
      (println "TODO: default case"))))

(def supported-players #{"strawberry" "fooyin" "emms"})

(defn supported-player? [metadata]
  (let [line (-> metadata str/split-lines first)]
    (some #(str/starts-with? line %) supported-players)))

(defn waybar-music []
  (let [proc (shell {:out :string :err :string :continue true} "playerctl metadata")]
    (when (zero? (:exit proc))
      (let [metadata (-> proc :out str/trim)]
        (if (supported-player? metadata)
          (print-curr-playing)
          (printf "err-usp"))))))

(defn compositor
  "Detect the running Wayland compositor. Both waybar launch paths (compositor
  autostart + keybind exec) are spawned by the compositor and inherit its env, so
  the per-compositor IPC socket vars are the strong signal; XDG_CURRENT_DESKTOP is
  a weaker fallback. Defaults to :hypr (the common case)."
  []
  (cond
    (System/getenv "NIRI_SOCKET")                  :niri
    (System/getenv "HYPRLAND_INSTANCE_SIGNATURE")  :hypr
    (= "niri" (System/getenv "XDG_CURRENT_DESKTOP")) :niri
    :else                                          :hypr))

(defn point-compositor-symlink!
  "Repoint ~/.config/waybar/active-compositor.json at the fragment matching the
  running compositor, so config / config-minimal include the right modules-left."
  []
  (let [dir    (fs/expand-home "~/.config/waybar")
        target (fs/file dir (case (compositor)
                              :niri "compositor-niri.json"
                              "compositor-hypr.json"))
        link   (fs/file dir "active-compositor.json")]
    (fs/delete-if-exists link)
    (fs/create-sym-link link target)
    (printf "active-compositor.json -> %s\n" (fs/file-name target))))

(defn waybar-launch
  "Set the compositor symlink, then start waybar. Used by compositor autostart."
  []
  (point-compositor-symlink!)
  (shell {:out :string} "sh -c 'setsid waybar >/dev/null 2>&1 &'"))

(defn waybar-toggle [minimal?]
  ;; `:continue true` prevents the exception on non-zero exit codes.
  (let [status (-> (shell {:out :string :continue true} "sh -c 'pgrep waybar >/dev/null'") :exit)]
    (if (= 0 status)
      (do (println "waybar is running -> killing it")
          (let [status (-> (shell {:out :string} "sh -c 'pkill -f waybar'") :exit)]
            (printf "killing waybar, status = %d\n" status)))
      (do (println "not runnin'")
          (point-compositor-symlink!)
          (if minimal?
            (let [status (-> (shell {:out :string} "sh -c 'setsid waybar -c ~/.config/waybar/config-minimal -s ~/.config/waybar/style.css >/dev/null 2>&1 &'") :exit)]
              (printf "starting waybar, status = %d\n" status))
            (let [status (-> (shell {:out :string} "sh -c 'setsid waybar >/dev/null 2>&1 &'") :exit)]
              (printf "starting waybar, status = %d\n" status)))))))

(defn waybar-vpn []
  (let [interfaces (->> (shell {:out :string :continue true} "wg show interfaces")
                        :out
                        (re-seq #"\S+")
                        (sort-by #(if (= "muc" %) 0 1)))
        out-str (if (seq interfaces)
                  (json/encode {:text (str " " (str/join " + " interfaces))})
                  (json/encode {:text "NO VPN CONN" :state "Critical" :class "down"}))]
    (printf "%s" out-str)))

(defn waybar-notification-status []
  (let [is-paused (-> (shell {:out :string} "dunstctl is-paused")
                      :out
                      str/trim
                      Boolean/parseBoolean)]
    (if is-paused
      (printf " ")
      (printf " "))))

(let [action (first *command-line-args*)]
  (case action
    "date" (waybar-date)
    "launch" (waybar-launch)
    "disk" (waybar-disk)
    "licht" (waybar-licht)
    "load" (waybar-load)
    "memory" (waybar-memory)
    "music" (waybar-music)
    "notification-status" (waybar-notification-status)
    "toggle" (waybar-toggle false)
    "toggle-min" (waybar-toggle true)
    "vpn" (waybar-vpn)
    (err-unknow-action)))
