# Funkcja do wyświetlania zmian w plikach binarnych i skryptach
track_binary_changes() {
    print_header "Zmiany w plikach binarnych i skryptach"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Zmiany w katalogach binarnych po $SINCE_DATE:${RESET}"

        # Sprawdzenie głównych katalogów z plikami wykonywalnymi
        bin_dirs=("/bin" "/usr/bin" "/usr/local/bin" "/sbin" "/usr/sbin" "/usr/local/sbin")

        for dir in "${bin_dirs[@]}"; do
            if [ -d "$dir" ]; then
                echo -e "\n${YELLOW}Zmiany w $dir:${RESET}"
                find "$dir" -type f -newermt "$SINCE_DATE" -executable | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $file"
                done
            fi
        done

        # Sprawdzenie skryptów startowych
        echo -e "\n${YELLOW}Zmiany w skryptach startowych:${RESET}"
        rc_dirs=("/etc/init.d" "/etc/init" "/etc/rc.d" "/etc/systemd")

        for dir in "${rc_dirs[@]}"; do
            if [ -d "$dir" ]; then
                find "$dir" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $file"
                done
            fi
        done
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}