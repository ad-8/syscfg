#!/usr/bin/env bb
;; Searchable keybind popup for Hyprland.
;; Parses ~/.config/hypr/hyprland.lua directly (hyprctl gives opaque __lua args).

(require '[clojure.string :as str]
         '[babashka.process :refer [shell]])

(def config (str (System/getenv "HOME") "/.config/hypr/hyprland.lua"))
(def lines (-> config slurp str/split-lines))

;; Resolve simple local variable declarations (local foo = "bar")
(def vars
  (into {"scripts" (str (System/getenv "HOME") "/syscfg/scripts")}
        (keep #(when-let [[_ k v] (re-find #"^local\s+(\w+)\s*=\s*\"([^\"]+)\"" %)] [k v])
              lines)))

(def modifiers #{"SHIFT" "CTRL" "ALT" "SUPER"})

(defn mod-combo [mod-args]
  (let [keys (->> (re-seq #"\"([^\"]+)\"" mod-args) (map second))]
    ;; last key must not be a modifier (catches loop vars like mod("SHIFT", key))
    (when (and (seq keys) (not (modifiers (last keys))))
      (str "SUPER+" (str/join "+" keys)))))

(defn clean-action [s]
  (-> s str/trim
      ;; strip trailing Lua line comments (only after closing paren — avoids eating --flag args)
      (str/replace #"\)\s*--[^'\"]*$" ")")
      (str/replace #"exec_cmd\((\w+)\)"
                   (fn [[_ v]] (str "exec " (get vars v v))))
      (str/replace #"exec_cmd\(scripts \.\. \"([^\"]+)\"\)"
                   (fn [[_ path]] (str "exec " (str/replace-first path #"^/" ""))))
      (str/replace #"exec_cmd\(\"([^\"]+)\"\)"
                   "exec $1")
      (str/replace "hl.dsp." "")
      (str/replace #"\)\s*$" "")))

(defn extract-action [line mod-pattern]
  (-> line (str/replace mod-pattern "") clean-action))

(let [rows
      (loop [[line & rest] lines
             section "misc"
             submap  nil
             acc     []]
        (if (nil? line)
          acc
          (let [section' (or (some-> (re-find #"^-- ([a-zA-Z].+)" line)
                                     second str/trim)
                             section)
                submap'  (cond
                           (re-find #"hl\.define_submap\(" line)
                           (some-> (re-find #"hl\.define_submap\(\"([^\"]+)\"" line) second)
                           (= (str/trim line) "end)") nil
                           :else submap)
                mod-m    (re-find #"hl\.bind\(mod\(([^)]+)\)" line)
                bare-m   (when (and submap (not mod-m))
                           (re-find #"^[\s]*hl\.bind\(\"([^\"]+)\"" line))]
            (cond
              mod-m
              (let [combo (mod-combo (second mod-m))
                    act   (extract-action line #".*hl\.bind\(mod\([^)]*\),\s*")]
                (recur rest section' submap'
                       (if combo (conj acc [submap section' combo act]) acc)))

              bare-m
              (let [act (extract-action line #".*hl\.bind\(\"[^\"]*\",\s*")]
                (recur rest section' submap'
                       (conj acc [submap section' (second bare-m) act])))

              :else (recur rest section' submap' acc)))))

      text (->> rows
                (map (fn [[sub sect combo act]]
                       (let [pfx (if sub (format "[%-10s]" sub) "           ")]
                         (format "%s  %-28s  %-22s  %s" pfx combo sect act))))
                (str/join "\n"))]
  (shell {:in text}
         "rofi -dmenu -i -p keybinds -no-show-icons -theme-str 'window {width: 1500px;} listview {lines: 22;}'"))
