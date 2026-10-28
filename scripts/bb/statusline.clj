#!/usr/bin/env bb

(ns statusline
  (:require [cheshire.core :as json]
            [babashka.process :as process]
            [clojure.string :as str])
  (:import [java.time Instant]
           [java.time.temporal ChronoUnit]))

(def esc (str (char 27) "["))

(defn parse-instant
  "Parses `v` as epoch seconds or an ISO-8601 timestamp, or returns nil.

  ```clojure
  (parse-instant 1790000000)             ;=> #object[java.time.Instant \"2026-09-21T14:13:20Z\"]
  (parse-instant \"2026-10-28T12:00:00Z\") ;=> #object[java.time.Instant \"2026-10-28T12:00:00Z\"]
  (parse-instant nil)                    ;=> nil
  ```"
  [v]
  (when (seq (str v))
    (try (Instant/ofEpochSecond (Long/parseLong (str v)))
         (catch Exception _
           (try (Instant/parse (str v))
                (catch Exception _ nil))))))

(defn eta-str
  "Returns the time left until `resets-at` as days and hours, hours and minutes, or minutes, or nil once it has passed.
  A second unit that is zero is left out.

  ```clojure
  ;; with the reset 2 days, 3 hours and 10 minutes away
  (eta-str resets-at) ;=> \"2d3h\"
  ;; 2 days, 0 hours and 10 minutes away
  (eta-str resets-at) ;=> \"2d\"
  ;; 50 seconds away
  (eta-str resets-at) ;=> \"<1m\"
  ```"
  [resets-at]
  (when-let [reset-inst (parse-instant resets-at)]
    (let [secs (.between ChronoUnit/SECONDS (Instant/now) reset-inst)]
      (when (pos? secs)
        (let [days  (quot secs 86400)
              hours (quot (rem secs 86400) 3600)
              mins  (quot (rem secs 3600) 60)]
          (cond
            (pos? days)  (str days "d" (when (pos? hours) (str hours "h")))
            (pos? hours) (str hours "h" (when (pos? mins) (str mins "m")))
            (pos? mins)  (str mins "m")
            :else        "<1m"))))))

(defn shorten-dir
  "Replaces the `$HOME` prefix of `dir` with `~`.

  ```clojure
  ;; HOME=/home/ax
  (shorten-dir \"/home/ax/syscfg\") ;=> \"~/syscfg\"
  (shorten-dir \"/home/axel\")      ;=> \"/home/axel\"
  ```"
  [dir]
  (let [home (System/getenv "HOME")]
    (cond
      (not (and home (str/starts-with? dir home)))  dir
      (= (count dir) (count home))                  "~"
      (= \/ (.charAt dir (count home)))             (str "~" (subs dir (count home)))
      :else                                         dir)))

(defn git-branch
  "Returns the current git branch for dir, truncated to 20 chars, or nil if not a git repo."
  [dir]
  (when dir
    (try
      (let [branch (-> (process/sh "git" "-C" dir "branch" "--show-current")
                       :out str/trim)]
        (when (seq branch)
          (let [limit 20]
            (if (> (count branch) limit)
              (str (subs branch 0 (- limit 1)) "…")
              branch))))
      (catch Exception _ nil))))

(defn pct-str
  "Formats a usage percentage rounded to a whole number, coloured green below 50, yellow from 50, red from 75 and bold underlined red from 90."
  [pct]
  (let [n     (Math/round (double pct))
        color (cond (>= n 90) (str esc "1;4;31m")
                    (>= n 75) (str esc "31m")
                    (>= n 50) (str esc "33m")
                    :else     (str esc "32m"))]
    (str color n "%" esc "0m")))

(defn rate-seg
  "Builds one rate-limit segment, or nil when `pct` is nil.

  ```clojure
  (rate-seg \"5h\" 55 \"2h10m\") ;=> \"5h: 55% (↻2h10m)\", with 55% in yellow
  (rate-seg \"7d\" 12 nil)     ;=> \"7d: 12%\", with 12% in green
  ```"
  [label pct eta]
  (when pct
    (str label ": " (pct-str pct)
         (when eta (str " (↻" eta ")")))))

(defn short-hostname
  "Returns the first label of `/etc/hostname`, or \"localhost\" if it can't be read."
  []
  (try (-> (slurp "/etc/hostname") str/trim (str/split #"\.") first)
       (catch Exception _ "localhost")))

(defn env-info
  "Looks up the user, host and git branch that `status-line` shows for `input`."
  [input]
  {:user   (or (System/getenv "USER") (System/getenv "LOGNAME") "user")
   :host   (short-hostname)
   :branch (git-branch (get-in input [:workspace :current_dir]))})

(defn status-line
  "Builds the status line from Claude Code's statusline JSON, parsed with keyword keys,
  and the user, host and branch from `env-info`. Percentages carry ANSI colours (see `pct-str`).

  ```clojure
  ;; HOME=/home/ax
  (status-line {:workspace      {:current_dir \"/home/ax/syscfg\"}
                :model          {:display_name \"Opus\"}
                :effort         {:level \"low\"}
                :context_window {:total_input_tokens 12345}
                :rate_limits    {:five_hour {:used_percentage 55}}}
               {:user \"ax\" :host \"ax-bee\" :branch \"master\"})
  ;=> \"ax@ax-bee | ~/syscfg (master) | Opus - low | ctx: 12.3k | 5h: 55%\", with 55% in yellow
  ```"
  [input {:keys [user host branch]}]
  (let [five-pct (get-in input [:rate_limits :five_hour :used_percentage])
        week-pct (get-in input [:rate_limits :seven_day :used_percentage])
        five-eta (eta-str (get-in input [:rate_limits :five_hour :resets_at]))
        week-eta (eta-str (get-in input [:rate_limits :seven_day :resets_at]))
        raw-dir  (get-in input [:workspace :current_dir])
        dir      (some-> raw-dir shorten-dir)
        model    (get-in input [:model :display_name])
        effort   (get-in input [:effort :level])
        ctx-tok  (get-in input [:context_window :total_input_tokens])
        ctx      (when ctx-tok (format "%.1fk" (/ ctx-tok 1000.0)))]
    (->> [(str user "@" host)
          (if branch (str dir " (" branch ")") dir)
          (when model (str model (when effort (str " - " effort))))
          (when (and effort (not model)) effort)
          (when ctx (str "ctx: " ctx))
          (rate-seg "5h" five-pct five-eta)
          (rate-seg "7d" week-pct week-eta)]
         (remove nil?)
         (str/join " | "))))

(when (= *file* (System/getProperty "babashka.file"))
  (let [input (json/parse-string (slurp *in*) true)]
    (print (status-line input (env-info input)))))
