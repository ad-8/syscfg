#!/usr/bin/env bb
(ns set-random-wallpaper
  (:require [clojure.java.io :as io]
            [clojure.java.shell :as shell]
            [clojure.string :as str]
            [babashka.process :refer [shell]]))



(def wallpaper-base (io/file (System/getProperty "user.home") "sync" "wallpapers" "bing"))

(comment
  (->> (shell/sh "ls" (str wallpaper-base))
       :out
       (str/split-lines)))

(def wallpaper-dir (io/file wallpaper-base))

(defn set-wallpaper-xorg [path]
  (let [feh (format "feh --bg-scale \"%s\"" path)]
    (shell/sh "sh" "-c" feh)
    (println "Wallpaper changed.")))


(defn set-wallpaper-wayland [path]
  (let [feh (format "swaybg --image \"%s\"" path)]
    ;; by default, swaybg just "stacks" the wallpapers
    (try (shell "pkill -f swaybg") (catch Exception e))
    (Thread/sleep 250)
    (shell/sh "sh" "-c" feh)
    (println "Wallpaper changed.")))


(defn ends-with-extension? [^java.io.File f, ^String e]
  (let [file (.toLowerCase (.getName f))
        ext  (.toLowerCase e)]
    (.endsWith file ext)))

; w/o boolean, returns true or nil 
; doesnt matter w/ filter, but old version of this fn returned true or false, so ...
(defn picture?
  "Predicate Function that returns true if file is a picture."
  [f]
  (let [exts #{".jpg" ".jpeg" ".png"}]
    (boolean (some #(ends-with-extension? f %) exts))))


(defn random-wallpaper [dir]
  (->> dir
       file-seq
       (filter picture?) ; removes e.g. the containing dir and obv. other files
       rand-nth))


(defn get-session-type []
  (-> (shell {:out :string} "/usr/bin/env bash -c" "echo $XDG_SESSION_TYPE") :out str/trim))


(defn set-wall [path]
  (if (= "wayland" (get-session-type))
    (set-wallpaper-wayland path)
    (set-wallpaper-xorg path)))


(when (= *file* (System/getProperty "babashka.file"))
  (-> wallpaper-dir
      random-wallpaper
      set-wall))
