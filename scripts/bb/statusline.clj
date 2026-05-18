#!/usr/bin/env bb

(ns statusline
  (:require [cheshire.core :as json]
            [clojure.string :as str])
  (:import [java.time Instant]
           [java.time.temporal ChronoUnit]))

(defn parse-instant [v]
  (when (seq (str v))
    (try (Instant/ofEpochSecond (Long/parseLong (str v)))
         (catch Exception _
           (try (Instant/parse (str v))
                (catch Exception _ nil))))))

(defn eta-str [resets-at]
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

(defn shorten-dir [dir]
  (let [home (System/getenv "HOME")]
    (cond
      (not (and home (str/starts-with? dir home)))  dir
      (= (count dir) (count home))                  "~"
      (= \/ (.charAt dir (count home)))             (str "~" (subs dir (count home)))
      :else                                         dir)))

(let [input     (json/parse-string (slurp *in*) true)
      five-pct  (get-in input [:rate_limits :five_hour :used_percentage])
      week-pct  (get-in input [:rate_limits :seven_day :used_percentage])
      five-eta  (eta-str (get-in input [:rate_limits :five_hour :resets_at]))
      week-eta  (eta-str (get-in input [:rate_limits :seven_day :resets_at]))
      dir       (some-> (get-in input [:workspace :current_dir]) shorten-dir)
      model     (get-in input [:model :display_name])
      effort    (get-in input [:effort :level])
      ctx-tok   (get-in input [:context_window :total_input_tokens])
      ctx       (when ctx-tok (format "%.1fk" (/ ctx-tok 1000.0)))
      host      (try (-> (slurp "/etc/hostname") str/trim (str/split #"\.") first)
                     (catch Exception _ "localhost"))
      user      (or (System/getenv "USER") (System/getenv "LOGNAME") "user")
      esc       (str (char 27) "[")
      pct-str   (fn [pct]
                  (let [n     (Math/round (double pct))
                        color (cond (>= pct 90) (str esc "1;4;31m")
                                    (>= pct 75) (str esc "31m")
                                    (>= pct 50) (str esc "33m")
                                    :else       (str esc "32m"))]
                    (str color n "%" esc "0m")))
      rate-seg  (fn [label pct eta]
                  (when pct
                    (str label ": " (pct-str pct)
                         (when eta (str " (resets " eta ")")))))
      parts     (remove nil?
                  [(str user "@" host)
                   dir
                   (when model (str model (when effort (str " - " effort))))
                   (when (and effort (not model)) effort)
                   (when ctx (str "ctx: " ctx))
                   (rate-seg "5h" five-pct five-eta)
                   (rate-seg "7d" week-pct week-eta)])]
  (print (str/join " | " parts)))
