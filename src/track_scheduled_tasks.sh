# Funkcja do śledzenia zmian w crontab i zaplanowanych zadaniach
track_scheduled_tasks() {
    print_header "Zmiany w zaplanowanych zadaniach"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Zmiany w zadaniach cron i systemd-timer po $SINCE_DATE:${RESET}"

        # Sprawdź pliki crontab
        cron_dirs=("/etc/cron.d" "/etc/crontab" "/var/spool/cron" "/var/spool/cron/crontabs")

        for dir in "${cron_dirs[@]}"; do
            if [ -e "$dir" ]; then
                if [ -d "$dir" ]; then
                    echo -e "\n${YELLOW}Zmiany w $dir:${RESET}"
                    find "$dir" -type f -newermt "$SINCE_DATE" | while read -r file; do
                        mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                        echo "$mod_date: $file"
                        grep -v "^#" "$file" | grep -v "^$" | head -n 5
                        echo "..."
                    done
                elif [ -f "$dir" ] && [ "$(stat -c '%Y' "$dir")" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
                    echo -e "\n${YELLOW}Zmiany w $dir:${RESET}"
                    mod_date=$(stat -c '%y' "$dir" | cut -d. -f1)
                    echo "$mod_date: $dir"
                    grep -v "^#" "$dir" | grep -v "^$" | head -n 5
                    echo "..."
                fi
            fi
        done

        # Sprawdź timery systemd
        if command_exists systemctl; then
            echo -e "\n${YELLOW}Timery systemd zmienione po $SINCE_DATE:${RESET}"
            if [ -d "/etc/systemd/system" ]; then
                find "/etc/systemd/system" -name "*.timer" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    timer_name=$(basename "$file")
                    echo "$mod_date: $timer_name"
                    systemctl status "$(basename "$file")" 2>/dev/null | head -n 5 || echo "Timer nieaktywny"
                done
            fi
        fi
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}