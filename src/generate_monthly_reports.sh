# Funkcja do generowania raportów miesięcznych
generate_monthly_reports() {
    print_header "Raport zmian miesięcznych z ostatnich 12 miesięcy"

    # Pobierz bieżącą datę
    local current_date
    local current_month
    local current_year
    local current_month_num

    current_date=$(date +"%Y-%m-%d")
    current_month=$(date +"%Y-%m")
    current_year=$(date +"%Y")
    current_month_num=$(date +"%m")

    echo -e "${GREEN}Generowanie raportów miesięcznych od $(date -d "12 months ago" +"%B %Y") do $(date +"%B %Y")${RESET}\n"

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

    # Generuj raporty dla każdego miesiąca z ostatnich 12 miesięcy
    for ((i=11; i>=0; i--)); do
        # Oblicz datę początku i końca miesiąca
        local month_start
        local next_month
        local year_month
        local month_num
        local year_num

        month_start=$(date -d "$current_year-$current_month_num-01 -$i months" +"%Y-%m-01")
        next_month=$(date -d "$month_start +1 month" +"%Y-%m-01")
        year_month=$(date -d "$month_start" +"%Y-%m")
        month_num=$(date -d "$month_start" +"%m")
        year_num=$(date -d "$month_start" +"%Y")

        echo -e "${BLUE}========== ${month_names[$month_num]} $year_num ==========${RESET}"

        # Zainstalowane pakiety
        if command_exists dpkg; then
            echo -e "${CYAN}Pakiety zainstalowane w ${month_names[$month_num]} $year_num:${RESET}"
            if [ -f /var/log/dpkg.log ] || [ -f /var/log/dpkg.log.1 ]; then
                local count=0
                # Sprawdź zarówno bieżący jak i archiwalny log
                for log_file in /var/log/dpkg.log /var/log/dpkg.log.1; do
                    if [ -f "$log_file" ]; then
                        while read -r line; do
                            log_date=$(echo "$line" | awk '{print $1}')
                            if is_date_between "$log_date" "$month_start" "$next_month"; then
                                package=$(echo "$line" | awk '{print $4}')
                                echo "  $log_date: $package"
                                count=$((count+1))
                            fi
                        done < <(grep " install " "$log_file" | grep -v "status installed")
                    fi
                done

                if [ $count -eq 0 ]; then
                    echo "  Brak zainstalowanych pakietów w tym miesiącu"
                fi
            else
                echo "  Brak dostępnych logów dla tego miesiąca"
            fi
        elif command_exists rpm; then
            echo -e "${CYAN}Pakiety zainstalowane w ${month_names[$month_num]} $year_num:${RESET}"
            if [ -f /var/log/dnf.log ] || [ -f /var/log/yum.log ]; then
                local count=0
                # Sprawdź zarówno dnf jak i yum logi
                for log_file in /var/log/dnf.log /var/log/yum.log; do
                    if [ -f "$log_file" ]; then
                        while read -r line; do
                            if [[ "$log_file" == *"dnf.log"* ]]; then
                                log_date=$(echo "$line" | awk '{print $1 " " $2}' | sed 's/:$//')
                            else
                                log_date=$(echo "$line" | awk '{print $1 " " $2}')
                            fi

                            if is_date_between "$log_date" "$month_start" "$next_month"; then
                                package=$(echo "$line" | awk '{print $5}' | sed 's/:.*//')
                                echo "  $log_date: $package"
                                count=$((count+1))
                            fi
                        done < <(grep -i "Installed" "$log_file")
                    fi
                done

                if [ $count -eq 0 ]; then
                    echo "  Brak zainstalowanych pakietów w tym miesiącu"
                fi
            else
                echo "  Brak dostępnych logów dla tego miesiącu"
            fi
        fi

        # Zmiany w usługach
        echo -e "\n${CYAN}Zmiany w usługach w ${month_names[$month_num]} $year_num:${RESET}"
        local service_count=0

        # Sprawdź usługi systemd
        if command_exists systemctl && [ -d "/etc/systemd/system" ]; then
            while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                if is_date_between "$mod_date" "$month_start" "$next_month"; then
                    service_name=$(basename "$file")
                    echo "  $mod_date: $service_name"
                    service_count=$((service_count+1))
                fi
            done < <(find "/etc/systemd/system" -name "*.service" -type f)
        fi

        # Sprawdź usługi init.d
        if [ -d "/etc/init.d" ]; then
            while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                if is_date_between "$mod_date" "$month_start" "$next_month"; then
                    service_name=$(basename "$file")
                    echo "  $mod_date: $service_name"
                    service_count=$((service_count+1))
                fi
            done < <(find "/etc/init.d" -type f)
        fi

        if [ $service_count -eq 0 ]; then
            echo "  Brak zmian w usługach w tym miesiącu"
        fi

        # Zmiany w plikach konfiguracyjnych
        echo -e "\n${CYAN}Zmiany w plikach konfiguracyjnych w ${month_names[$month_num]} $year_num:${RESET}"
        local config_count=0

        if [ -d "/etc" ]; then
            while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                if is_date_between "$mod_date" "$month_start" "$next_month"; then
                    echo "  $mod_date: $file"
                    config_count=$((config_count+1))

                    # Limit maksymalnej liczby plików dla przejrzystości
                    if [ $config_count -ge 10 ]; then
                        echo "  ... (więcej zmian pominięto dla przejrzystości)"
                        break
                    fi
                fi
            done < <(find "/etc" -type f -not -path "*/\.*" 2>/dev/null)
        fi

        if [ $config_count -eq 0 ]; then
            echo "  Brak zmian w plikach konfiguracyjnych w tym miesiącu"
        fi

        echo -e "\n"
    done
}