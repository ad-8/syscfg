#!/usr/bin/env janet

# dict.cc en<->de lookup, a Janet port of dict.cc.joke (itself a port of
# dict.cc.clj; all three are kept alongside each other):
#   dict.cc.janet word...       top-5 translations as a table
#   dict.cc.janet -N word...    top-N results as EDN ({:en .. :de .. :upvotes ..})
#                               for the anki_import.clj bulk pipeline
#
# HTTPS shells out to curl on purpose: Janet core has no TLS/HTTP. The HTML is
# picked apart with PEGs where joker used regexes. EDN output is emitted by
# hand because janet's %j escapes UTF-8 bytes as \xNN, which EDN can't read.


### --- shelling out ----------------------------------------------------------

# Lifted verbatim from spork/sh.janet (MIT, (c) 2022 Calvin Rose). Reads both
# pipes via ev/gather (no deadlock) and wraps the process in `with` for fd
# cleanup. Kept inline so this script stays self-contained.

(defn exec-slurp-all
  ``Execute args with `os/spawn`; return {:out :err :status} (trimmed stdout,
  trimmed stderr, exit code). Never raises on a non-zero exit.``
  [& args]
  (with [proc (os/spawn args :p {:out :pipe :err :pipe})]
    (let [[out err status]
          (ev/gather
            (ev/read (proc :out) :all)
            (ev/read (proc :err) :all)
            (os/proc-wait proc))]
      {:out (if out (string/trimr out) "")
       :err (if err (string/trimr err) "")
       :status status})))


### --- UTF-8 / HTML entities -------------------------------------------------

(defn utf8-encode
  "Encode a Unicode codepoint to a UTF-8 string (1-4 bytes)."
  [cp]
  (def b @"")
  (cond
    (< cp 0x80)    (buffer/push-byte b cp)
    (< cp 0x800)   (buffer/push-byte b (bor 0xC0 (brshift cp 6))
                                       (bor 0x80 (band cp 0x3F)))
    (< cp 0x10000) (buffer/push-byte b (bor 0xE0 (brshift cp 12))
                                       (bor 0x80 (band (brshift cp 6) 0x3F))
                                       (bor 0x80 (band cp 0x3F)))
    (buffer/push-byte b (bor 0xF0 (brshift cp 18))
                        (bor 0x80 (band (brshift cp 12) 0x3F))
                        (bor 0x80 (band (brshift cp 6) 0x3F))
                        (bor 0x80 (band cp 0x3F))))
  (string b))

(def entities
  {"amp" "&" "lt" "<" "gt" ">" "quot" "\"" "apos" "'" "nbsp" " "})

# Single pass: numeric entities via utf8-encode, named ones via the table
# (unknown names pass through untouched), everything else copied as-is.
(def unescape-peg
  (peg/compile
    ~(% (any (+ (/ (* "&#" (set "xX") (number :h+ 16) ";") ,utf8-encode)
                (/ (* "&#" (number :d+) ";") ,utf8-encode)
                (/ (* "&" (<- :w+) ";")
                   ,(fn [name] (get entities name (string "&" name ";"))))
                (<- 1))))))

(defn html-unescape [s]
  (first (peg/match unescape-peg s)))


### --- HTML cell parsing -----------------------------------------------------

(def td-peg
  (peg/compile
    ~(any (+ (* "<td" (<- (to ">")) ">" (<- (to "</td>")) "</td>") 1))))

(defn td7nl-blocks [html-body]
  (seq [[attrs body] :in (partition 2 (or (peg/match td-peg html-body) []))
        :when (and body (string/find `class="td7nl"` attrs))]
    body))

(def whitespace '(+ "\xC2\xA0" (set " \t\r\n")))  # incl. raw non-breaking space

(def words-peg
  (peg/compile
    ~(any (+ ,whitespace (<- (some (if-not ,whitespace 1)))))))

(defn cell-texts [cell]
  (def cleaned
    (->> cell
         # only strip the upvote div (digit-only content);
         # the elliwrap div wraps translation <a> tags and must survive
         (peg/replace-all ~(* "<div" (to ">") ">" :d+ "</div>") "")
         (peg/replace-all ~(* "<dfn" (thru "</dfn>")) "")
         (peg/replace-all ~(* "<var" (thru "</var>")) "")
         (peg/replace-all ~(* "<sup" (thru "</sup>")) "")
         (peg/replace-all ~(* "<" (to ">") ">") " ")
         html-unescape))
  (or (peg/match words-peg cleaned) []))

(def upvotes-peg
  (peg/compile
    ~(any (+ (* "<div" (to ">") ">" (number :d+) "</div>") 1))))

(defn div-upvotes [cell]
  (or (first (or (peg/match upvotes-peg cell) [])) 0))


### --- rows ------------------------------------------------------------------

(defn sort-rows
  "Descending by upvotes; janet's sort isn't stable, so tack the page index
  onto the key to break ties in page order (what bb's stable sort-by does)."
  [rows]
  (def keyed (seq [[i r] :pairs rows] [(- (r :upvotes)) i r]))
  (map |(get $ 2) (sort keyed)))

(defn pair->row [[left right]]
  {:upvotes (div-upvotes right)
   :x       (string/join (cell-texts left) " ")
   :y       (string/join (cell-texts right) " ")})

(defn fetch-rows [word]
  (def {:out body :status code}
    (exec-slurp-all
      "curl" "-sfG"
      "-A" "Mozilla/5.0 (Windows NT 6.1;) Gecko/20100101 Firefox/141.0.3"
      "--data-urlencode" (string "s=" word)
      "https://www.dict.cc/"))
  (unless (= 0 code) (os/exit 1))
  (->> (td7nl-blocks body)
       (partition 2)
       (filter |(= 2 (length $)))
       (map pair->row)
       (sort-rows)))


### --- output ----------------------------------------------------------------

(defn ulen
  "String length in codepoints (bytes minus UTF-8 continuation bytes), so
  umlauts don't skew column widths."
  [s]
  (count |(not= 0x80 (band $ 0xC0)) s))

(defn print-table [ks rows]
  (def cell-strs (map (fn [row] (map |(string (get row $ "")) ks)) rows))
  (def ws (seq [[i k] :pairs ks]
            (max (ulen (describe k)) ;(map |(ulen (get $ i)) cell-strs))))
  (defn cell [s w] (string " " (string/repeat " " (- w (ulen s))) s " "))
  (defn row-s [vals] (string "|" (string/join (map cell vals ws) "|") "|"))
  (def sep (string "|" (string/join (map |(string/repeat "-" (+ $ 2)) ws) "+") "|"))
  (print)
  (print (row-s (map describe ks)))
  (print sep)
  (each strs cell-strs
    (print (row-s strs))))

(defn edn-str [s]
  (string `"`
          (->> s
               (string/replace-all "\\" "\\\\")
               (string/replace-all `"` `\"`))
          `"`))

(defn translate-table [word]
  (print-table [:x :y :upvotes] (take 5 (fetch-rows word))))

(defn translate-edn [word n]
  (def rows (take n (fetch-rows word)))
  (print "("
         (string/join
           (map (fn [{:x x :y y :upvotes up}]
                  (string/format "{:en %s, :de %s, :upvotes %d}"
                                 (edn-str x) (edn-str y) up))
                rows)
           " ")
         ")"))


### --- main ------------------------------------------------------------------

(def args (drop 1 (dyn :args)))
(def n-match (when-let [a (first args)]
               (peg/match ~(* "-" (number :d+) -1) a)))
(if-let [[n] n-match]
  (translate-edn (string/join (drop 1 args) "+") n)
  (translate-table (string/join args "+")))
