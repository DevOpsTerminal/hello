# Uzyskaj listę uruchomionych usług/procesów
get_running_services() {
    print_header "Uruchomione usługi"

    if command_exists systemctl; then
        echo -e "${GREEN}Usługi systemd:${RESET}"
        systemctl list-units --type=service --state=running | grep "\.service" | awk '{print $1}'

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Usługi zmienione po $SINCE_DATE:${RESET}"
            systemd_services_dir="/etc/systemd/system"
            if [ -d "$systemd_services_dir" ]; then
                find "$systemd_services_dir" -name "*.service" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    service_name=$(basename "$file")
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $service_name (zmodyfikowana)"
                done
            fi

            # Sprawdź również logi systemd pod kątem zmian w usługach
            if command_exists journalctl; then
                echo -e "\n${CYAN}Zmiany stanu usług w logach systemd po $SINCE_DATE:${RESET}"
                journalctl -u "*.service" --since "$SINCE_DATE" | grep -E "(Started|Stopped|Failed)" | head -n 20
            fi
        fi
    elif command_exists service; then
        echo -e "${GREEN}Usługi init.d/service:${RESET}"
        service --status-all | grep "\[ + \]" | awk '{print $4}'

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Usługi zmienione po $SINCE_DATE:${RESET}"
            initd_dir="/etc/init.d"
            if [ -d "$initd_dir" ]; then
                find "$initd_dir" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    service_name=$(basename "$file")
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $service_name (zmodyfikowana)"
                done
            fi
        fi
    else
        echo -e "${RED}Nie znaleziono znanego menedżera usług${RESET}"
    fi
}