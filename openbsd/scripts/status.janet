#!/usr/bin/env janet

# Status-bar helpers for OpenBSD, dispatched by the first CLI argument.
# Bundles what volume.sh / battery.sh / vpn.sh / backlight.sh used to do:
#   status.janet volume     speaker mute state + output level
#   status.janet battery    charge %, time-to-empty (or AC), draw rate
#   status.janet vpn        wg0/wg1 description (tunnel name), or NO VPN
#   status.janet backlight  current xbacklight level
#   status.janet datetime   German weekday + date + time, with icons

(defn sh
  ``Run a command (program followed by args) and return its trimmed stdout.
  Stderr is swallowed (the shell versions all used `2>/dev/null`) and a
  missing binary yields "" so callers can treat it as absent. The exit code
  is not checked, so a nonzero exit still returns whatever was on stdout
  (matching the shell versions, which keyed off empty output, not status).``
  [& args]
  (try
    (with [proc (os/spawn args :p {:out :pipe :err :pipe})]
      (let [[out] (ev/gather
                    (ev/read (proc :out) :all)
                    (ev/read (proc :err) :all)
                    (os/proc-wait proc))]
        (if out (string/trim out) "")))
    ([_] "")))

(defn volume []
  (if (= "1" (sh "sndioctl" "-n" "output.mute"))
    (print "  MUTED")
    # output.level is a 0..1 float; show it as a whole percent
    (let [level (or (scan-number (sh "sndioctl" "-n" "output.level")) 0)]
      (printf "  %.0f%%" (* level 100)))))

(defn battery []
  (let [life (sh "apm" "-l")
        mins (sh "apm" "-m")
        rate (string/replace " (rate)" ""
                             (sh "sysctl" "-n" "hw.sensors.acpibat0.power0"))
        time-str (if (or (empty? mins) (= mins "unknown"))
                   "AC"
                   (let [m (scan-number mins)]
                     (string (div m 60) "h" (mod m 60) "m")))]
    (printf "󰄌 %s%% %s %s" life time-str rate)))

(defn vpn []
  (defn descr [iface]
    # `ifconfig <iface>` prints "description: <name>"; grab the last field
    (let [line (->> (string/split "\n" (sh "ifconfig" iface))
                    (find |(string/find "description:" $)))]
      (if line (last (string/split " " (string/trim line))) "")))
  (let [a (descr "wg0")
        b (descr "wg1")
        up (filter (comp not empty?) [a b])]
    (if (empty? up)
      (print "NO VPN")
      (print " " (string/join up " + ")))))

(defn backlight []
  (let [bl (or (scan-number (sh "xbacklight" "-get")) 0)]
    (printf " %.0f" bl)))

(defn datetime []
  # os/date gives :week-day 0=Sun, :month-day/:month 0-based; map to the
  # German weekday and the original's "<cal> WD dd.mm.  <clock> HH:MM" layout.
  (let [d  (os/date (os/time) true)
        wd (get ["So" "Mo" "Di" "Mi" "Do" "Fr" "Sa"] (d :week-day))]
    (printf "\xef\x81\xb3 %s %02d.%02d. \xef\x80\x97 %02d:%02d"
            wd (inc (d :month-day)) (inc (d :month))
            (d :hours) (d :minutes))))

(def commands
  {"volume"    volume
   "battery"   battery
   "vpn"       vpn
   "backlight" backlight
   "datetime"  datetime})

(defn main [& args]
  (let [cmd (get args 1)
        handler (get commands cmd)]
    (if handler
      (handler)
      (do
        (eprintf "usage: %s {%s}"
                 (get args 0 "status.janet")
                 (string/join (sorted (keys commands)) "|"))
        (os/exit 1)))))
