# Funkcja do sprawdzania czasów modyfikacji plików systemowych
check_system_timestamps() {
    print_header "Czasy modyfikacji kluczowych plików systemowych"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Kluczowe pliki systemowe zmienione po $SINCE_DATE:${RESET}\n"

        # Lista kluczowych katalogów i plików do sprawdzenia
        system_files=(
            "/boot"
            "/etc/fstab"
            "/etc/hosts"
            "/etc/resolv.conf"
            "/etc/ssh/sshd_config"
            "/etc/pam.d"
            "/etc/security"
            "/etc/sudoers"
            "/etc/sudoers.d"
            "/etc/modules"
            "/etc/modprobe.d"
            "/etc/sysctl.conf"
            "/etc/sysctl.d"
            "/etc/default"
            "/lib/modules"
        )

        for file in "${system_files[@]}"; do
            if [ -e "$file" ]; then
                if [ -d "$file" ]; then
                    # Dla katalogów sprawdź rekursywnie pliki
                    find "$file" -type f -newermt "$SINCE_DATE" 2>/dev/null | while read -r changed_file; do
                        mod_date=$(stat -c '%y' "$changed_file" | cut -d. -f1)
                        echo "$mod_date: $changed_file"
                    done
                elif [ -f "$file" ] && [ "$(stat -c '%Y' "$file")" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
                    # Dla pojedynczych plików
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $file"
                fi
            fi
        done
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}