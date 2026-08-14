#!/usr/bin/env janet

# escapes because literal glyphs get eaten when an llm edits this file.
# UTF-8 bytes, not codepoints: janet has no \u. :disk (U+F02CA) and :ram
# (U+F035B) sit outside the BMP, so they take four bytes each.
(def icons
  {:licht    "\xef\x83\xab"
   :load     "\xef\x8b\x9b"
   :vol      "\xef\x80\xa8"
   :vol-mute "\xee\xbb\xa8"
   :disk     "\xf3\xb0\x8b\x8a"
   :ram      "\xf3\xb0\x8d\x9b"
   :vpn      "\xef\x80\xa3"
   :cal      "\xef\x81\xb3"
   :clock    "\xef\x80\x97"})

(def sep " \xe2\x80\xa2 ")
(def ellipsis "\xe2\x80\xa6")
(def weekdays-de ["So" "Mo" "Di" "Mi" "Do" "Fr" "Sa"])

(def scripts "/home/ax/syscfg/scripts")
(def runtime-dir (or (os/getenv "XDG_RUNTIME_DIR") "/tmp"))
(def weather-cache (string runtime-dir "/kwm-weather"))
(def weather-script (string scripts "/bb/weather.clj"))
# three missed 600s fetches; past this the reading is too old to trust
(def weather-max-age 1800)

(def supported-players {"strawberry" true "fooyin" true "emms" true})
(def music-width 35)
(def tick-secs 2)

# kwm's status buffer is 256 bytes and only gets terminated when the read comes
# up short, so a line filling it exactly is read past the end (bar.zig:29).
(def line-max-bytes 254)
(def over-marker "!TOO LONG!")


### --- helpers ---------------------------------------------------------------

# both lifted from spork/sh.janet (MIT, (c) 2022 Calvin Rose): pipes read via
# ev/gather (no deadlock), process wrapped in `with` for fd cleanup.

(defn sh
  ``Run args; return {:out <trimmed stdout> :status <exit code>}. Stderr is
  left on the terminal, matching the clj's `:err :inherit`.``
  [& args]
  (with [proc (os/spawn args :p {:out :pipe})]
    (let [[out status] (ev/gather
                         (ev/read (proc :out) :all)
                         (os/proc-wait proc))]
      {:out (if out (string/trimr out) "") :status status})))

(defn sh-quiet
  "sh, with stderr swallowed."
  [& args]
  (with [proc (os/spawn args :p {:out :pipe :err :pipe})]
    (let [[out _ status] (ev/gather
                           (ev/read (proc :out) :all)
                           (ev/read (proc :err) :all)
                           (os/proc-wait proc))]
      {:out (if out (string/trimr out) "") :status status})))

(defn blank? [s] (or (nil? s) (empty? (string/trim s))))

(def word-peg (peg/compile ~(any (+ (<- (some :S)) 1))))
(defn words [s] (peg/match word-peg s))

(defn first-line
  "First line of path, or nil when the file does not exist."
  [path]
  (when (os/stat path :mode)
    (first (string/split "\n" (slurp path)))))

(defn cp-count
  "Code points in a UTF-8 string, i.e. bytes that are not continuation bytes."
  [s]
  (count |(not= 0x80 (band $ 0xC0)) s))

(defn cp-offset
  "Byte offset of code point n, so a cut there never splits a glyph."
  [s n]
  (var seen 0)
  (or (find-index |(and (not= 0x80 (band $ 0xC0)) (> (++ seen) n)) s)
      (length s)))

(defn truncate
  "Cut to n code points, ellipsis if cut."
  [s n]
  (if (<= (cp-count s) n)
    s
    (string (string/slice s 0 (cp-offset s (dec n))) ellipsis)))


### --- fields ----------------------------------------------------------------

