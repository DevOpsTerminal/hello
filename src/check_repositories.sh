# Funkcja do sprawdzenia zainstalowanych repozytoriów
check_repositories() {
    print_header "Skonfigurowane repozytoria"

    if [ -d /etc/apt/sources.list.d ]; then
        echo -e "${GREEN}Repozytoria APT (Debian/Ubuntu):${RESET}"
        ls -l /etc/apt/sources.list.d/
        echo -e "\n${GREEN}Główne repozytoria:${RESET}"
        grep -v "^#" /etc/apt/sources.list | grep -v "^$"

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Repozytoria dodane/zmienione po $SINCE_DATE:${RESET}"
            find /etc/apt/sources.list.d -type f -newermt "$SINCE_DATE" | while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                echo "$mod_date: $file"
                grep -v "^#" "$file" | grep -v "^$"
            done

            # Sprawdź główny plik sources.list
            if [ -f /etc/apt/sources.list ] && [ "$(stat -c '%Y' /etc/apt/sources.list)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
                echo -e "\n${CYAN}Zmiany w głównym pliku sources.list:${RESET}"
                mod_date=$(stat -c '%y' /etc/apt/sources.list | cut -d. -f1)
                echo "$mod_date: /etc/apt/sources.list"
            fi
        fi
    elif [ -d /etc/yum.repos.d ]; then
        echo -e "${GREEN}Repozytoria YUM/DNF (Fedora/RHEL/CentOS):${RESET}"
        ls -l /etc/yum.repos.d/

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Repozytoria dodane/zmienione po $SINCE_DATE:${RESET}"
            find /etc/yum.repos.d -type f -newermt "$SINCE_DATE" | while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                echo "$mod_date: $file"
                grep -v "^#" "$file" | grep -v "^$" | head -n 10
                echo "..."
            done
        fi
    elif [ -f /etc/pacman.conf ]; then
        echo -e "${GREEN}Repozytoria Pacman (Arch):${RESET}"
        grep "^\[" /etc/pacman.conf

        if [ "$TRACK_CHANGES" = true ] && [ "$(stat -c '%Y' /etc/pacman.conf)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${CYAN}Zmiany w konfiguracji repozytorium po $SINCE_DATE:${RESET}"
            mod_date=$(stat -c '%y' /etc/pacman.conf | cut -d. -f1)
            echo "$mod_date: /etc/pacman.conf"
        fi
    else
        echo -e "${RED}Nie znaleziono konfiguracji repozytoriów${RESET}"
    fi
}