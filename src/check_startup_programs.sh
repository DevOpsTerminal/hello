# Sprawdź automaty startowe
check_startup_programs() {
    print_header "Programy uruchamiane na starcie"

    # Sprawdź usługi systemd
    if command_exists systemctl; then
        echo -e "${GREEN}Usługi systemd włączone podczas startu:${RESET}"
        systemctl list-unit-files --type=service --state=enabled | grep "\.service" | awk '{print $1}'

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Usługi systemd zmienione po $SINCE_DATE:${RESET}"
            systemd_dir="/etc/systemd/system"
            if [ -d "$systemd_dir" ]; then
                find "$systemd_dir" -name "*.service" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    service_name=$(basename "$file")
                    service_state=$(systemctl is-enabled "$service_name" 2>/dev/null || echo "unknown")
                    echo "$mod_date: $service_name (stan: $service_state)"
                done
            fi
        fi
    fi

    # Sprawdź programy startowe użytkownika
    if [ -d /etc/xdg/autostart ]; then
        echo -e "\n${GREEN}Programy startowe XDG:${RESET}"
        ls -l /etc/xdg/autostart/

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Programy startowe XDG zmienione po $SINCE_DATE:${RESET}"
            find /etc/xdg/autostart -type f -newermt "$SINCE_DATE" | while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                echo "$mod_date: $file"
            done
        fi
    fi

    # Sprawdź rc.local
    if [ -f /etc/rc.local ]; then
        echo -e "\n${GREEN}Zawartość /etc/rc.local:${RESET}"
        grep -v "^#" /etc/rc.local | grep -v "^$"

        if [ "$TRACK_CHANGES" = true ] && [ "$(stat -c '%Y' /etc/rc.local)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${CYAN}Plik /etc/rc.local został zmodyfikowany:${RESET}"
            mod_date=$(stat -c '%y' /etc/rc.local | cut -d. -f1)
            echo "$mod_date: /etc/rc.local"
        fi
    fi
}