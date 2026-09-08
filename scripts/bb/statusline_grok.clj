#!/usr/bin/env bb

(ns statusline-grok
  (:require [babashka.http-client :as http]
            [cheshire.core :as json]
            [clojure.java.io :as io]
            [clojure.string :as str])
  (:import [java.time Instant]
           [java.time.temporal ChronoUnit]))

(def cache-ttl-secs 60)

(defn parse-instant [v]
  (when (seq (str v))
    (try (Instant/parse (str v))
         (catch Exception _ nil))))

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

(defn truncate [s n]
  (when (seq s)
    (if (> (count s) n)
      (str (subs s 0 (dec n)) "…")
      s)))

(defn grok-home []
  (or (System/getenv "GROK_HOME")
      (str (System/getenv "HOME") "/.grok")))

(defn weekly-cache-file []
  (io/file (grok-home) "statusline-billing.json"))

(defn read-weekly-cache []
  (let [f (weekly-cache-file)]
    (when (.exists f)
      (try (json/parse-string (slurp f) true)
           (catch Exception _ nil)))))

(defn write-weekly-cache [data]
  (try
    (spit (weekly-cache-file)
          (json/generate-string (assoc data :cached_at (str (Instant/now)))))
    (catch Exception _ nil)))

(defn cache-fresh? [cached]
  (when-let [t (parse-instant (:cached_at cached))]
    (< (.between ChronoUnit/SECONDS t (Instant/now)) cache-ttl-secs)))

(defn unexpired? [acct]
  (when-let [t (parse-instant (:expires_at acct))]
    (.isAfter t (Instant/now))))

(defn grok-auth []
  (let [f (io/file (grok-home) "auth.json")]
    (when (.exists f)
      (try
        (let [accounts (->> (json/parse-string (slurp f) true) vals (filter :key))]
          (or (first (filter unexpired? accounts))
              (first accounts)))
        (catch Exception _ nil)))))

(defn fetch-grok-weekly []
  (when-let [{:keys [key user_id]} (grok-auth)]
    (try
      (let [resp (http/get "https://cli-chat-proxy.grok.com/v1/billing?format=credits"
                           {:headers {"Authorization" (str "Bearer " key)
                                      "X-XAI-Token-Auth" "xai-grok-cli"
                                      "x-userid" (str user_id)
                                      "Accept" "application/json"}
                            :timeout 2500
                            :throw false})
            body (when (and (:status resp) (<= 200 (:status resp) 299))
                   (json/parse-string (:body resp) true))
            cfg  (:config body)
            pct  (:creditUsagePercent cfg)]
        (when (number? pct)
          {:pct pct
           :resets (or (get-in cfg [:currentPeriod :end])
                       (:billingPeriodEnd cfg))}))
      (catch Exception _ nil))))

(defn grok-weekly []
  (let [cached (read-weekly-cache)]
    (if (cache-fresh? cached)
      cached
      (let [data (or (fetch-grok-weekly)
                     (when (number? (:pct cached)) (select-keys cached [:pct :resets]))
                     {:error true})]
        (write-weekly-cache data)
        data))))

(let [input     (json/parse-string (slurp *in*) true)
      week      (grok-weekly)
      week-pct  (when (number? (:pct week)) (:pct week))
      week-eta  (eta-str (:resets week))
      raw-dir   (get-in input [:workspace :current_dir])
      dir       (some-> raw-dir shorten-dir)
      branch    (truncate (get-in input [:workspace :branch]) 20)
      model     (get-in input [:model :display_name])
      effort    (get-in input [:effort :level])
      ctx-pct   (get-in input [:context_window :used_percentage])
      ctx       (when (number? ctx-pct)
                  (str (long (Math/round (double ctx-pct))) "%"))
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
      week-seg  (if week-pct
                  (str "7d: " (pct-str week-pct)
                       (when week-eta (str " (resets " week-eta ")")))
                  "7d: ?")
      parts     (remove nil?
                  [(str user "@" host)
                   (if branch (str dir " (" branch ")") dir)
                   (when model (str model (when effort (str " - " effort))))
                   (when (and effort (not model)) effort)
                   (when ctx (str "ctx: " ctx))
                   week-seg])]
  (print (str/join " | " parts)))
