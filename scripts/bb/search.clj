#!/usr/bin/env bb
(ns search
  (:require [babashka.process :refer [process shell]]
            [clojure.edn]
            [clojure.string :as str]))

(def all
  {:ddg "https://duckduckgo.com/?q="
   :kagi "https://kagi.com/search?q="
   :mab "https://www.metal-archives.com/search?type=band_name&searchString="
   :github "https://github.com/search?q="
   :amazon "https://www.amazon.de/s?k="
   :wikipedia-en "https://en.wikipedia.org/w/index.php?title=Special:Search&search="
   :wikipedia-de "https://de.wikipedia.org/w/index.php?title=Special:Search&search="
   :dict-cc "https://www.dict.cc/?s="
   :yt "https://www.youtube.com/results?search_query="
   :deepl "https://www.deepl.com/translator#en/de/"
   :bandcamp "https://bandcamp.com/search?q="
   :arch-wiki "https://wiki.archlinux.org/index.php?search="
})

(def fav (find all :ddg))


(defn get-query []
  (-> (process {:in "" :out :string} "wmenu" "-p" "Enter search term")
      deref :out str/trim))

(defn get-search-engine []
  (-> (process "echo" "-e" (str/join "\n" (sort-by key all)))
      (process {:out :string} "wmenu" "-i" "-l" "25" "-p" "Select search engine")
      deref :out str/trim clojure.edn/read-string))

(defn search! [search-engine query]
  (println "se=" search-engine "q=" query "qempty?" (empty? query))
  (if (empty? query)
    (prn "foo")
    (shell "firefox" (str (last search-engine) query))))


(let [arg1 (first *command-line-args*)]
  (if (= "--select-provider" arg1)
    (let [se (get-search-engine)
          q  (if (nil? se) nil (get-query))]
      (search! se q))
    (search! fav (get-query))))
