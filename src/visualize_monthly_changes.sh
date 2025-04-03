# Funkcja do wizualizacji zmian miesięcznych
visualize_monthly_changes() {
    print_header "Wizualizacja zmian miesięcznych z ostatnich 12 miesięcy"

    # Inicjalizacja tablic dla przechowywania danych
    declare -A packages_count
    local months=()
    local month_labels=()

    # Pobierz bieżącą datę
    local current_date
    local current_month
    local current_year
    local current_month_num

    current_date=$(date +"%Y-%m-%d")
    current_month=$(date +"%Y-%m")
    current_year=$(date +"%Y")
    current_month_num=$(date +"%m")

    # Inicjalizuj tablicę dla miesięcy (skrócone nazwy)
    declare -A month_names
    month_names["01"]="Sty"
    month_names["02"]="Lut"
    month_names["03"]="Mar"
    month_names["04"]="Kwi"
    month_names["05"]="Maj"
    month_names["06"]="Cze"
    month_names["07"]="Lip"
    month_names["08"]="Sie"
    month_names["09"]="Wrz"
    month_names["10"]="Paź"
    month_names["11"]="Lis"
    month_names["12"]="Gru"

    echo -e "${GREEN}Generowanie wykresu zmian miesięcznych${RESET}\n"

    # Zbierz dane dla każdego miesiąca z ostatnich 12 miesięcy
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

        # Dodaj miesiąc do listy miesięcy
        months+=("$year_month")
        month_labels+=("${month_names[$month_num]}$(date -d "$month_start" +"%y")")

        # Inicjalizuj licznik pakietów dla tego miesiąca
        packages_count[$year_month]=0

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
    done

    # Znajdź maksymalną wartość dla skali wykresu
    local max_count=0
    for month in "${months[@]}"; do
        if [ "${packages_count[$month]}" -gt "$max_count" ]; then
            max_count=${packages_count[$month]}
        fi
    done

    # Jeśli brak danych, ustaw maksimum na 1 aby uniknąć dzielenia przez zero
    if [ "$max_count" -eq 0 ]; then
        max_count=1
    fi

    # Ustaw wysokość wykresu
    local chart_height=10

    # Generuj wykres
    echo -e "${CYAN}Zainstalowane pakiety miesięcznie:${RESET}\n"

    # Rysuj oś Y i wykres
    for ((j=chart_height; j>=0; j--)); do
        # Wylicz wartość dla danej wysokości
        local y_value=$(( max_count * j / chart_height ))

        # Formatowanie etykiety osi Y
        printf "%4d │ " "$y_value"

        # Rysuj słupki
        for month in "${months[@]}"; do
            local bar_height=$(( chart_height * packages_count[$month] / max_count ))
            if [ $j -le $bar_height ]; then
                printf "█ "
            else
                printf "  "
            fi
        done
        printf "\n"
    done

    # Rysuj oś X
    printf "     └"
    for ((i=0; i<${#months[@]}; i++)); do
        printf "──"
    done
    printf "\n"

    # Rysuj etykiety osi X
    printf "       "
    for label in "${month_labels[@]}"; do
        printf "%-2s" "$label"
    done
    printf "\n"

    echo -e "\n${GREEN}Legenda:${RESET} Wykres przedstawia liczbę zainstalowanych pakietów w każdym miesiącu z ostatnich 12 miesięcy."
}