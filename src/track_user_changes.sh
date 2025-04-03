# Funkcja do śledzenia zmian w użytkownikach i grupach
track_user_changes() {
    print_header "Zmiany w użytkownikach i grupach"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Zmiany w użytkownikach po $SINCE_DATE:${RESET}"

        # Sprawdź pliki passwd i shadow
        if [ -f /etc/passwd ] && [ "$(stat -c '%Y' /etc/passwd)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${YELLOW}Plik /etc/passwd został zmodyfikowany:${RESET}"
            mod_date=$(stat -c '%y' /etc/passwd | cut -d. -f1)
            echo "$mod_date: /etc/passwd"
        fi

        if [ -f /etc/shadow ] && [ "$(stat -c '%Y' /etc/shadow)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${YELLOW}Plik /etc/shadow został zmodyfikowany:${RESET}"
            mod_date=$(stat -c '%y' /etc/shadow | cut -d. -f1)
            echo "$mod_date: /etc/shadow"
        fi

        if [ -f /etc/group ] && [ "$(stat -c '%Y' /etc/group)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${YELLOW}Plik /etc/group został zmodyfikowany:${RESET}"
            mod_date=$(stat -c '%y' /etc/group | cut -d. -f1)
            echo "$mod_date: /etc/group"
        fi

        # Sprawdź logi dotyczące użytkowników
        if [ -f /var/log/auth.log ]; then
            echo -e "\n${YELLOW}Aktywność związana z użytkownikami w logach auth.log:${RESET}"
            grep -E "useradd|usermod|userdel|groupadd|groupmod|groupdel" /var/log/auth.log | grep -v "pam_unix" | grep -A1 -B1 -i --text "$(date -d "$SINCE_DATE" +"%b %d")" | tail -n 20
        elif [ -f /var/log/secure ]; then
            echo -e "\n${YELLOW}Aktywność związana z użytkownikami w logach secure:${RESET}"
            grep -E "useradd|usermod|userdel|groupadd|groupmod|groupdel" /var/log/secure | grep -v "pam_unix" | grep -A1 -B1 -i --text "$(date -d "$SINCE_DATE" +"%b %d")" | tail -n 20
        fi
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}