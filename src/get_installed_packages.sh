# Pobierz zainstalowane pakiety w zależności od menedżera pakietów
get_installed_packages() {
    print_header "Zainstalowane pakiety"

    if command_exists dpkg; then
        echo -e "${GREEN}Pakiety Debian/Ubuntu (dpkg):${RESET}"
        dpkg -l | grep "^ii" | awk '{print $2}' | sort

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Pakiety zainstalowane po $SINCE_DATE:${RESET}"
            if [ -f /var/log/dpkg.log ]; then
                grep " install " /var/log/dpkg.log | grep -v "status installed" | while read -r line; do
                    log_date=$(echo "$line" | awk '{print $1}')
                    if is_after_since_date "$log_date"; then
                        package=$(echo "$line" | awk '{print $4}')
                        echo "$log_date: $package"
                    fi
                done
            else
                find /var/lib/dpkg/info/ -name "*.list" -newer "$(date -d "$SINCE_DATE" +%Y%m%d)" | sed 's/.*\///g' | sed 's/\.list$//g'
            fi
        fi
    elif command_exists rpm; then
        echo -e "${GREEN}Pakiety RPM (Fedora/CentOS/RHEL):${RESET}"
        rpm -qa --qf "%{NAME}\n" | sort

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Pakiety zainstalowane po $SINCE_DATE:${RESET}"
            if [ -f /var/log/dnf.log ]; then
                grep -i "Installed" /var/log/dnf.log | while read -r line; do
                    log_date=$(echo "$line" | awk '{print $1 " " $2}' | sed 's/:$//')
                    if is_after_since_date "$log_date"; then
                        package=$(echo "$line" | awk '{print $5}' | sed 's/:.*//')
                        echo "$log_date: $package"
                    fi
                done
            elif [ -f /var/log/yum.log ]; then
                grep "Installed" /var/log/yum.log | while read -r line; do
                    log_date=$(echo "$line" | awk '{print $1 " " $2}')
                    if is_after_since_date "$log_date"; then
                        package=$(echo "$line" | awk '{print $5}')
                        echo "$log_date: $package"
                    fi
                done
            fi
        fi
    elif command_exists pacman; then
        echo -e "${GREEN}Pakiety Arch Linux:${RESET}"
        pacman -Q | awk '{print $1}' | sort

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Pakiety zainstalowane po $SINCE_DATE:${RESET}"
            since_timestamp=$(date -d "$SINCE_DATE" +%s)
            grep "\[ALPM\] installed" /var/log/pacman.log | while read -r line; do
                log_date=$(echo "$line" | cut -d[ -f2 | cut -d] -f1)
                log_timestamp=$(date -d "$log_date" +%s 2>/dev/null)
                if [ -n "$log_timestamp" ] && [ "$log_timestamp" -ge "$since_timestamp" ]; then
                    package=$(echo "$line" | sed 's/.*installed \(.*\) (.*/\1/')
                    echo "$log_date: $package"
                fi
            done
        fi
    else
        echo -e "${RED}Nie znaleziono znanego menedżera pakietów${RESET}"
    fi
}