(defn music
  ``Playing track as N. Title, prefixed PAUSED when paused. Blank when nothing
  is playing or the player is not one of ours.``
  []
  # playerctl is optional: missing means no field, not a dead loop
  (def {:out out :status status}
    (try
      (sh-quiet "playerctl" "metadata" "--format"
                "{{playerName}}|{{status}}|{{xesam:trackNumber}}|{{xesam:title}}")
      ([_] {:out "" :status 1})))
  (def [player state track title] (string/split "|" (string/trim out) 0 4))
  (if (or (pos? status)
          (not (supported-players player))
          (= "Stopped" state)
          (blank? title))
    ""
    (let [base (if (blank? track) title (string track ". " title))]
      (truncate (if (= "Paused" state) (string "PAUSED " base) base)
                music-width))))

# never inline: a slow request would stall the clock too. publish only on
# success -- weather.clj prints its errors to stdout -- and via a temp file so
# a reader cannot catch a half-written cache.
(defn weather-refresh
  ``Fetch the weather into the cache file. Publishes only on success, so a
  failed fetch leaves the last good reading in place.``
  []
  (def {:out out :status status} (sh-quiet "timeout" "30" weather-script "dwm"))
  (def tmp (string weather-cache ".new"))
  (when (and (zero? status) (not (blank? out)))
    (spit tmp out)
    (os/rename tmp weather-cache)))

(defn weather
  "Last cached weather reading, or -- when there is none or it went stale."
  []
  (def age (when-let [m (os/stat weather-cache :modified)] (- (os/time) m)))
  (let [v (when (and age (< age weather-max-age)) (first-line weather-cache))]
    (if (blank? v) "--" v)))

(defn volume
  ``Default sink volume as a percentage, MUTED when muted, -- when pipewire
  does not answer.``
  []
  (def w (words ((sh-quiet "wpctl" "get-volume" "@DEFAULT_AUDIO_SINK@") :out)))
  (def n (when-let [v (get w 1)] (scan-number v)))
  (cond
    (nil? n)                    (string/format "%s  --" (icons :vol))
    (= "[MUTED]" (get w 2))     (string/format "%s  MUTED" (icons :vol-mute))
    (string/format "%s  %.0f%%" (icons :vol) (* n 100))))

(defn licht
  "Screen brightness, from the cache licht.clj writes, or -- when absent."
  []
  (let [v (first-line "/tmp/licht-curr-val")]
    (string/format "%s %s" (icons :licht) (if (blank? v) "--" v))))

(defn load-avg
  "One-minute load average from /proc/loadavg."
  []
  (string/format "%s %s" (icons :load) (first (words (slurp "/proc/loadavg")))))

(defn disk
  "Space available on /, blank when df fails."
  []
  (def out ((sh "df" "-h" "/" "--output=avail") :out))
  (if-let [avail (get (string/split "\n" out) 1)]
    (string/format "%s %s" (icons :disk) (string/trim avail))
    ""))

(defn ram
  "Memory in use as a percentage of total, blank when free fails."
  []
  (def line (find |(string/has-prefix? "Mem:" $)
                  (string/split "\n" ((sh "free" "-m") :out))))
  (def [_ total used] (words (or line "")))
  (if (and total used)
    (string/format "%s %d%%" (icons :ram)
                   (math/floor (* (/ (scan-number used) (scan-number total)) 100)))
    ""))

(defn vpn
  "Active wireguard interfaces, or NO VPN."
  []
  # wg is optional the same way playerctl is: absent reads as no tunnel
  (def {:out out :status status}
    (try (sh-quiet "wg" "show" "interfaces") ([_] {:out "" :status 1})))
  (if (or (pos? status) (blank? out))
    "NO VPN"
    (string/format "%s %s" (icons :vpn) (string/join (words out) " "))))

(defn datetime
  "German weekday, date and time."
  []
  # os/date gives :week-day 0=Sun, and 0-based :month-day/:month
  (def d (os/date (os/time) true))
  (string/format "%s %s %02d.%02d. %s %02d:%02d"
                 (icons :cal) (weekdays-de (d :week-day))
                 (inc (d :month-day)) (inc (d :month))
                 (icons :clock) (d :hours) (d :minutes)))

