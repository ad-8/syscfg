#!/usr/bin/env bb

(ns weather
  (:require [clojure.string :as str]
            [babashka.process :refer [shell]]
            [clojure.java.io :as io]
            [babashka.fs :as fs]
            [babashka.cli :as cli]
            [clojure.test :refer :all]
            [babashka.http-client :as http]
            [cheshire.core :as json]
            [clojure.edn :as edn]
            [clojure.walk :refer [keywordize-keys]]
            [hiccup2.core :as h]))



(def settings-file (io/file (System/getProperty "user.home") "sync" "cfg" "weather.edn"))
(def weather-codes-file (io/file (System/getProperty "user.home") "sync" "cfg" "weather-codes.json"))

(doseq [f [settings-file weather-codes-file]]
  (when-not (.exists f)
    (println "weather.clj: missing config file:" (str f))
    (System/exit 1)))

(def weather-codes (-> weather-codes-file slurp json/decode clojure.walk/keywordize-keys))
(def settings (-> settings-file slurp edn/read-string))
(def current-place (get-in settings [:locations (:curr-loc settings)]))


(def url "https://api.open-meteo.com/v1/forecast"),
(def query-params {:latitude (:lat current-place)
                   :longitude (:lon current-place)
                   :timezone "Europe/Berlin"
                   :forecast_days 3
                   :models "icon_seamless"
                   ;; all checkboxes checked for :daily
                   :daily ["weather_code", "temperature_2m_max", "temperature_2m_min", "apparent_temperature_max", "apparent_temperature_min", "sunrise", "sunset", "daylight_duration", "sunshine_duration", "precipitation_sum", "rain_sum", "showers_sum", "snowfall_sum", "precipitation_hours", "precipitation_probability_max", "wind_speed_10m_max", "wind_gusts_10m_max", "wind_direction_10m_dominant", "shortwave_radiation_sum", "et0_fao_evapotranspiration"]
                   ;; Every weather variable available in hourly data, is available as current condition as well.
                   :current ["weather_code" "is_day" "temperature_2m", "precipitation", "rain", "cloud_cover", "precipitation_probability"]
                   :hourly ["weather_code", "temperature_2m", "precipitation_probability", "precipitation", "cloud_cover", "is_day"]})


(defn make-request [url query-params]
  (let [params {:query-params query-params}
        resp (try (http/get url params)
                  (catch Exception e (println (.getMessage e))))]
    (if (= 200 (:status resp))
      resp
      (System/exit 1))))


