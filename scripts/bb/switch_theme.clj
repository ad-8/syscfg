#!/usr/bin/env bb
;; Usage: switch_theme.clj [theme]
;; Without args, opens wmenu picker. With arg, switches directly.

(ns switch-theme
  (:require [babashka.process :refer [shell process]]
            [babashka.fs :as fs]
            [clojure.string :as str]))

(def themes-dir (fs/path (fs/home) "syscfg/themes"))

(def theme-categories
  {:dark     #{"everforest-dark" "gotham" "gruvbox-dark" "iceberg" "lumon" "modus-vivendi"
               "nord" "osaka-jade" "oxocarbon" "solarized-dark" "tokyo-night"
               "winter-is-coming-dark-blue"}
   :light    #{"doric-marble" "doric-oak" "flatwhite" "gruvbox-light" "modus-operandi"
               "nord-light" "solarized-light"}
   :muted    #{"doric-plum" "doric-walnut" "wilmersdorf"}
   :neon     #{"hackerman" "laserwave" "matte-black" "retro-82" "tron-legacy"}
   :phosphor #{"amber" "matrix" "vantablack"}})

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

(defn kitty-sockets
  "Returns remote-control socket paths of running kitty instances. listen_on unix:/tmp/kitty appends -<pid>, so each instance has its own /tmp/kitty-<pid> socket."
  []
  (try (map str (fs/glob "/tmp" "kitty-*")) (catch Exception _ nil)))

(defn reload-kitty
  "Live-updates colors in every running kitty instance via remote control, reading the active theme file. --all recolors open windows, --configured makes new windows in the instance inherit it too."
  [src]
  (doseq [sock (kitty-sockets)]
    (try
      (shell {:continue true} "kitten" "@" "--to" (str "unix:" sock)
             "set-colors" "--all" "--configured" (str src))
      (catch Exception _))))

(defn reload-tmux
  "Re-sources the active tmux theme file into the running tmux server, if any.
   Guarded by list-sessions so we don't spawn a server when none is running."
  [src]
  (shell {:continue true} "sh" "-c"
         (str "tmux list-sessions >/dev/null 2>&1 && tmux source-file " src)))

(defn no-reload
  "Placeholder reload for apps that don't require an explicit restart."
  [_] nil)

(def apps
  [{:file    "btop.theme"
    :dest    (fs/path (fs/xdg-config-home) "btop/themes/active.theme")
    :reload  (fn [_] (shell ["pkill" "-SIGUSR2" "btop"]))}
   {:file    "foot.theme"
    :dest    (fs/path (fs/xdg-config-home) "foot/active-theme")
    :reload  reload-foot}
   {:file    "kitty.conf"
    :dest    (fs/path (fs/xdg-config-home) "kitty/active-theme.conf")
    :reload  reload-kitty}
   {:file    "tmux.conf"
    :dest    (fs/path (fs/xdg-config-home) "tmux/active-theme.conf")
    :reload  reload-tmux}
   {:file    "waybar.css"
    :dest    (fs/path (fs/xdg-config-home) "waybar/active-theme.css")
    ;; Restart via `waybar.clj launch` (not bare `waybar`) so the gitignored
    ;; active-compositor.json include target is (re)created first; a missing one
    ;; is a fatal config-load error that kills the whole bar.
    :reload  (fn [_]
               (when (zero? (:exit (shell {:continue true} "sh -c 'pgrep waybar >/dev/null'")))
                 (shell {:continue true} "sh -c 'pkill waybar'")
                 (shell {:continue true} (str "bb " (fs/path (fs/home) "syscfg/scripts/waybar.clj") " launch"))))}
   {:file    "hyprland.lua"
    :dest    (fs/path (fs/xdg-config-home) "hypr/active-theme.lua")
    :reload  (fn [_] (shell ["hyprctl" "reload"]))}
   {:file    "niri.kdl"
    :dest    (fs/path (fs/xdg-config-home) "niri/active-theme.kdl")
    :reload  (fn [_] (shell ["niri" "msg" "action" "load-config-file"]))}
   {:file    "emacs-theme.el"
    :dest    (fs/path (fs/xdg-config-home) "doom/active-theme.el")
    :reload  no-reload}
   {:file    "rofi.rasi"
    :dest    (fs/path (fs/xdg-config-home) "rofi/active-theme.rasi")
    :reload  no-reload}
   {:file    "fuzzel.ini"
    :dest    (fs/path (fs/xdg-config-home) "fuzzel/active-theme.ini")
    :reload  no-reload}
   {:file    "dunst.conf"
    :dest    (fs/path (fs/xdg-config-home) "dunst/active-theme.conf")
    :reload  (fn [_]
               (shell {:continue true}
                      (str "dunstctl reload "
                           (fs/path (fs/xdg-config-home) "dunst/dunstrc") " "
                           (fs/path (fs/xdg-config-home) "dunst/active-theme.conf"))))}
   ;; wlr-which-key reads exactly one file and has no include directive, so the
   ;; theme fragment can't sit beside the menu as its own symlink — :base makes
   ;; this entry generate config.yaml instead. No reload: every binding spawns a
   ;; fresh process, so the next menu open already has the new colors.
   {:file    "wlr-which-key.yaml"
    :dest    (fs/path (fs/xdg-config-home) "wlr-which-key/config.yaml")
    :base    (fs/path (fs/home) "syscfg/dotfiles/wlr-which-key/.config/wlr-which-key/menu.yaml")
    :reload  no-reload}])

(defn available-themes
  "Returns a sorted list of theme names (directory names) found in themes-dir."
  []
  (->> (fs/list-dir themes-dir)
       (filter fs/directory?)
       (map fs/file-name)
       sort))

(defn apply-app-theme
  "Points dest at the app's theme file and calls its reload fn; prints a warning and sends a notification if the file is missing.
   Normally dest becomes a symlink to src. With :base, dest is instead written as src concatenated onto the base file — via a temp file and an atomic rename, so a reader can never catch a half-written config."
  [theme-dir {:keys [file dest base reload]}]
  (let [src (fs/path theme-dir file)]
    (if (fs/exists? src)
      (do
        (fs/create-dirs (fs/parent dest))
        (if base
          (let [tmp (fs/path (fs/parent dest) (str (fs/file-name dest) ".tmp"))]
            (spit (str tmp) (str (slurp (str src)) "\n" (slurp (str base))))
            (fs/move tmp dest {:replace-existing true :atomic-move true}))
          (do
            (fs/delete-if-exists dest)
            (fs/create-sym-link dest src)))
        (try (reload src) (catch Exception _)))
      (do
        (binding [*out* *err*] (println "switch_theme: missing" (str src)))
        (shell {:continue true} "notify-send" "-u" "critical" "switch_theme" (str "missing: " (fs/file-name src)))))))

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
  (let [groups    (for [cat [:dark :light :muted :neon :phosphor]]
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
