#!/usr/bin/env bb

(ns check-updates
  "Update flake.lock, dry-run the system build, report what would change, then restore the lock."
  (:require [clojure.string :as str]
            [babashka.fs :as fs]
            [cheshire.core :as json]
            [bling.core :refer [bling]]
            [babashka.process :refer [sh shell]]))

(def flake (str (fs/home) "/syscfg/nixos-config"))
(def lock-file (str flake "/flake.lock"))

(defn node-names
  "Map each flake.lock node key to a readable input path, e.g. mangowm/scenefx."
  [lock]
  (let [nodes (get lock "nodes")]
    (loop [queue [[(get lock "root") nil]], names {}]
      (if-let [[[node prefix] & more] (seq queue)]
        (let [children (for [[input target] (get-in nodes [node "inputs"])
                             :when (and (string? target) (not (contains? names target)))]
                         [target (if prefix (str prefix "/" input) input)])]
          (recur (concat more children) (into names (map (juxt first second) children))))
        names))))

(defn lock-label
  "Format a locked input as its date plus short commit."
  [locked]
  (str (.toLocalDate (.atOffset (java.time.Instant/ofEpochSecond (get locked "lastModified"))
                                java.time.ZoneOffset/UTC))
       (when-let [rev (get locked "rev")] (str " " (subs rev 0 7)))))

(defn updated-inputs
  "Lines for every input whose lock changed between two flake.lock maps, sorted by name."
  [old new]
  (let [old-nodes (get old "nodes")
        names (node-names new)]
    (->> (for [[node data] (get new "nodes")
               :let [locked (get data "locked")
                     old-locked (get-in old-nodes [node "locked"])]
               :when (and locked (not= (get locked "narHash") (get old-locked "narHash")))]
           [(get names node node)
            (if old-locked
              (format "%-30s %s -> %s" (get names node node) (lock-label old-locked) (lock-label locked))
              (format "%-30s %s (new)" (get names node node) (lock-label locked)))])
         (sort-by (comp str/lower-case first))
         (map second))))

(defn store-name
  "Strip the /nix/store/<hash>- prefix from a store path."
  [path]
  (str/replace path #"^\s*/nix/store/[a-z0-9]{32}-" ""))

(defn split-name
  "Split a store name into package name, version and suffix; nil when there is no version.
  The suffix is any tail of letter-only parts (-env, -getent, -npm) plus the output (-bin, -dev, …);
  prerelease tags (-alpha, -beta, -pre, -preview, -rc, any case) stay in the version."
  [n]
  (when-let [[_ pname version tail output]
             (re-matches #"(.+?)-([0-9][^_]*?)((?:-(?!(?i:alpha|beta|pre|preview|rc)\b)[A-Za-z][A-Za-z_]*)*?)(-(?:bin|dev|doc|man|lib|info|devdoc|debug))?" n)]
    {:pname pname :version version :tail tail :suffix (str tail output)}))

(defn parse-dry-run
  "Collect the fetched paths, their total size and the built derivations from nixos-rebuild
  dry-run output, counting store paths outside both lists as unparsed."
  [lines]
  (loop [[line & more] lines, mode nil, acc {:fetched [] :built [] :unparsed 0}]
    (cond
      (nil? line) acc
      (str/includes? line "will be fetched")
      (recur more :fetched (assoc acc :fetch-size (second (re-find #"\(([^)]*)\)" line))))
      (str/includes? line "will be built") (recur more :built acc)
      (str/starts-with? line "  /nix/store/")
      (recur more mode (case mode
                         :fetched (update acc :fetched conj (store-name line))
                         :built (update acc :built conj (str/replace (store-name line) #"\.drv$" ""))
                         (update acc :unparsed inc)))
      :else (recur more nil acc))))

(defn versions
  "Map [name key] to the set of versions among the given store names, key being :suffix or :tail."
  [key names]
  (->> (keep split-name names)
       (group-by (juxt :pname key))
       (#(update-vals % (fn [xs] (set (map :version xs)))))))

(defn shared-parts
  "Count the leading version parts two versions share."
  [a b]
  (count (take-while true? (map = (str/split a #"[.+-]") (str/split b #"[.+-]")))))

(defn replaced-versions
  "The current versions a new one replaces: the closest matches by leading parts.
  Those fetched or built again stay; empty when all of them stay, so the new version sits alongside."
  [old staying version]
  (let [by-score (group-by #(shared-parts version %) old)]
    (sort (remove staying (by-score (apply max (keys by-score)))))))

(defn report-line
  "Format one fetched package as old -> new, (new) or (rebuilt)."
  [current fetched built n]
  (if-let [{:keys [pname version tail suffix]} (split-name n)]
    (let [label (str pname suffix)
          old (get current [pname suffix])
          staying (into (get fetched [pname suffix] #{}) (get built [pname tail]))
          from (cond (nil? old) []
                     (old version) nil
                     :else (replaced-versions old staying version))]
      (cond
        (nil? from) (format "%-30s %s (rebuilt)" label version)
        (empty? from) (format "%-30s %s (new)" label version)
        :else (bling [:system-green (format "%-30s %s -> %s" label (str/join ", " from) version)])))
    (format "%-30s (no version)" n)))

(defn heading
  "Render a section heading in bold blue."
  [text]
  (bling [:bold.system-blue text]))

(defn report
  "Build all output lines: updated inputs, derivations to build, packages to fetch."
  [old-lock new-lock dry-run-lines current-paths]
  (let [inputs (updated-inputs old-lock new-lock)
        {:keys [fetched built fetch-size unparsed]} (parse-dry-run dry-run-lines)
        current (versions :suffix (map store-name current-paths))
        fetched-versions (versions :suffix fetched)
        built-versions (versions :tail built)]
    (concat [(heading "Updated inputs:")]
            (if (seq inputs) inputs ["none"])
            ["" (heading (str (count built) " derivations to build:"))]
            (if (seq built) (sort-by str/lower-case built) ["none"])
            ["" (heading (str "Packages to fetch" (when fetch-size (str " (" fetch-size ")")) ":"))]
            (if (seq fetched)
              (map #(report-line current fetched-versions built-versions %) (sort-by str/lower-case fetched))
              ["none"])
            (when (pos? unparsed)
              ["" (str "warning: " unparsed " store paths in the dry-run output were not parsed; run upd for the raw output")]))))

(defn read-lock
  "Parse the current flake.lock."
  []
  (json/parse-string (slurp lock-file)))

(when (= *file* (System/getProperty "babashka.file"))
  (let [old-text (slurp lock-file)
        _ (.addShutdownHook (Runtime/getRuntime) (Thread. #(spit lock-file old-text)))
        [new-lock {:keys [exit out err]}]
        (do
          (shell "nix" "flake" "update" "--flake" flake)
          (shell "git" "-C" flake "status" "--short")
          (println "\n----------\n")
          (println "evaluating...")
          [(read-lock)
           (sh "nixos-rebuild" "dry-run" "--flake" (str flake "#" (str/trim (:out (sh "uname" "-n")))))])]
    (println "\n----------\n")
    (when-not (zero? exit)
      (print (str out err))
      (flush)
      (System/exit exit))
    (run! println (report (json/parse-string old-text) new-lock
                          (str/split-lines (str out err))
                          (str/split-lines (:out (sh "nix-store" "-qR" "/run/current-system")))))))
