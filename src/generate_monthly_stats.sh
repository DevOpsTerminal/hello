# Funkcja do generowania statystyk miesięcznych
generate_monthly_stats() {
    print_header "Statystyki zmian miesięcznych z ostatnich 12 miesięcy"

    # Inicjalizuj tablicę dla miesięcy
    declare -A month_names
    month_names["01"]="Styczeń"
    month_names["02"]="Luty"
    month_names["03"]="Marzec"
    month_names["04"]="Kwiecień"
    month_names["05"]="Maj"
    month_names["06"]="Czerwiec"
    month_names["07"]="Lipiec"
    month_names["08"]="Sierpień"
    month_names["09"]="Wrzesień"
    month_names["10"]="Październik"
    month_names["11"]="Listopad"
    month_names["12"]="Grudzień"

    # Inicjalizuj tablice dla statystyk
    declare -A packages_count
    declare -A services_count
    declare -A configs_count
    declare -A users_count
    declare -A network_count

    # Pobierz bieżącą datę
    local current_date
    local current_month
    local current_year
    local current_month_num

    current_date=$(date +"%Y-%m-%d")
    current_month=$(date +"%Y-%m")
    current_year=$(date +"%Y")
    current_month_num=$(date +"%m")

    echo -e "${GREEN}Generowanie statystyk miesięcznych od $(date -d "12 months ago" +"%B %Y") do $(date +"%B %Y")${RESET}\n"

    # Przygotuj dane dla każdego miesiąca z ostatnich 12 miesięcy
    for ((i=11; i>=0; i--)); do
        # Oblicz datę początku i końca miesiąca
        local month_start
        local next_month
        local year_month

        month_start=$(date -d "$current_year-$current_month_num-01 -$i months" +"%Y-%m-01")
        next_month=$(date -d "$month_start +1 month" +"%Y-%m-01")
        year_month=$(date -d "$month_start" +"%Y-%m")

        # Inicjalizuj liczniki dla tego miesiąca
        packages_count[$year_month]=0
        services_count[$year_month]=0
        configs_count[$year_month]=0
        users_count[$year_month]=0
        network_count[$year_month]=0

        # Licz pakiety
        if command_exists dpkg; then
            if [ -f /var/log/dpkg.log ] || [ -f /var/log/dpkg.log.1 ]; then
                for log_file in /var/log/dpkg.log /var/log/dpkg.log.1; do
                    if [ -f "$log_file" ]; then
                        while read -r line; do
                            log_date=$(echo "$line" | awk '{print $1}')
                            if is_date_between "$log_date" "$month_start" "$next_month"; then
                                packages_count[$year_month]=$((packages_count[$year_month]+1))
                            fi
                        done < <(grep " install " "$log_file" | grep -v "status installed")
                    fi
                done
            fi
        elif command_exists rpm; then
            if [ -f /var/log/dnf.log ] || [ -f /var/log/yum.log ]; then
                for log_file in /var/log/dnf.log /var/log/yum.log; do
                    if [ -f "$log_file" ]; then
                        while read -r line; do
                            if [[ "$log_file" == *"dnf.log"* ]]; then
                                log_date=$(echo "$line" | awk '{print $1 " " $2}' | sed 's/:$//')
                            else
                                log_date=$(echo "$line" | awk '{print $1 " " $2}')
                            fi

                            if is_date_between "$log_date" "$month_start" "$next_month"; then
                                packages_count[$year_month]=$((packages_count[$year_month]+1))
                            fi
                        done < <(grep -i "Installed" "$log_file")
                    fi
                done
            fi
        fi

        # Licz usługi
        if command_exists systemctl && [ -d "/etc/systemd/system" ]; then
            while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                if is_date_between "$mod_date" "$month_start" "$next_month"; then
                    services_count[$year_month]=$((services_count[$year_month]+1))
                fi
            done < <(find "/etc/systemd/system" -name "*.service" -type f)
        fi

        if [ -d "/etc/init.d" ]; then
            while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                if is_date_between "$mod_date" "$month_start" "$next_month"; then
                    services_count[$year_month]=$((services_count[$year_month]+1))
                fi
            done < <(find "/etc/init.d" -type f)
        fi

        # Licz pliki konfiguracyjne
        if [ -d "/etc" ]; then
            while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                if is_date_between "$mod_date" "$month_start" "$next_month"; then
                    configs_count[$year_month]=$((configs_count[$year_month]+1))
                fi
            done < <(find "/etc" -type f -not -path "*/\.*" 2>/dev/null | head -n 1000)
        fi

        # Licz zmiany użytkowników
        if [ -f "/etc/passwd" ]; then
            mod_date=$(stat -c '%y' "/etc/passwd" | cut -d. -f1)
            if is_date_between "$mod_date" "$month_start" "$next_month"; then
                users_count[$year_month]=$((users_count[$year_month]+1))
            fi
        fi

        if [ -f "/etc/group" ]; then
            mod_date=$(stat -c '%y' "/etc/group" | cut -d. -f1)
            if is_date_between "$mod_date" "$month_start" "$next_month"; then
                users_count[$year_month]=$((users_count[$year_month]+1))
            fi
        fi

        # Licz zmiany sieci
        network_dirs=("/etc/network" "/etc/NetworkManager" "/etc/netplan" "/etc/sysconfig/network-scripts")
        for dir in "${network_dirs[@]}"; do
            if [ -d "$dir" ]; then
                while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    if is_date_between "$mod_date" "$month_start" "$next_month"; then
                        network_count[$year_month]=$((network_count[$year_month]+1))
                    fi
                done < <(find "$dir" -type f 2>/dev/null)
            fi
        done
    done

    # Wyświetl statystyki w formie tabeli
    echo -e "${YELLOW}Miesiąc\t\tPakiety\tUsługi\tKonfiguracje\tUżytkownicy\tSieć${RESET}"
    echo -e "${YELLOW}----------------------------------------------------------------------${RESET}"

    for ((i=11; i>=0; i--)); do
        local month_start
        local year_month
        local month_num
        local year_num

        month_start=$(date -d "$current_year-$current_month_num-01 -$i months" +"%Y-%m-01")
        year_month=$(date -d "$month_start" +"%Y-%m")
        month_num=$(date -d "$month_start" +"%m")
        year_num=$(date -d "$month_start" +"%Y")

        local month_display="${month_names[$month_num]} $year_num"

        # Uzupełnij spacjami, aby zachować formatowanie tabeli
        if [ ${#month_display} -lt 16 ]; then
            month_display="${month_display}$(printf '%*s' $((16-${#month_display})) '')"
        fi

        echo -e "${CYAN}${month_display}${RESET}\t${packages_count[$year_month]}\t${services_count[$year_month]}\t${configs_count[$year_month]}\t${users_count[$year_month]}\t\t${network_count[$year_month]}"
    done

    echo -e "\n${GREEN}Legenda:${RESET}"
    echo -e "  Pakiety: Liczba zainstalowanych pakietów"
    echo -e "  Usługi: Liczba zmodyfikowanych usług systemowych"
    echo -e "  Konfiguracje: Liczba zmodyfikowanych plików konfiguracyjnych"
    echo -e "  Użytkownicy: Zmiany w kontach użytkowników i grupach"
    echo -e "  Sieć: Zmiany w konfiguracji sieci"
}