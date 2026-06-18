#!/usr/bin/env janet

# Weather helper, dispatched by the first CLI argument. A Janet port of
# weather.clj (kept alongside it; callers still point at the .clj for now):
#   weather.janet dunst         desktop notification: current + 3-day + 12h
#   weather.janet dwm           status-bar text  ("18°C Clear M")
#   weather.janet i3            status-bar JSON   ({"text":"18°C Clear"})
#   weather.janet hours [n]     next n hours, ANSI-colored, for a terminal
#   weather.janet hours-dunst [n]  next n hours as a notification (Pango)
#   weather.janet plot          3-day Plotly chart opened in Firefox
#
# JSON comes from spork/json (one-time `jpm install spork`; its native module
# builds fine on OpenBSD, where cc is in base). `utf8-encode` below stays
# hand-rolled — it also renders Nerd Font weather glyphs, not just JSON escapes.

(import spork/json)


### --- UTF-8 ------------------------------------------------------------------

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


### --- shelling out ----------------------------------------------------------

(defn run
  "Run a command vector; return [stdout exit-code]. stderr is swallowed."
  [args]
  (def proc (os/spawn args :p {:out :pipe :err :pipe}))
  (def out (ev/read (proc :out) :all))
  (ev/read (proc :err) :all)
  (def code (os/proc-wait proc))
  [(if out (string out) "") code])

(defn spawn-wait [args]
  (os/proc-wait (os/spawn args :p)))


### --- config ----------------------------------------------------------------

(def home (os/getenv "HOME"))
(def settings-file (string home "/sync/cfg/weather.edn"))
(def weather-codes-file (string home "/sync/cfg/weather-codes.json"))

(each f [settings-file weather-codes-file]
  (unless (os/stat f)
    (eprint "weather.janet: missing config file: " f)
    (os/exit 1)))

# weather.edn uses only EDN syntax that is also valid janet data, so `parse`
# reads it directly (keywords, maps, vectors, strings, numbers).
(def settings (parse (slurp settings-file)))
(def weather-codes (json/decode (slurp weather-codes-file) true))
(def current-place (get-in settings [:locations (settings :curr-loc)]))

(def url "https://api.open-meteo.com/v1/forecast")
(def query-params
  {:latitude (current-place :lat)
   :longitude (current-place :lon)
   :timezone "Europe/Berlin"
   :forecast_days 3
   :models "icon_seamless"
   :daily ["weather_code" "temperature_2m_max" "temperature_2m_min" "apparent_temperature_max" "apparent_temperature_min" "sunrise" "sunset" "daylight_duration" "sunshine_duration" "precipitation_sum" "rain_sum" "showers_sum" "snowfall_sum" "precipitation_hours" "precipitation_probability_max" "wind_speed_10m_max" "wind_gusts_10m_max" "wind_direction_10m_dominant" "shortwave_radiation_sum" "et0_fao_evapotranspiration"]
   :current ["weather_code" "is_day" "temperature_2m" "precipitation" "rain" "cloud_cover" "precipitation_probability"]
   :hourly ["weather_code" "temperature_2m" "precipitation_probability" "precipitation" "cloud_cover" "is_day"]})


### --- request ---------------------------------------------------------------

(defn make-request [base params]
  # -G + --data-urlencode: curl builds and escapes the query string; -f makes
  # an HTTP error a nonzero exit, replacing the explicit status==200 check.
  (def args @["curl" "-sfG" base])
  (eachp [k v] params
    (def vs (if (indexed? v) (string/join (map string v) ",") (string v)))
    (array/push args "--data-urlencode" (string k "=" vs)))
  (def [body code] (run args))
  (if (= 0 code) body (os/exit 1)))

(defn download-icon [icon-url path]
  (spawn-wait ["curl" "-sLfo" path icon-url]))

(defn notify [title body]
  # separate args (not a shell string) -> robust quoting; body is one arg, so a
  # leading "-3°C" can't be parsed as a flag.
  (spawn-wait ["notify-send" "--app-name" "dunst-weather"
               "--icon" (settings :icon-path) title body]))


