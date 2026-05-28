#!/usr/bin/env bb

(require '[clojure.pprint])
(require '[clojure.string :as str])
(require '[babashka.http-client :as http])
(require '[babashka.pods :as pods])
(pods/load-pod 'retrogradeorbit/bootleg "0.1.9")
(require '[pod.retrogradeorbit.bootleg.utils :as utils])
(require '[pod.retrogradeorbit.hickory.select :as s])



(defn get-inner
  "Concatenate all text within a hickory node (bare string, element map, or
   content vector). Recurses through nesting like <a><abbr>…</abbr></a> and,
   crucially, gathers *mixed* content such as [\"(\" {<abbr>sth.</abbr>} \")\"]
   → \"(sth.)\" — earlier this stopped at the leading \"(\" and dropped the rest."
  [node]
  (cond
    (string? node) node
    (map? node)    (get-inner (:content node))
    (vector? node) (apply str (map get-inner node))
    :else          ""))

;; with just the *or* as filter
#_({:a ("to" "dare" "sth."), :div ("to"), :dfn ("to"), :var ("to")}
   {:a ("etw." "wagen"), :div ("4994"), :dfn (), :var ()})
;; with the if
#_({:a ("to" "dare" "sth."), :div (), :dfn (), :var ()}
   {:a ("etw." "wagen"), :div ("4994"), :dfn (), :var ()})
(defn filter-n-get-innermost [a-vector tag]
  (let [filter-fn (if (= :a tag)
                    #(or (= tag (:tag %)) (= :b (:tag %)) (string? %)) ; stuff like "to" is just a str, not nested; bare <b> for unlinked headwords
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
;; dict.cc now wraps long cells' <a> chain in <div id="elliwrap..."> with
;; overflow:hidden + JS-driven expand-on-hover. Splice such divs' content
;; back into the top level so filter-n-get-innermost can see the <a> tags.
(defn flatten-elliwrap [a-vector]
  (mapcat (fn [elem]
            (if (and (map? elem)
                     (= :div (:tag elem))
                     (some-> elem :attrs :id (str/starts-with? "elliwrap")))
              (:content elem)
              [elem]))
          a-vector))

(defn extract-from-vec
  "Each vector represents one half of a row in the table (search term or translation).

   Above are two corresponding vectors for illustration purposes"
  [a-vector]
  (let [a-vector    (flatten-elliwrap a-vector)
        content-for (partial filter-n-get-innermost a-vector)]
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
        resp (http/get "https://www.dict.cc/" {:headers h :query-params {"s" word}})
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

  resp

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