(defn due?
  ``True when a field refreshing every secs is due on this tick. max 1 so a
  cadence below one tick means every tick rather than dividing by zero.``
  [tick secs]
  (zero? (% tick (max 1 (div secs tick-secs)))))

# bar order, left to right; every field states its own refresh rate in seconds
(def fields
  [{:render music    :secs tick-secs}
   {:render weather  :secs 10}
   {:render volume   :secs tick-secs}
   {:render licht    :secs tick-secs}
   {:render load-avg :secs 6}
   {:render disk     :secs 30}
   {:render ram      :secs 30}
   {:render vpn      :secs 10}
   {:render datetime :secs tick-secs}])

(comment
  # tick -- loop counter, one per tick-secs, so 15 is 30s in
  15

  # cache -- one string per entry in fields, same order and length.
  # glyphs written as <name> here only to keep this file pure ascii
  ["3. Blue Monday"
   "13C Clear sky WHV"
   "<vol> 38%"
   "<licht> 42"
   "<load> 0.31"
   "<disk> 29G"
   "<ram> 28%"
   "<vpn> muc"
   "Mi 12.08.  19:38"]

  # back comes the same shape: fields that are due get re-rendered, the rest
  # carry their previous string through. music is "" when nothing is playing,
  # and the join in the loop drops every blank.
  (refresh 15 (array/new-filled (length fields) "")))

(defn refresh
  "Render every field whose cadence is due on this tick, carry the rest through."
  [tick cache]
  (map (fn [{:render render :secs secs} old]
         (if (due? tick secs) (try (render) ([_] "")) old))
       fields cache))

(defn drop-longest
  "parts without its longest entry."
  [parts]
  (def longest (reduce2 (fn [a b] (if (>= (length b) (length a)) b a)) parts))
  (filter |(not= longest $) parts))

(defn fit
  "Marked line with the longest fields dropped until it fits the budget."
  [parts]
  (def line (string/join [over-marker ;parts] sep))
  (if (<= (length line) line-max-bytes)
    line
    (fit (drop-longest parts))))

(defn compose
  ``Join the non-blank fields, so an absent field leaves no stray separator.
  Over budget, mark the line and drop the longest field until it fits, so the
  field that blew up is the one that disappears.``
  [cache]
  (def parts (filter |(not (blank? $)) cache))
  (def line (string/join parts sep))
  (if (<= (length line) line-max-bytes)
    line
    (fit parts)))

(defn write-line
  ``Write to the status fifo, true when it landed. kwm holds the fifo open while
  its bar is up, but the bar only appears after kwm has spawned us, so an absent
  reader is normal at startup -- os/open fails fast there instead of blocking the
  whole ev loop the way spit does.``
  [path line]
  (try
    (with [f (os/open path :w)] (:write f (string line "\n")) true)
    ([_] false)))

(defn run
  "Tick forever, writing the composed line to the status fifo on every change."
  [status-fifo]
  (unless (os/stat status-fifo :mode)
    (eprint "kwm-status: " status-fifo " does not exist, is river's init running?")
    (os/exit 1))

  (var tick 0)
  (var prev nil)
  (var cache (array/new-filled (length fields) ""))
  (forever
    # 600s matches waybar; retry at 60s until the first fetch lands
    (when (or (due? tick 600)
              (and (not (os/stat weather-cache :mode)) (due? tick 60)))
      (ev/spawn (try (weather-refresh) ([_] nil))))

    (set cache (refresh tick cache))
    (def line (compose cache))
    (when (and (not= line prev) (write-line status-fifo line))
      (set prev line))

    (ev/sleep tick-secs)
    (++ tick)))

(defn main [& args]
  (run (or (get args 1) (string runtime-dir "/kwm-status"))))
