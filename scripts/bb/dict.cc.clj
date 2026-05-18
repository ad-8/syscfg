#!/usr/bin/env bb

(require '[clojure.pprint])
(require '[clojure.string :as str])
(require '[babashka.http-client :as http])
(require '[babashka.pods :as pods])
(pods/load-pod 'retrogradeorbit/bootleg "0.1.9")
(require '[pod.retrogradeorbit.bootleg.utils :as utils])
(require '[pod.retrogradeorbit.hickory.select :as s])



(defn get-inner [elem]
  (loop [current elem]
    (let []
      (cond
        (string? current) current
        (map? current) (recur (:content current))
        (vector? current) (if (string? (first current))
                            (first current)
                            (recur (first current)))
        :else :should-not-happen))))

;; with just the *or* as filter
#_({:a ("to" "dare" "sth."), :div ("to"), :dfn ("to"), :var ("to")}
   {:a ("etw." "wagen"), :div ("4994"), :dfn (), :var ()})
;; with the if
#_({:a ("to" "dare" "sth."), :div (), :dfn (), :var ()}
   {:a ("etw." "wagen"), :div ("4994"), :dfn (), :var ()})
(defn filter-n-get-innermost [a-vector tag]
  (let [filter-fn (if (= :a tag)
                    #(or (= tag (:tag %)) (string? %)) ; stuff like "to" is just a str, not nested
                    #(= tag (:tag %)))]

    (->> a-vector
         (filter filter-fn)
         (map get-inner)
         (map str/trim)
         (remove str/blank?)
         (remove #(= " " %)) ;; U+00A0 non-breaking space, not caught by str/blank?
         )))


#_([{:type :element,
     :attrs {:href "/?s=whimsical"},
     :tag :a,
     :content [{:type :element, :attrs nil, :tag :b, :content ["whimsical"]}]}
    " "
    {:type :element, :attrs {:title "adjective"}, :tag :var, :content ["{adj}"]}]
   [{:type :element, :attrs {:style "float:right;color:#999;user-select:none;"}, :tag :div, :content ["1470"]}
    {:type :element, :attrs {:href "/?s=skurril"}, :tag :a, :content ["skurril"]}
    " "])
(defn extract-from-vec
  "Each vector represents one half of a row in the table (search term or translation).
   
   Above are two corresponding vectors for illustration purposes"
  [a-vector]
  (let [content-for (partial filter-n-get-innermost a-vector)]
    {:a   (content-for :a)
     :div (content-for :div)
     :dfn (content-for :dfn)
     :var (content-for :var)}))


(defn partition->map [[left right]]
  (let [upvotes (-> right :div first)
        ; sometimes both :a tags are empty and the translation is in the :div tags
        ; TODO would be to better parse beforehand, as stuff gets lost in those cases
        ; (zusammengesetzte Wörter / Redewendungen)
        upvotes' (try
                   (Integer/parseInt upvotes)
                   (catch Exception _e 0))]
    {:x (->> left :a (str/join " "))
     :y (->> right :a (str/join " "))
     :upvotes upvotes'}))


(defn translate [word]
  (let [h {"User-Agent" "Mozilla/5.0 (Windows NT 6.1;) Gecko/20100101 Firefox/141.0.3"} ; LUL
        url (format "https://www.dict.cc/?s=%s" word)
        resp (http/get url {:headers h})
        sel (->> resp :body (utils/html->hickory)
                 (s/select (s/and (s/tag "td") (s/class "td7nl")))
                 (map :content))]

    (->> sel
         (map extract-from-vec)
         (partition 2)
         (map partition->map)
         (sort-by :upvotes >)
         (take 5)
         (clojure.pprint/print-table))))


(translate (str/join "+" *command-line-args*))



(comment
  (def h {"User-Agent" "Mozilla/5.0 (Windows NT 6.1;) Gecko/20100101 Firefox/141.0.3"})

  ;; h to include nouns before low upvoted others
  (def resp (http/get "https://www.dict.cc/?s=whimsical" {:headers h}))


; :a   - überetztung, info like genus
; :dfn - bereich like comp. 
; :div - "like" counter
  (def selection
    (->> resp
         :body
         (utils/html->hickory)
         (s/select (s/and (s/tag "td") (s/class "td7nl")))
         (map :content)))

  (->> selection
       (map extract-from-vec)
       (partition 2)
       (map partition->map)
       (sort-by :upvotes >)
       (take 5)
       (clojure.pprint/print-table))


  ;;
  )
