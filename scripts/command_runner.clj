#!/usr/bin/env bb
(ns command-runner
  (:require [babashka.deps :as deps]
            [babashka.fs :as fs]
            [babashka.process :refer [shell]]
            [bling.core :refer [bling print-bling callout point-of-interest]]
            [clojure.string :as str]
            [clj-yaml.core :as yaml]))


(defn- flatten-commands [commands-data]
  (mapcat
   (fn [command-data]
     (map
      #(assoc % :category (:category command-data))
      (get command-data :commands [])))
   commands-data))


;;  ((juxt a b c) x) => [(a x) (b x) (c x)]
(defn- extract-cmd-names [all-commands]
  (->> all-commands
       ;; sort by :category, and where it is equal, sort by :name
       (sort-by (juxt (comp str/lower-case :category)
                      (comp str/lower-case :name)))
       reverse
       (map #(str (:category %) ": " (:name %)))))


(defn- get-user-selection
  "Uses `fzf` to present a list of commands to the user and return the users choice."
  [command-names]
  (try (str/trim (:out (shell {:in (str/join "\n" command-names) :out :string} "fzf")))
       (catch Exception e ((println "No command selected" (.getMessage e))
                           (System/exit 0)))))


'({:category "Help", :commands ({:name "help - about R", :cmd "echo 'This is R, a simple command runner.'"})}
  {:category "System",
   :commands
   ({:name "Check disk usage", :cmd "df -h / && echo && df -h | grep -i nas"}
    {:name "toggle notifications (dunst)", :cmd "$HOME/scripts/dunst_toggle_and_notify.clj"})}
  {:etc :pp})
(def commands-data (yaml/parse-string (slurp (fs/file (fs/home) "x/commands.yml"))))


'({:name "help - about R", :cmd "echo 'This is R, a simple command runner.'", :category "Help"}
  {:name "Check disk usage", :cmd "df -h / && echo && df -h | grep -i nas", :category "System"}
  {:name "toggle notifications (dunst)", :cmd "$HOME/scripts/dunst_toggle_and_notify.clj", :category "System"}
  {:etc :pp})
(def all-commands
  (flatten-commands commands-data))


(let [; ("Wttr: Show loss" "Wttr: Show data" "Wttr: Plot" "...")
      command-names (extract-cmd-names all-commands) 
      ; "help - about R"
      actual-command-name (str/trim (second (str/split (get-user-selection command-names) #": " 2))) 
      ; #ordered/map ([:name help - about R] [:cmd echo 'This is R, a simple command runner.'] [:category Help])
      selected-command (first (filter #(= (:name %) actual-command-name) all-commands))
      cmd-info (callout {:type :info :theme :sideline :label-theme :marquee :label "command-runner"}
                        (str "running " (bling [:olive (:name selected-command)]) "\n"
                             "cmd     " (bling [:olive.bold (:cmd selected-command)])))]
  (print-bling cmd-info)
  (shell "sh" "-c" (:cmd selected-command)))
