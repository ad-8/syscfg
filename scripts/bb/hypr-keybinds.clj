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

(defn format-combo [modmask k]
  (let [mods (decode-mods modmask)]
    (if (empty? mods) k (str mods "+" k))))

(try
  (let [binds    (-> (shell {:out :string} "hyprctl binds -j")
                     :out
                     (json/parse-string true))
        filtered (->> binds
                      (filter :has_description)
                      (map (fn [b] (assoc b :combo (format-combo (:modmask b) (:key b)))))
                      (sort-by (juxt :submap :combo)))
        col-w    (reduce max 20 (map (comp count :combo) filtered))
        fmt      (str "%s  %-" col-w "s  %s")
        rows     (map (fn [{:keys [combo submap description]}]
                        (let [pfx (if (seq submap) (format "[%-10.10s]" submap) "            ")]
                          (format fmt pfx combo description)))
                      filtered)
        text     (str/join "\n" rows)]
    (shell {:in text :continue true}
           "rofi -dmenu -i -p keybinds -no-show-icons -theme-str 'window {width: 900px;} listview {lines: 22;}'"))
  (catch Exception e
    (binding [*out* *err*]
      (println (str "hypr-keybinds: " (ex-message e))))
    (System/exit 1)))
