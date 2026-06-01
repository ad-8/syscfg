#!/usr/bin/env bb
;; Usage: switch_theme.clj [theme]
;; Without args, opens wmenu picker. With arg, switches directly.

(ns switch-theme
  (:require [babashka.process :refer [shell process]]
            [babashka.fs :as fs]
            [clojure.string :as str]))

(def themes-dir (fs/path (fs/home) "syscfg/themes"))

(def theme-categories
  {:dark  #{"everforest-dark" "gotham" "gruvbox-dark" "iceberg" "nord" "osaka-jade"
            "oxocarbon" "solarized-dark" "tokyo-night" "winter-is-coming-dark-blue"}
   :light #{"doric-marble" "flatwhite" "gruvbox-light" "nord-light" "solarized-light"}
   :mono  #{"amber" "lumon" "matrix" "vantablack"}
   :muted #{"doric-plum" "doric-walnut" "wilmersdorf"}
   :neon  #{"hackerman" "laserwave" "matte-black" "retro-82" "tron-legacy"}})

(defn foot-osc
  "Builds OSC escape sequences from a foot theme file to set terminal foreground, background, cursor, and palette colors."
  [theme-file]
  (str/join
    (for [line (str/split-lines (slurp (str theme-file)))
          :let [[k v] (str/split line #"=" 2)]
          :when v]
      (cond
        (= k "foreground") (str "\033]10;#" v "\007")
        (= k "background") (str "\033]11;#" v "\007")
        (= k "cursor")     (when-let [fg (second (remove str/blank? (str/split v #" +")))]
                             (str "\033]12;#" fg "\007"))
        (re-matches #"regular[0-7]" k) (str "\033]4;" (last k) ";#" v "\007")
        (re-matches #"bright[0-7]" k)  (str "\033]4;" (+ 8 (Integer/parseInt (str (last k)))) ";#" v "\007")))))

(defn foot-ptys
  "Returns PTY device paths (/dev/pts/*) of all child processes of running foot instances."
  []
  (->> (-> (process ["pgrep" "-x" "foot"] {:out :string}) deref :out str/trim str/split-lines)
       (remove str/blank?)
       (mapcat #(-> (process ["pgrep" "-P" %] {:out :string}) deref :out str/trim str/split-lines))
       (remove str/blank?)
       (keep (fn [pid]
               (try
                 (let [link (-> (process ["readlink" (str "/proc/" pid "/fd/1")] {:out :string}) deref :out str/trim)]
                   (when (str/starts-with? link "/dev/pts/") link))
                 (catch Exception _ nil))))))

(defn reload-foot
  "Writes OSC color-change sequences derived from src to all open foot terminals."
  [src]
  (let [osc (foot-osc src)]
    (doseq [pty (foot-ptys)]
      (try (spit pty osc :append true) (catch Exception _)))))

(defn no-reload
  "Placeholder reload for apps that don't require an explicit restart."
  [_] nil)

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
    :reload  no-reload}
   {:file    "rofi.rasi"
    :symlink (fs/path (fs/xdg-config-home) "rofi/active-theme.rasi")
    :reload  no-reload}
   {:file    "fuzzel.ini"
    :symlink (fs/path (fs/xdg-config-home) "fuzzel/active-theme.ini")
    :reload  no-reload}
   {:file    "dunst.conf"
    :symlink (fs/path (fs/xdg-config-home) "dunst/active-theme.conf")
    :reload  (fn [_]
               (shell {:continue true}
                      (str "dunstctl reload "
                           (fs/path (fs/xdg-config-home) "dunst/dunstrc") " "
                           (fs/path (fs/xdg-config-home) "dunst/active-theme.conf"))))}])

(defn available-themes
  "Returns a sorted list of theme names (directory names) found in themes-dir."
  []
  (->> (fs/list-dir themes-dir)
       (filter fs/directory?)
       (map fs/file-name)
       sort))

(defn apply-app-theme
  "Symlinks the app's theme file from theme-dir and calls its reload fn; prints a warning and sends a notification if the file is missing."
  [theme-dir {:keys [file symlink reload]}]
  (let [src (fs/path theme-dir file)]
    (if (fs/exists? src)
      (do
        (fs/create-dirs (fs/parent symlink))
        (fs/delete-if-exists symlink)
        (fs/create-sym-link symlink src)
        (try (reload src) (catch Exception _)))
      (do
        (binding [*out* *err*] (println "switch_theme: missing" (str src)))
        (shell {:continue true} ["notify-send" "-u" "critical" "switch_theme" (str "missing: " (fs/file-name src))])))))

(defn switch-theme
  "Validates that theme exists in themes-dir, then applies it to all configured apps."
  [theme]
  (let [theme-dir (fs/path themes-dir theme)]
    (when-not (fs/directory? theme-dir)
      (binding [*out* *err*] (println "Unknown theme:" theme))
      (System/exit 1))
    (run! #(apply-app-theme theme-dir %) apps)))

(defn pick-theme
  "Opens a fuzzel dmenu picker populated with available themes and returns the selected theme name."
  []
  (let [themes (available-themes)
        n-themes (count themes)]
    (-> (process ["fuzzel" "--dmenu" "-l" n-themes "-p" (str "select theme (" n-themes "): ")]
               {:in (str/join "\n" themes) :out :string})
      deref
      :out
      str/trim)))

(defn pick-theme-grouped
  "Opens a fuzzel dmenu picker with themes grouped by category. Category headers are injected as non-theme rows; reopens the picker if a header is selected; returns nil if cancelled."
  []
  (let [groups    (for [cat [:dark :light :mono :muted :neon]]
                    [cat (sort (theme-categories cat))])
        lines     (mapcat (fn [[cat themes]]
                            (cons (str "── " (name cat) " ──") themes))
                          groups)
        theme-set (set (mapcat second groups))
        selection (-> (process ["fuzzel" "--dmenu" "-l" (count lines)
                                "-p" (str "select theme (" (count theme-set) "): ")]
                               {:in (str/join "\n" lines) :out :string})
                      deref :out str/trim)]
    (cond
      (theme-set selection)              selection
      (str/starts-with? selection "── ") (recur)
      :else                              nil)))

(let [arg   (first *command-line-args*)
      theme (case arg
              nil        (pick-theme)
              "--groups" (pick-theme-grouped)
              arg)]
  (when-not (str/blank? theme)
    (switch-theme theme)))