(defn sunshine_hrs [data]
  (->> data :daily :sunshine_duration
       (map #(/ % 3600))
       (map #(format "%.1f" %))
       (map #(Double/parseDouble %))))


(defn format-number
  "Sometimes the temperature from the API is an even number like 4,
  which, when formatted with the format string used below, throws an exception
  when used with an integer, so we need to explicitly parse to a float"
  [num]
  (let [fmt (format "%.0f" (float num))]
    (if (= "-0" fmt) 
      "0" 
      fmt)))


(defn parse-day [daily-data i]
  {:dt (nth (:time daily-data) i)
   :sunrise (nth (:sunrise daily-data) i)
   :sunset (nth (:sunset daily-data) i)
   :weather-code (nth (:weather_code daily-data) i)
   :temp-min (format-number (nth (:temperature_2m_min daily-data) i))
   :temp-max (format-number (nth (:temperature_2m_max daily-data) i))
   :sunshine-duration (nth (:sunshine_duration daily-data) i)
   :wind_gusts_10m_max (nth (:wind_gusts_10m_max daily-data) i)
   :wind_speed_10m_max (nth (:wind_speed_10m_max daily-data) i)
   :precipitation-sum (nth (:precipitation_sum daily-data) i)})


(defn download-icon [url filename]
  (io/copy
   (:body (http/get url {:as :stream}))
   (io/file filename)))


(defn find-code [code]
  (let [code (-> code str keyword)]
    (-> (filter #(= code (first %)) weather-codes) first)))


(defn code-desc [code day?]
  (if day?
    (-> (find-code code) second :day :description)
    (-> (find-code code) second :night :description)))

(comment

(type weather-codes)
(code-desc 63 3)

  (find-code 71)

(clojure.pprint/pprint weather-codes)
(take 3 weather-codes)
(keys weather-codes)
(vals weather-codes)

(for)

;;
)


(defn code-img [code day?]
  (if day?
    (-> (find-code code) second :day :image)
    (-> (find-code code) second :night :image)))


(defn extract-time [dt]
  (-> dt (str/split #"T") last))


(defn sun-rise-set [today tomorrow]
  (let [sunset  (-> today :sunset extract-time)
        sunrise (-> tomorrow :sunrise extract-time)]
    (format "↓%s ↑%s" sunset sunrise)))


(defn fmt [day]
  (format "%2d %2d %s .. %.0f/%.0f km/h"
          (Integer/parseInt (:temp-min day))
          (Integer/parseInt (:temp-max day))
          (code-desc (:weather-code day) true)
          (:wind_speed_10m_max day)
          (:wind_gusts_10m_max day)))


(declare hour-rows render-hour-line)

(defn forecast [data]
  (let [curr (:current data)
        curr-temp (-> curr :temperature_2m format-number)
        day? (if (= 0 (:is_day curr)) false true)
        curr-desc (code-desc (:weather_code curr) day?)
        prec-prob (or (:precipitation_probability curr) 0)
        curr-icon (code-img (:weather_code curr) day?)
        daily-data (:daily data)
        today   (parse-day daily-data 0)
        today+1 (parse-day daily-data 1)
        today+2 (parse-day daily-data 2)
        hourly-lines (->> (hour-rows data 12) (map #(render-hour-line % :pango)) (str/join "\n"))
        title (format "Weather in %s" (:long current-place))
        body  (format "   %s°C  %s  --  %s%% PoP\n\n%s\n\ntoday:     %s\ntomorrow:  %s\nday after: %s\n\n%s"
                      curr-temp curr-desc prec-prob
                      (sun-rise-set today today+1)
                      (fmt today)
                      (fmt today+1) (fmt today+2)
                      hourly-lines)]

    (download-icon curr-icon (:icon-path settings))
    ;; separate-args notify-send (not a shell string) -> robust quoting; the
    ;; body is a single arg, so a leading "-3°C" can't be parsed as a flag.
    (shell "notify-send" "--app-name" "dunst-weather"
           "--icon" (:icon-path settings) title body)))


;; --- hourly "next few hours" view (CLI + dunst) ------------------------------

(def weather-glyph
  "WMO weather code -> Nerd Font Weather Icon codepoint (day/night variant).
  These glyphs live inside Hack Nerd Font itself (range U+E300-E3E3), so unlike
  color emoji they have a fixed in-font advance and stay column-aligned in both
  foot and dunst — no fallback font, no padding hacks needed."
  {0  {:day 0xe30d :night 0xe32b}   1  {:day 0xe30c :night 0xe37e}
   2  {:day 0xe302 :night 0xe379}   3  {:day 0xe312 :night 0xe312}
   45 {:day 0xe303 :night 0xe313}   48 {:day 0xe313 :night 0xe313}
   51 {:day 0xe309 :night 0xe319}   53 {:day 0xe309 :night 0xe319}   55 {:day 0xe309 :night 0xe319}
   56 {:day 0xe3ad :night 0xe3ad}   57 {:day 0xe3ad :night 0xe3ad}
   61 {:day 0xe308 :night 0xe318}   63 {:day 0xe308 :night 0xe318}   65 {:day 0xe308 :night 0xe318}
   66 {:day 0xe3ad :night 0xe3ad}   67 {:day 0xe3ad :night 0xe3ad}
   71 {:day 0xe30a :night 0xe31a}   73 {:day 0xe30a :night 0xe31a}   75 {:day 0xe30a :night 0xe31a}
   77 {:day 0xe30a :night 0xe31a}
   80 {:day 0xe309 :night 0xe319}   81 {:day 0xe308 :night 0xe318}   82 {:day 0xe308 :night 0xe318}
   85 {:day 0xe30a :night 0xe31a}   86 {:day 0xe30a :night 0xe31a}
   95 {:day 0xe30f :night 0xe31d}   96 {:day 0xe30f :night 0xe31d}   99 {:day 0xe30f :night 0xe31d}})

(defn code-glyph [code day?]
  ;; U+E374 = nf-weather-na, the fallback for any code not in the map.
  (let [cp (get-in weather-glyph [code (if day? :day :night)] 0xe374)]
    (str (char cp))))

(defn code-color
  "WMO weather code -> RGB hex for the glyph, grouped by condition family.
  Applied as a zero-width color wrapper (ANSI for foot, Pango span for dunst),
  so it restores color without disturbing column alignment."
  [code]
  (cond
    (#{0 1} code)                        "#f9d71c"  ;; clear        - gold
    (#{2 3} code)                        "#9aa0a6"  ;; cloudy       - grey
    (#{45 48} code)                      "#b0b0b0"  ;; fog          - pale grey
    (#{56 57 66 67} code)                "#7fd4d4"  ;; freezing     - icy cyan
    (#{51 53 55 61 63 65 80 81 82} code) "#5a9bd4"  ;; rain         - blue
    (#{71 73 75 77 85 86} code)          "#cfe8ff"  ;; snow         - pale blue
    (#{95 96 99} code)                   "#b08cff"  ;; thunderstorm - violet
    :else                                "#cccccc"))

(defn current-hour-index
  "Index into the :hourly arrays for the current local hour. open-meteo returns
  :current :time already in the location's timezone, so no tz math is needed —
  match it (truncated to the hour) against the hourly :time strings."
  [data]
  ;; a partial/degraded 200 response can omit :current :time; fall back to the
  ;; start of the window rather than NPE on subs of nil.
  (let [t0     (get-in data [:current :time])
        now-hr (when t0 (subs t0 0 13))
        times  (-> data :hourly :time)]
    (or (when now-hr (->> times (keep-indexed (fn [i t] (when (= (subs t 0 13) now-hr) i))) first))
        (when now-hr (->> times (keep-indexed (fn [i t] (when (>= (compare (subs t 0 13) now-hr) 0) i))) first))
        0)))

(defn hour-rows
  "Up to n per-hour maps starting at the current hour."
  [data n]
  (let [h     (:hourly data)
        times (:time h)
        start (current-hour-index data)
        end   (min (+ start n) (count times))]
    (for [i (range start end)]
      {:hh     (subs (nth times i) 11 16)
       :glyph  (code-glyph (nth (:weather_code h) i) (pos? (or (nth (:is_day h) i) 1)))
       :color  (code-color (nth (:weather_code h) i))
       :temp   (some-> (nth (:temperature_2m h) i) format-number)
       :pop    (nth (:precipitation_probability h) i)
       :precip (nth (:precipitation h) i)
       :cloud  (nth (:cloud_cover h) i)})))

(defn- hex->rgb [hex]
  (let [h (subs hex 1)]
    (mapv #(Integer/parseInt (subs h % (+ % 2)) 16) [0 2 4])))

(defn- colorize
  "Wrap the glyph in a zero-width color escape for the given target: an ANSI
  truecolor SGR for foot, a Pango <span> for dunst (markup = full)."
  [glyph hex target]
  (case target
    :ansi  (let [[r g b] (hex->rgb hex)]
             (format "\u001b[38;2;%d;%d;%dm%s\u001b[0m" r g b glyph))
    :pango (format "<span foreground='%s'>%s</span>" hex glyph)
    glyph))

(defn- fmt-pct [v] (if v (format "%3d%%" v) "  --"))

(defn render-hour-line
  "Render one hour row. `target` selects the glyph color syntax: :ansi (foot),
  :pango (dunst), or nil (plain). Color wrappers are zero-width, so alignment
  holds regardless — the Nerd Font glyphs have a fixed in-font advance."
  [{:keys [hh glyph color temp pop precip cloud]} target]
  ;; glyph right after the hour (icon-first scans fastest).
  (str (format "%s %s %3s°C  %s PoP  %s cld" hh (colorize glyph color target) (or temp "--") (fmt-pct pop) (fmt-pct cloud))
       (when (and precip (pos? precip)) (format "  %.1fmm" precip))))

(defn hours-cli [data n]
  (println (format "Weather in %s — next %dh" (:long current-place) n))
  (doseq [row (hour-rows data n)]
    (println (render-hour-line row :ansi)))
  nil)

(defn hours-dunst [data n]
  (let [curr  (:current data)
        day?  (pos? (or (:is_day curr) 1))
        icon  (code-img (:weather_code curr) day?)
        title (format "Next %dh — %s" n (:long current-place))
        body  (->> (hour-rows data n) (map #(render-hour-line % :pango)) (str/join "\n"))]
    (download-icon icon (:icon-path settings))
    ;; separate-args notify-send (not a shell string) -> robust quoting.
    (shell "notify-send" "--app-name" "dunst-weather"
           "--icon" (:icon-path settings) title body)
    nil))

;; --- end hourly view ---------------------------------------------------------


(defn print-for-i3bar-short [status curr-temp curr-desc]
  (if (= 200 status)
    (format "%s°C %s" curr-temp curr-desc)
    (format "Request Error: status code %d" status)))


(defn dwmblocks [data wm]
  (let [location (:shortkw current-place)
        curr (:current data)
        day? (if (= 0 (:is_day curr)) false true)
        curr-temp (-> curr :temperature_2m format-number)
        curr-desc (code-desc (:weather_code curr) day?)
        weather (print-for-i3bar-short 200 curr-temp curr-desc)
        fmt (case wm
              "dwm" (format "%s %s" weather location)
              "i3" (json/encode {:text (format "%s°C %s" curr-temp curr-desc)}))]
    fmt))


(defn html-template
  "Creates a simple HTML template for a website with a Plotly plot."
  [div-width div-height plot-data]
  (h/html (h/raw "<!DOCTYPE html>")
          [:html
           [:head
            [:title "Wetterplot.clj"]
            [:script {:src "file:///home/ax/sync/libs/plotly-3.3.0.min.js"
                      :charset "utf-8"}]]
           [:body
            [:div {:id "plotly-div"
                   :style (str "width:" div-width "px;height:" div-height "px;")}]
            [:script (h/raw "const plotData = " (json/encode plot-data) ";"
                            "Plotly.newPlot('plotly-div', plotData.data, plotData.layout);")]]]))

(defn plot-next-3-days [data]
  ;; https://plotly.com/javascript/multiple-axes/
  (let [outmap {:time (-> data :hourly :time)
                :temp (-> data :hourly :temperature_2m)
                :prec (-> data :hourly :precipitation)
                :prec_prob (-> data :hourly :precipitation_probability)
                :sunshine_hrs (flatten (map (fn [x] (repeat 24 x)) (sunshine_hrs data)))
                :loc (:long current-place)}
        temp {:x (:time outmap)
              :y (:temp outmap)
              :type "scatter"
              :mode "lines"
              :yaxis "y"
              :marker {:color :orange}
              :text (:time outmap)
              :name "Temperatur"}
        prec {:x (:time outmap)
              :y (:prec outmap)
              :yaxis "y2"
              :type "bar"
              :marker {:color :blue}
              :name "Niederschlag"}
        precprob {:x (:time outmap)
              :y (:prec_prob outmap)
              :yaxis "y3"
              :type "scatter"
              :mode "lines"
              :marker {:color :blue}
              :name "Niederschlagswahrsch."}
        width 1600
        height 700
        plot-data {:data [temp prec precprob]
                   :layout {:title {:text (format "Wetter in %s: 3-Tage-Vorschau" (:long current-place))}
                            :width width
                            :height height
                            :xaxis {;:title {:text "DateTime"} 
                                    :type "date"
                                    :domain [0 0.9]
                                   ; :tickformat "%a %d.%m"
                                    }
;                            :dtick (* 3 60 60 1000)
                            :yaxis {:title {:text "Temperatur [°C]"}
                                   ; :color :red
                                    }
                            :yaxis2 {:title {:text "Niederschlag [mm]"}
                                     :overlaying "y"
                                     :side :right
                                     :anchor :x
                                     :range [0 (inc (apply max (:prec outmap)))]} 
                            :yaxis3 {:title {:text "Niederschlagswahrsch."}
                                     :overlaying "y"
                                     :side :right
                                     :anchor :free
                                     :position 0.95
                                     :range [0 100]}
                            }}
        filename "/tmp/plotly-weather-chart.html"
        html-template (html-template width height plot-data)]

    (spit filename html-template)
    (println "Plot saved to" filename ", opening in Firefox...")
    (shell {:out :inherit} (format "firefox %s" filename))))


(def actions #{"dunst" "dwm" "i3" "plot" "hours" "hours-dunst"})

(let [action (first *command-line-args*)
      n      (or (some-> (second *command-line-args*) parse-long) 12)]
  (if-not (actions action)
    (binding [*out* *err*]
      (println (format "usage: weather.clj {%s} [n]" (str/join "|" (sort actions))))
      (System/exit 1))
    (let [data (-> (make-request url query-params) :body json/decode keywordize-keys)
          out  (case action
                 "dunst" (forecast data)
                 "dwm" (dwmblocks data "dwm")
                 "i3" (dwmblocks data "i3")
                 "plot" (plot-next-3-days data)
                 "hours" (hours-cli data n)
                 "hours-dunst" (hours-dunst data n))]
      ;; only print string results (dwm/i3); dunst/plot/hours* self-output.
      ;; also avoids printing forecast/plot's process-map (was a noise LOW).
      (when (string? out) (println out)))))


(comment 
  (def res (make-request url query-params))
  (def data (->> res
                 :body
                 json/decode
                 keywordize-keys))

  data
  (keys data)
  (get data :daily)
  (sort (get data :daily_units))
  (:current data)
  (:current_units data)

  (try (forecast data)
       (catch Exception e (str "error: " (.getMessage e))))

  (dwmblocks data "dwm")

  (try
    (/ 1 0)
    (catch Exception e (str "caught exception: " (.getMessage e))))

  )


(comment
  ;; better safe than sorry :)
  (def daily-data-for-test
    {:sunset ["2024-09-12T19:32" "2024-09-13T19:30" "2024-09-14T19:28"],
     :precipitation_hours [9.0 22.0 24.0],
     :wind_direction_10m_dominant [225 320 279],
     :daylight_duration [45907.84 45700.86 45493.08],
     :showers_sum [0.0 0.4 0.3],
     :snowfall_sum [0.0 0.0 0.0],
     :et0_fao_evapotranspiration [1.09 0.8 0.57],
     :precipitation_sum [5.5 16.1 57.6],
     :time ["2024-09-12" "2024-09-13" "2024-09-14"],
     :weather_code [61 61 63],
     :sunrise ["2024-09-12T06:47" "2024-09-13T06:48" "2024-09-14T06:50"],
     :sunshine_duration [0.0 0.0 0.0],
     :wind_gusts_10m_max [22.0 36.7 42.1],
     :shortwave_radiation_sum [6.29 4.18 1.87],
     :rain_sum [5.5 15.4 57.0],
     :apparent_temperature_min [4.4 4.8 1.7],
     :apparent_temperature_max [9.9 7.1 5.2],
     :wind_speed_10m_max [9.7 12.4 18.0],
     :temperature_2m_max [11.4 9.9 7.7],
     :precipitation_probability_max [100 100 100],
     :temperature_2m_min [6.9 6.6 5.7]})

  (deftest test-parse-day
    (are
     [input i expected]
     (= expected (parse-day input i))
      daily-data-for-test 0 {:dt "2024-09-12",
                             :sunrise "2024-09-12T06:47",
                             :sunset "2024-09-12T19:32",
                             :weather-code 61,
                             :temp-min "7",
                             :temp-max "11",
                             :sunshine-duration 0.0,
                             :precipitation-sum 5.5
                             :wind_gusts_10m_max 22.0
                             :wind_speed_10m_max 9.7}
      daily-data-for-test 1 {:dt "2024-09-13",
                             :sunrise "2024-09-13T06:48",
                             :sunset "2024-09-13T19:30",
                             :weather-code 61,
                             :temp-min "7",
                             :temp-max "10",
                             :sunshine-duration 0.0,
                             :precipitation-sum 16.1
                             :wind_gusts_10m_max 36.7
                             :wind_speed_10m_max 12.4}
      daily-data-for-test 2 {:dt "2024-09-14",
                             :sunrise "2024-09-14T06:50",
                             :sunset "2024-09-14T19:28",
                             :weather-code 63,
                             :temp-min "6",
                             :temp-max "8",
                             :sunshine-duration 0.0,
                             :precipitation-sum 57.6
                             :wind_gusts_10m_max 42.1
                             :wind_speed_10m_max 18.0}))

  (run-tests)
  ;;
  )


(comment

  (def data (->> (make-request url query-params)
                 :body
                 json/decode
                 keywordize-keys))
  (keys data)
  (:current_units data)
  (:hourly_units data)

  (:current data)
  data
  (keys (:hourly data))
  (:daily data)
  (forecast data)

  (def daily (:daily data))
  (def hourly (:hourly data))

  (->> (keys daily) sort)
  (into (sorted-map) daily)
  (into (sorted-map) (:daily_units data))

  (parse-day daily 1)
  (:precipitation_hours daily)

  (into (sorted-map) daily)

  (partition 8 (interleave
                (-> data :daily :time)
                (-> data :daily :sunrise)
                (-> data :daily :sunset)
                (-> data :daily :weather_code)
                (:temperature_2m_min daily)
                (:temperature_2m_max daily)
                (:sunshine_duration daily)
                (:precipitation_sum daily)))


  :hourly ["weather_code", "temperature_2m", "precipitation_probability", "precipitation", "cloud_cover"]
  (partition 6 (interleave
                (-> data :hourly :time)
                (-> data :hourly :weather_code)
                (:temperature_2m hourly)
                (:precipitation hourly)
                (:precipitation_probability hourly)
                (:cloud_cover hourly)))
  ;;
  )
