#!/usr/bin/env bb
;; Searchable keybind popup for Hyprland.
;; Shows only binds that have a description field set.

(require '[clojure.string :as str]
         '[cheshire.core :as json]
         '[babashka.process :refer [shell]])

(def mod-bits
  "X11/Wayland modifier flag values mapped to names. Hyprland encodes the
  active modifier set as a single integer `modmask` in `hyprctl` JSON output:
  `SHIFT`=1, `CTRL`=4, `ALT`=8, `SUPER`=64. A bind like SUPER+SHIFT has `modmask`=65."
  {1 "SHIFT" 4 "CTRL" 8 "ALT" 64 "SUPER"})

(defn decode-mods
  "Takes a `modmask` integer and returns the active modifier names joined with `+`.
  For each `[bit name]` in `mod-bits`, tests `(bit-and mask bit)`; keeps names where
  the result is positive. Returns `\"\"` when no bits match (e.g. `mask`=0).
  ### Example:
  ```clojure
  (decode-mods 65) ;; \"SHIFT+SUPER\"  (65 = 1 (SHIFT) + 64 (SUPER))
  (decode-mods 0)  ;; \"\"```"
  [mask]
  (->> mod-bits
       (filter (fn [[bit _]] (pos? (bit-and mask bit))))
       (map second)
       (str/join "+")))

(defn format-combo
  "Builds a human-readable key combo string from a `modmask` and key name.
  Returns just `k` when the mask has no modifiers (guards against a leading `+`).
  ### Example:
  ```clojure
  (format-combo 65 \"Return\") ;; \"SHIFT+SUPER+Return\"
  (format-combo 0  \"F5\")     ;; \"F5\"```"
  [modmask k]
  (let [mods (decode-mods modmask)]
    (if (empty? mods) k (str mods "+" k))))

;; Fetch described binds from hyprctl, sort by submap then combo, format into
;; aligned columns with a dynamically-sized combo width, and pipe into a rofi
;; dmenu popup. Hyprctl failures are caught, reported to stderr, and exit 1.
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
