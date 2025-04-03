# Funkcja do sprawdzania zmian w konfiguracji sieci
check_network_changes() {
    print_header "Zmiany w konfiguracji sieci"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Zmiany w konfiguracji sieci po $SINCE_DATE:${RESET}\n"

        # Sprawdź katalogi konfiguracji sieci
        network_dirs=(
            "/etc/network"
            "/etc/NetworkManager"
            "/etc/netplan"
            "/etc/sysconfig/network-scripts"
        )

        for dir in "${network_dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo -e "${YELLOW}Zmiany w $dir:${RESET}"
                find "$dir" -type f -newermt "$SINCE_DATE" 2>/dev/null | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $file"
                done
            fi
        done

        # Sprawdź konfigurację DNS
        if [ -f "/etc/resolv.conf" ] && [ "$(stat -c '%Y' "/etc/resolv.conf")" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${YELLOW}Zmiana w /etc/resolv.conf:${RESET}"
            mod_date=$(stat -c '%y' "/etc/resolv.conf" | cut -d. -f1)
            echo "$mod_date: /etc/resolv.conf"
            grep -v "^#" "/etc/resolv.conf" | grep -v "^$"
        fi

        # Sprawdź plik hosts
        if [ -f "/etc/hosts" ] && [ "$(stat -c '%Y' "/etc/hosts")" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${YELLOW}Zmiana w /etc/hosts:${RESET}"
            mod_date=$(stat -c '%y' "/etc/hosts" | cut -d. -f1)
            echo "$mod_date: /etc/hosts"
            grep -v "^#" "/etc/hosts" | grep -v "^$"
        fi
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}