### --- weather codes ---------------------------------------------------------

(defn code-field [code day? field]
  (get-in weather-codes [(keyword (string code)) (if day? :day :night) field]))

(defn code-desc [code day?] (code-field code day? :description))
(defn code-img  [code day?] (code-field code day? :image))


### --- formatting helpers ----------------------------------------------------

(defn format-number
  "Format a number to a whole-number string, normalizing -0 to 0."
  [num]
  (def f (string/format "%.0f" (* 1.0 num)))
  (if (= f "-0") "0" f))

(defn extract-time [dt] (last (string/split "T" dt)))

(defn sun-rise-set [today tomorrow]
  (string/format "↓%s ↑%s"
                 (extract-time (today :sunset))
                 (extract-time (tomorrow :sunrise))))

(defn parse-day [d i]
  {:dt (in (d :time) i)
   :sunrise (in (d :sunrise) i)
   :sunset (in (d :sunset) i)
   :weather-code (in (d :weather_code) i)
   :temp-min (format-number (in (d :temperature_2m_min) i))
   :temp-max (format-number (in (d :temperature_2m_max) i))
   :sunshine-duration (in (d :sunshine_duration) i)
   :wind_gusts_10m_max (in (d :wind_gusts_10m_max) i)
   :wind_speed_10m_max (in (d :wind_speed_10m_max) i)
   :precipitation-sum (in (d :precipitation_sum) i)})

(defn fmt [day]
  (string/format "%2d %2d %s .. %.0f/%.0f km/h"
                 (scan-number (day :temp-min))
                 (scan-number (day :temp-max))
                 (code-desc (day :weather-code) true)
                 (day :wind_speed_10m_max)
                 (day :wind_gusts_10m_max)))


### --- hourly view -----------------------------------------------------------

(def weather-glyph
  # WMO weather code -> Nerd Font Weather Icon codepoint (day/night). These live
  # inside Hack Nerd Font (U+E300-E3E3) with a fixed in-font advance, so they
  # stay column-aligned in both foot and dunst.
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
  # U+E374 = nf-weather-na, the fallback for any code not in the map.
  (utf8-encode (get-in weather-glyph [code (if day? :day :night)] 0xe374)))

(defn code-color
  "WMO weather code -> RGB hex for the glyph, grouped by condition family."
  [code]
  (cond
    (index-of code [0 1])                        "#f9d71c"  # clear        - gold
    (index-of code [2 3])                        "#9aa0a6"  # cloudy       - grey
    (index-of code [45 48])                      "#b0b0b0"  # fog          - pale grey
    (index-of code [56 57 66 67])                "#7fd4d4"  # freezing     - icy cyan
    (index-of code [51 53 55 61 63 65 80 81 82]) "#5a9bd4"  # rain         - blue
    (index-of code [71 73 75 77 85 86])          "#cfe8ff"  # snow         - pale blue
    (index-of code [95 96 99])                   "#b08cff"  # thunderstorm - violet
    "#cccccc"))

(defn current-hour-index
  "Index into the :hourly arrays for the current local hour. open-meteo returns
  :current :time already in the location's timezone, so match it (truncated to
  the hour) against the hourly :time strings."
  [data]
  (def t0 (get-in data [:current :time]))
  (def now-hr (when t0 (string/slice t0 0 13)))
  (def times (get-in data [:hourly :time]))
  (or (and now-hr (find-index |(= (string/slice $ 0 13) now-hr) times))
      (and now-hr (find-index |(>= (compare (string/slice $ 0 13) now-hr) 0) times))
      0))

