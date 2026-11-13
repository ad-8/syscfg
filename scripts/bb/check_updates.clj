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
  "Map each flake.lock node key to a readable input path, e.g. hyprland/hyprutils."
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
  "Split a store name into package name, version and output suffix; nil when there is no version."
  [n]
  (when-let [[_ pname version output]
             (re-matches #"(.+?)-([0-9][^_]*?)(-(?:bin|dev|doc|man|lib|info|devdoc|debug))?" n)]
    {:pname pname :version version :output output}))

(defn parse-dry-run
  "Collect the fetched paths and built derivations from nixos-rebuild dry-run output."
  [lines]
  (loop [[line & more] lines, mode nil, acc {:fetched [] :built []}]
    (cond
      (nil? line) acc
      (str/includes? line "will be fetched") (recur more :fetched acc)
      (str/includes? line "will be built") (recur more :built acc)
      (str/starts-with? line "  /nix/store/")
      (recur more mode (case mode
                         :fetched (update acc :fetched conj (store-name line))
                         :built (update acc :built conj (str/replace (store-name line) #"\.drv$" ""))
                         acc))
      :else (recur more nil acc))))

(defn current-versions
  "Map [name output] to the set of versions in the running system's closure."
  [paths]
  (->> (keep (comp split-name store-name) paths)
       (group-by (juxt :pname :output))
       (#(update-vals % (fn [xs] (set (map :version xs)))))))

(defn report-line
  "Format one fetched package as old -> new, (new) or (rebuilt)."
  [current n]
  (if-let [{:keys [pname version output]} (split-name n)]
    (let [label (str pname output)
          old (get current [pname output])]
      (cond
        (nil? old) (format "%-30s %s (new)" label version)
        (old version) (format "%-30s %s (rebuilt)" label version)
        :else (format "%-30s %s -> %s" label (str/join ", " (sort old)) version)))
    (format "%-30s (no version)" n)))

(defn heading
  "Render a section heading in bold blue."
  [text]
  (bling [:bold.system-blue text]))

(defn report
  "Build all output lines: updated inputs, derivations to build, packages to fetch."
  [old-lock new-lock dry-run-lines current-paths]
  (let [inputs (updated-inputs old-lock new-lock)
        {:keys [fetched built]} (parse-dry-run dry-run-lines)
        current (current-versions current-paths)]
    (concat [(heading "Updated inputs:")]
            (if (seq inputs) inputs ["none"])
            ["" (heading (str (count built) " derivations to build:"))]
            (if (seq built) (sort-by str/lower-case built) ["none"])
            ["" (heading "Packages to fetch:")]
            (if (seq fetched)
              (sort-by str/lower-case (map #(report-line current %) fetched))
              ["none"]))))

(defn read-lock
  "Parse the current flake.lock."
  []
  (json/parse-string (slurp lock-file)))

(when (= *file* (System/getProperty "babashka.file"))
  (let [old-text (slurp lock-file)
        [new-lock {:keys [exit out err]}]
        (try
          (shell "nix" "flake" "update" "--flake" flake)
          (shell "git" "-C" flake "status" "--short")
          (println "\n----------\n")
          (println "evaluating...")
          [(read-lock)
           (sh "nixos-rebuild" "dry-run" "--flake" (str flake "#" (str/trim (:out (sh "uname" "-n")))))]
          (finally (spit lock-file old-text)))]
    (println "\n----------\n")
    (when-not (zero? exit)
      (print (str out err))
      (flush)
      (System/exit exit))
    (run! println (report (json/parse-string old-text) new-lock
                          (str/split-lines (str out err))
                          (str/split-lines (:out (sh "nix-store" "-qR" "/run/current-system")))))))
