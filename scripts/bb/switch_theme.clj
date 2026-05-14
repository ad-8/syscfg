#!/usr/bin/env bb
;; Usage: switch_theme.clj [theme]
;; Without args, opens wmenu picker. With arg, switches directly.

(ns switch-theme
  (:require [babashka.process :refer [shell process]]
            [babashka.fs :as fs]
            [clojure.string :as str]))

(def themes-dir (fs/path (fs/home) "syscfg/scripts/themes"))

(def apps
  [{:file    "btop.theme"
    :symlink (fs/path (fs/xdg-config-home) "btop/themes/active.theme")
    :reload  #(shell ["pkill" "-SIGUSR2" "btop"])}
   {:file    "foot.theme"
    :symlink (fs/path (fs/xdg-config-home) "foot/active-theme")
    :reload  #(shell ["pkill" "-SIGUSR1" "foot"])}])

(defn available-themes []
  (->> (fs/list-dir themes-dir)
       (filter fs/directory?)
       (map fs/file-name)
       sort))

(defn apply-app-theme [theme-dir {:keys [file symlink reload]}]
  (let [src (fs/path theme-dir file)]
    (when (fs/exists? src)
      (fs/delete-if-exists symlink)
      (fs/create-sym-link symlink src)
      (try (reload) (catch Exception _)))))

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