(defn hour-rows
  "Up to n per-hour maps starting at the current hour."
  [data n]
  (def h (data :hourly))
  (def times (h :time))
  (def start (current-hour-index data))
  (def end (min (+ start n) (length times)))
  (seq [i :range [start end]]
    {:hh     (string/slice (in times i) 11 16)
     :glyph  (code-glyph (in (h :weather_code) i) (pos? (or (in (h :is_day) i) 1)))
     :color  (code-color (in (h :weather_code) i))
     :temp   (when-let [t (in (h :temperature_2m) i)] (format-number t))
     :pop    (in (h :precipitation_probability) i)
     :precip (in (h :precipitation) i)
     :cloud  (in (h :cloud_cover) i)}))

(defn hex->rgb [hex]
  (def h (string/slice hex 1))
  [(scan-number (string "0x" (string/slice h 0 2)))
   (scan-number (string "0x" (string/slice h 2 4)))
   (scan-number (string "0x" (string/slice h 4 6)))])

(defn colorize
  "Wrap the glyph in a zero-width color escape: ANSI truecolor for foot, a Pango
  <span> for dunst (markup=full). Both are zero-width, so alignment holds."
  [glyph hex target]
  (case target
    :ansi  (let [[r g b] (hex->rgb hex)]
             (string/format "\x1b[38;2;%d;%d;%dm%s\x1b[0m" r g b glyph))
    :pango (string/format "<span foreground='%s'>%s</span>" hex glyph)
    glyph))

(defn- fmt-pct [v] (if v (string/format "%3d%%" v) "  --"))

(defn render-hour-line
  "Render one hour row. `target` selects the glyph color syntax: :ansi (foot),
  :pango (dunst), or nil (plain). Glyph right after the hour (icon-first scans
  fastest)."
  [row target]
  (def {:hh hh :glyph glyph :color color :temp temp :pop pop :precip precip :cloud cloud} row)
  (def base (string/format "%s %s %3s°C  %s PoP  %s cld"
                           hh (colorize glyph color target) (or temp "--") (fmt-pct pop) (fmt-pct cloud)))
  (if (and precip (pos? precip))
    (string base (string/format "  %.1fmm" precip))
    base))


### --- actions ---------------------------------------------------------------

(defn forecast [data]
  (def curr (data :current))
  (def curr-temp (format-number (curr :temperature_2m)))
  (def day? (not= 0 (curr :is_day)))
  (def curr-desc (code-desc (curr :weather_code) day?))
  (def prec-prob (or (curr :precipitation_probability) 0))
  (def curr-icon (code-img (curr :weather_code) day?))
  (def daily (data :daily))
  (def today   (parse-day daily 0))
  (def today+1 (parse-day daily 1))
  (def today+2 (parse-day daily 2))
  (def hourly-lines (string/join (map |(render-hour-line $ :pango) (hour-rows data 12)) "\n"))
  (def title (string/format "Weather in %s" (current-place :long)))
  (def body (string/format
              (string "   %s°C  %s  --  %d%% PoP\n\n%s\n\n"
                      "today:     %s\ntomorrow:  %s\nday after: %s\n\n%s")
              curr-temp curr-desc prec-prob
              (sun-rise-set today today+1)
              (fmt today) (fmt today+1) (fmt today+2)
              hourly-lines))
  (download-icon curr-icon (settings :icon-path))
  (notify title body))

(defn hours-cli [data n]
  (print (string/format "Weather in %s — next %dh" (current-place :long) n))
  (each row (hour-rows data n)
    (print (render-hour-line row :ansi))))

(defn hours-dunst [data n]
  (def curr (data :current))
  (def day? (pos? (or (curr :is_day) 1)))
  (def icon (code-img (curr :weather_code) day?))
  (def title (string/format "Next %dh — %s" n (current-place :long)))
  (def body (string/join (map |(render-hour-line $ :pango) (hour-rows data n)) "\n"))
  (download-icon icon (settings :icon-path))
  (notify title body))

(defn print-for-i3bar-short [status curr-temp curr-desc]
  (if (= 200 status)
    (string/format "%s°C %s" curr-temp curr-desc)
    (string/format "Request Error: status code %d" status)))

