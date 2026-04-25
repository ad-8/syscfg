(ns niri
  (:require
   [babashka.process :refer [process shell]]
   [cheshire.core :as json]
   [clojure.string :as str]))


(defn- list-windows []
  (sort-by :id (-> (shell {:out :string} "niri msg --json windows")
                   :out
                   str/split-lines
                   first
                   (json/parse-string true))))


(defn- format-window [{:keys [id title app_id]}]
  (format "%3d   %s (%s)" id title app_id))


(defn- selected-window-id [s]
  (let [[_ id] (re-find #"\s?(\d+)\s{3}.*" s)]
    id))


(defn- niri-switch-to-window [id]
  (shell {:out :string} (format "niri msg action focus-window --id %s" id)))


(defn switch-to-window-all-workspaces
  "Lets the user select a window from a list of all windows
  across all workspaces, then switches focus to it."
  []
  (let [windows (list-windows)
        windows-lines (str/join "\n" (map format-window windows))
        prompt (format "Select from %d windows" (count windows))
        rofi (format "rofi -dmenu -i -p \"%s\"" prompt)
        user-choice (-> (process {:in windows-lines :out :string} rofi)
                        deref :out str/trim)
        id (selected-window-id user-choice)]
    (niri-switch-to-window id)
    {:choice user-choice :id id}))


(let [action (first *command-line-args*)]
  (case action
    "select-window-from-all" (switch-to-window-all-workspaces)
    (System/exit 1)))

