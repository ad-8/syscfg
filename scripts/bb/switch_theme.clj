#!/usr/bin/env bb
;; Usage: switch_theme.clj [theme]
;; Without args, opens wmenu picker. With arg, switches directly.

(ns switch-theme
  (:require [babashka.process :refer [shell process]]
            [babashka.fs :as fs]
            [clojure.string :as str]))

(def themes-dir (fs/path (fs/home) "syscfg/scripts/themes"))

(defn foot-osc [theme-file]
  (let [sb (StringBuilder.)]
    (doseq [line (str/split-lines (slurp (str theme-file)))]
      (let [[k v] (str/split line #"=" 2)]
        (when v
          (cond
            (= k "foreground")         (.append sb (str "\033]10;#" v "\007"))
            (= k "background")         (.append sb (str "\033]11;#" v "\007"))
            (= k "cursor")             (when-let [fg (second (str/split v #" +"))]
                                         (.append sb (str "\033]12;#" fg "\007")))
            (re-matches #"regular[0-7]" k) (.append sb (str "\033]4;" (last k) ";#" v "\007"))
            (re-matches #"bright[0-7]" k)  (.append sb (str "\033]4;" (+ 8 (Integer/parseInt (str (last k)))) ";#" v "\007"))))))
    (str sb)))

(defn foot-ptys []
  (->> (-> (process ["pgrep" "-x" "foot"] {:out :string}) deref :out str/trim str/split-lines)
       (remove str/blank?)
       (mapcat #(-> (process ["pgrep" "-P" %] {:out :string}) deref :out str/trim str/split-lines))
       (remove str/blank?)
       (keep (fn [pid]
               (try
                 (let [link (-> (process ["readlink" (str "/proc/" pid "/fd/1")] {:out :string}) deref :out str/trim)]
                   (when (str/starts-with? link "/dev/pts/") link))
                 (catch Exception _ nil))))))

(defn reload-foot [src]
  (let [osc (foot-osc src)]
    (doseq [pty (foot-ptys)]
      (try (spit pty osc :append true) (catch Exception _)))))

(def apps
  [{:file    "btop.theme"
    :symlink (fs/path (fs/xdg-config-home) "btop/themes/active.theme")
    :reload  (fn [_] (shell ["pkill" "-SIGUSR2" "btop"]))}
   {:file    "foot.theme"
    :symlink (fs/path (fs/xdg-config-home) "foot/active-theme")
    :reload  reload-foot}
   {:file    "waybar.css"
    :symlink (fs/path (fs/xdg-config-home) "waybar/active-theme.css")
    :reload  (fn [_]
               (shell {:continue true} "sh -c 'pkill -f waybar'")
               (shell "sh -c 'setsid waybar >/dev/null 2>&1 &'"))}
   {:file    "hyprland.lua"
    :symlink (fs/path (fs/xdg-config-home) "hypr/active-theme.lua")
    :reload  (fn [_] (shell ["hyprctl" "reload"]))}
   {:file    "emacs-theme.el"
    :symlink (fs/path (fs/xdg-config-home) "doom/active-theme.el")
    :reload  (fn [_] nil)}
   {:file    "rofi.rasi"
    :symlink (fs/path (fs/xdg-config-home) "rofi/active-theme.rasi")
    :reload  (fn [_] nil)}])

(defn available-themes []
  (->> (fs/list-dir themes-dir)
       (filter fs/directory?)
       (map fs/file-name)
       sort))

(defn apply-app-theme [theme-dir {:keys [file symlink reload]}]
  (let [src (fs/path theme-dir file)]
    (when (fs/exists? src)
      (when symlink
        (fs/create-dirs (fs/parent symlink))
        (fs/delete-if-exists symlink)
        (fs/create-sym-link symlink src))
      (try (reload src) (catch Exception _)))))

(defn switch-theme [theme]
  (let [theme-dir (fs/path themes-dir theme)]
    (when-not (fs/directory? theme-dir)
      (println (str "Unknown theme: " theme))
      (System/exit 1))
    (run! #(apply-app-theme theme-dir %) apps)))

(defn pick-theme []
  (-> (process ["wmenu" "-p" "theme"]
               {:in (str/join "\n" (available-themes)) :out :string})
      deref
      :out
      str/trim))

(let [theme (or (first *command-line-args*) (pick-theme))]
  (when-not (str/blank? theme)
    (switch-theme theme)))
