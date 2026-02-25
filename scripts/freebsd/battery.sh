# Query battery values
life=$(sysctl -n hw.acpi.battery.life 2>/dev/null)
time=$(sysctl -n hw.acpi.battery.time 2>/dev/null)
rate=$(sysctl -n hw.acpi.battery.rate 2>/dev/null)

# Handle unknown time (-1 when charching?)
if [ "$time" -lt 0 ] 2>/dev/null; then
    time_str="unknown"
else
    hours=$((time / 60))
    mins=$((time % 60))
    time_str="${hours}h${mins}m"
fi

# Output in one line
printf "Bat: %s%% %s %s mW\n" "$life" "$time_str" "$rate"
