#!/usr/bin/env bb
;; Searchable keybind popup for Hyprland.
;; Shows only binds that have a description field set.

(require '[clojure.string :as str]
         '[cheshire.core :as json]
         '[babashka.process :refer [shell]])

(def mod-bits {1 "SHIFT" 4 "CTRL" 8 "ALT" 64 "SUPER"})

(defn decode-mods [mask]
  (->> mod-bits
       (filter (fn [[bit _]] (pos? (bit-and mask bit))))
       (map second)
       (str/join "+")))

(defn format-combo [modmask key]
  (let [mods (decode-mods modmask)]
    (if (empty? mods) key (str mods "+" key))))

(let [binds (-> (shell {:out :string} "hyprctl binds -j")
                :out
                (json/parse-string true))
      rows  (->> binds
                 (filter :has_description)
                 (map (fn [{:keys [modmask key submap description]}]
                        (let [combo (format-combo modmask key)
                              pfx   (if (seq submap) (format "[%-10s]" submap) "           ")]
                          (format "%s  %-20s  %s" pfx combo description)))))
      text  (str/join "\n" rows)]
  (shell {:in text}
         "rofi -dmenu -i -p keybinds -no-show-icons -theme-str 'window {width: 900px;} listview {lines: 22;}'"))
