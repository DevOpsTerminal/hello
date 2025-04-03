# Funkcja do sprawdzania zmian w plikach konfiguracyjnych
check_config_changes() {
    print_header "Zmiany w plikach konfiguracyjnych"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Pliki konfiguracyjne zmienione po $SINCE_DATE:${RESET}"

        # Główne lokalizacje plików konfiguracyjnych
        config_dirs=("/etc" "/usr/local/etc")

        for dir in "${config_dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo -e "\n${YELLOW}Zmiany w $dir:${RESET}"
                find "$dir" -type f -newermt "$SINCE_DATE" 2>/dev/null | sort | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $file"
                done
            fi
        done
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}