(defn dwmblocks [data wm]
  (def location (current-place :shortkw))
  (def curr (data :current))
  (def day? (not= 0 (curr :is_day)))
  (def curr-temp (format-number (curr :temperature_2m)))
  (def curr-desc (code-desc (curr :weather_code) day?))
  (def weather (print-for-i3bar-short 200 curr-temp curr-desc))
  (case wm
    "dwm" (string/format "%s %s" weather location)
    "i3"  (json/encode {:text (string/format "%s°C %s" curr-temp curr-desc)})))


### --- plot ------------------------------------------------------------------

(defn sunshine-hrs [data]
  (map |(scan-number (string/format "%.1f" (/ $ 3600)))
       (get-in data [:daily :sunshine_duration])))

(defn html-template
  "A static HTML page hosting a Plotly plot."
  [w h plot-data]
  (string
    "<!DOCTYPE html>\n<html>\n<head>\n<title>Wetterplot.clj</title>\n"
    "<script src=\"file:///home/ax/sync/libs/plotly-3.3.0.min.js\" charset=\"utf-8\"></script>\n"
    "</head>\n<body>\n"
    (string/format "<div id=\"plotly-div\" style=\"width:%dpx;height:%dpx;\"></div>\n" w h)
    "<script>const plotData = " (json/encode plot-data) ";"
    "Plotly.newPlot('plotly-div', plotData.data, plotData.layout);</script>\n"
    "</body>\n</html>"))

(defn plot-next-3-days [data]
  # https://plotly.com/javascript/multiple-axes/
  (def hourly (data :hourly))
  (def times (hourly :time))
  (def prec  (hourly :precipitation))
  (def temp {:x times :y (hourly :temperature_2m)
             :type "scatter" :mode "lines" :yaxis "y"
             :marker {:color "orange"} :text times :name "Temperatur"})
  (def precp {:x times :y prec :yaxis "y2" :type "bar"
              :marker {:color "blue"} :name "Niederschlag"})
  (def precprob {:x times :y (hourly :precipitation_probability)
                 :yaxis "y3" :type "scatter" :mode "lines"
                 :marker {:color "blue"} :name "Niederschlagswahrsch."})
  (def width 1600)
  (def height 700)
  (def plot-data
    {:data [temp precp precprob]
     :layout {:title {:text (string/format "Wetter in %s: 3-Tage-Vorschau" (current-place :long))}
              :width width
              :height height
              :xaxis {:type "date" :domain [0 0.9]}
              :yaxis {:title {:text "Temperatur [°C]"}}
              :yaxis2 {:title {:text "Niederschlag [mm]"}
                       :overlaying "y" :side "right" :anchor "x"
                       :range [0 (inc (max ;prec))]}
              :yaxis3 {:title {:text "Niederschlagswahrsch."}
                       :overlaying "y" :side "right" :anchor "free"
                       :position 0.95 :range [0 100]}}})
  (def filename "/tmp/plotly-weather-chart.html")
  (spit filename (html-template width height plot-data))
  (print "Plot saved to " filename ", opening in Firefox...")
  (spawn-wait ["firefox" filename]))


### --- dispatch --------------------------------------------------------------

(def actions
  {"dunst"       (fn [data _] (forecast data))
   "dwm"         (fn [data _] (print (dwmblocks data "dwm")))
   "i3"          (fn [data _] (print (dwmblocks data "i3")))
   "plot"        (fn [data _] (plot-next-3-days data))
   "hours"       (fn [data n] (hours-cli data n))
   "hours-dunst" (fn [data n] (hours-dunst data n))})

(defn main [& args]
  (def action (get args 1))
  (def n (or (and (> (length args) 2) (scan-number (in args 2))) 12))
  (def handler (get actions action))
  (if-not handler
    (do (eprint (string/format "usage: weather.janet {%s} [n]"
                               (string/join (sorted (keys actions)) "|")))
        (os/exit 1))
    (handler (json/decode (make-request url query-params) true true) n)))
