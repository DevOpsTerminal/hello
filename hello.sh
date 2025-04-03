#!/bin/bash

# Linux Software Finder
# Skrypt do wyszukiwania zainstalowanego oprogramowania i usług na systemach Linux
# Działa na różnych dystrybucjach (Ubuntu, Debian, Fedora, itp.)
# Umożliwia śledzenie zmian w systemie od określonej daty

# Ustawienie kolorów dla lepszej czytelności
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'
# Domyślna data początku śledzenia zmian (ostatnie 7 dni)
DEFAULT_SINCE_DATE=$(date -d "7 days ago" +"%Y-%m-%d")
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
# Sprawdź otwarte porty
check_open_ports() {
    print_header "Otwarte porty i nasłuchujące usługi"

    if command_exists ss; then
        echo -e "${GREEN}Lista otwartych portów (ss):${RESET}"
        ss -tuln | grep LISTEN

        if [ "$TRACK_CHANGES" = true ]; then
            # Zapisz bieżące porty do tymczasowego pliku
            ss -tuln | grep LISTEN > /tmp/current_ports.tmp

            # Wyświetl informacje o procesach nasłuchujących na portach
            echo -e "\n${CYAN}Procesy nasłuchujące na portach:${RESET}"
            ss -tulnp | grep LISTEN
        fi
    elif command_exists netstat; then
        echo -e "${GREEN}Lista otwartych portów (netstat):${RESET}"
        netstat -tuln | grep LISTEN

        if [ "$TRACK_CHANGES" = true ]; then
            # Zapisz bieżące porty do tymczasowego pliku
            netstat -tuln | grep LISTEN > /tmp/current_ports.tmp

            # Wyświetl informacje o procesach nasłuchujących na portach
            echo -e "\n${CYAN}Procesy nasłuchujące na portach:${RESET}"
            netstat -tulnp | grep LISTEN
        fi
    else
        echo -e "${RED}Nie znaleziono narzędzia do sprawdzania portów${RESET}"
    fi
}
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
# Sprawdź automaty startowe
check_startup_programs() {
    print_header "Programy uruchamiane na starcie"

    # Sprawdź usługi systemd
    if command_exists systemctl; then
        echo -e "${GREEN}Usługi systemd włączone podczas startu:${RESET}"
        systemctl list-unit-files --type=service --state=enabled | grep "\.service" | awk '{print $1}'

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Usługi systemd zmienione po $SINCE_DATE:${RESET}"
            systemd_dir="/etc/systemd/system"
            if [ -d "$systemd_dir" ]; then
                find "$systemd_dir" -name "*.service" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    service_name=$(basename "$file")
                    service_state=$(systemctl is-enabled "$service_name" 2>/dev/null || echo "unknown")
                    echo "$mod_date: $service_name (stan: $service_state)"
                done
            fi
        fi
    fi

    # Sprawdź programy startowe użytkownika
    if [ -d /etc/xdg/autostart ]; then
        echo -e "\n${GREEN}Programy startowe XDG:${RESET}"
        ls -l /etc/xdg/autostart/

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Programy startowe XDG zmienione po $SINCE_DATE:${RESET}"
            find /etc/xdg/autostart -type f -newermt "$SINCE_DATE" | while read -r file; do
                mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                echo "$mod_date: $file"
            done
        fi
    fi

    # Sprawdź rc.local
    if [ -f /etc/rc.local ]; then
        echo -e "\n${GREEN}Zawartość /etc/rc.local:${RESET}"
        grep -v "^#" /etc/rc.local | grep -v "^$"

        if [ "$TRACK_CHANGES" = true ] && [ "$(stat -c '%Y' /etc/rc.local)" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
            echo -e "\n${CYAN}Plik /etc/rc.local został zmodyfikowany:${RESET}"
            mod_date=$(stat -c '%y' /etc/rc.local | cut -d. -f1)
            echo "$mod_date: /etc/rc.local"
        fi
    fi
}
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
# Funkcja do sprawdzania dostępności polecenia
command_exists() {
    command -v "$1" &> /dev/null
}
# Funkcja do konwersji daty na uniksowy timestamp
date_to_timestamp() {
    date -d "$1" +%s
}

# Funkcja do sprawdzania, czy data jest po dacie początku śledzenia zmian
is_after_since_date() {
    local file_date="$1"
    local since_timestamp
    local file_timestamp

    since_timestamp=$(date_to_timestamp "$SINCE_DATE")
    file_timestamp=$(date_to_timestamp "$file_date")

    if [ "$file_timestamp" -ge "$since_timestamp" ]; then
        return 0  # prawda
    else
        return 1  # fałsz
    fi
}

# Funkcja sprawdzająca, czy data jest pomiędzy dwoma datami
is_date_between() {
    local check_date="$1"
    local start_date="$2"
    local end_date="$3"
    local check_timestamp
    local start_timestamp
    local end_timestamp

    check_timestamp=$(date_to_timestamp "$check_date")
    start_timestamp=$(date_to_timestamp "$start_date")
    end_timestamp=$(date_to_timestamp "$end_date")

    if [ "$check_timestamp" -ge "$start_timestamp" ] && [ "$check_timestamp" -lt "$end_timestamp" ]; then
        return 0  # prawda
    else
        return 1  # fałsz
    fi
}
# Wykryj dystrybucję
detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "$NAME"
    elif [ -f /etc/lsb-release ]; then
        # shellcheck source=/dev/null
        . /etc/lsb-release
        echo "$DISTRIB_ID"
    elif [ -f /etc/debian_version ]; then
        echo "Debian"
    elif [ -f /etc/fedora-release ]; then
        echo "Fedora"
    elif [ -f /etc/redhat-release ]; then
        echo "RedHat/CentOS"
    else
        echo "Nieznana dystrybucja"
    fi
}
# Znajdź ostatnio zainstalowane pakiety
find_recent_packages() {
    print_header "Ostatnio zainstalowane pakiety"

    if command_exists dpkg; then
        echo -e "${GREEN}Ostatnie pakiety (dpkg):${RESET}"
        grep " install " /var/log/dpkg.log | tail -n 20
    elif command_exists rpm; then
        echo -e "${GREEN}Ostatnie pakiety (rpm):${RESET}"
        if [ -d /var/log/dnf ]; then
            grep "Installed" /var/log/dnf.log | tail -n 20
        elif [ -d /var/log/yum ]; then
            grep "Installed" /var/log/yum.log | tail -n 20
        fi
    elif command_exists pacman; then
        echo -e "${GREEN}Ostatnie pakiety (pacman):${RESET}"
        grep "\[ALPM\] installed" /var/log/pacman.log | tail -n 20
    else
        echo -e "${RED}Nie znaleziono logów instalacji pakietów${RESET}"
    fi
}
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
# Uzyskaj listę uruchomionych usług/procesów
get_running_services() {
    print_header "Uruchomione usługi"

    if command_exists systemctl; then
        echo -e "${GREEN}Usługi systemd:${RESET}"
        systemctl list-units --type=service --state=running | grep "\.service" | awk '{print $1}'

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Usługi zmienione po $SINCE_DATE:${RESET}"
            systemd_services_dir="/etc/systemd/system"
            if [ -d "$systemd_services_dir" ]; then
                find "$systemd_services_dir" -name "*.service" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    service_name=$(basename "$file")
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $service_name (zmodyfikowana)"
                done
            fi

            # Sprawdź również logi systemd pod kątem zmian w usługach
            if command_exists journalctl; then
                echo -e "\n${CYAN}Zmiany stanu usług w logach systemd po $SINCE_DATE:${RESET}"
                journalctl -u "*.service" --since "$SINCE_DATE" | grep -E "(Started|Stopped|Failed)" | head -n 20
            fi
        fi
    elif command_exists service; then
        echo -e "${GREEN}Usługi init.d/service:${RESET}"
        service --status-all | grep "\[ + \]" | awk '{print $4}'

        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "\n${CYAN}Usługi zmienione po $SINCE_DATE:${RESET}"
            initd_dir="/etc/init.d"
            if [ -d "$initd_dir" ]; then
                find "$initd_dir" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    service_name=$(basename "$file")
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    echo "$mod_date: $service_name (zmodyfikowana)"
                done
            fi
        fi
    else
        echo -e "${RED}Nie znaleziono znanego menedżera usług${RESET}"
    fi
}
# Pobierz informacje o systemie
get_system_info() {
    print_header "Informacje o systemie"

    DISTRO=$(detect_distro)
    echo -e "${GREEN}Dystrybucja:${RESET} $DISTRO"

    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo -e "${GREEN}Wersja:${RESET} $VERSION_ID"
    fi

    echo -e "${GREEN}Jądro:${RESET} $(uname -r)"
    echo -e "${GREEN}Architektura:${RESET} $(uname -m)"

    # Data instalacji systemu (przybliżona)
    if [ -f /var/log/installer/syslog ]; then
        install_date=$(head -n 1 /var/log/installer/syslog | awk '{print $1, $2, $3}')
        echo -e "${GREEN}Przybliżona data instalacji:${RESET} $install_date"
    elif [ -d /var/log/anaconda ]; then
        install_date=$(stat -c '%y' /var/log/anaconda | cut -d. -f1)
        echo -e "${GREEN}Przybliżona data instalacji:${RESET} $install_date"
    else
        # Alternatywna metoda określania daty instalacji
        oldest_pkg_date=$(find /var/lib/dpkg/info -type f -name "*.list" 2>/dev/null | xargs -r ls -tr 2>/dev/null | head -n 1 | xargs -r stat -c '%y' 2>/dev/null | cut -d. -f1)
        if [ -n "$oldest_pkg_date" ]; then
            echo -e "${GREEN}Przybliżona data instalacji (na podstawie pakietów):${RESET} $oldest_pkg_date"
        fi
    fi

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Data początku śledzenia zmian:${RESET} $SINCE_DATE"
    fi
}
# Funkcja do wyświetlania nagłówków
print_header() {
    echo -e "\n${BLUE}========== $1 ==========${RESET}\n"
}
# Zapisz wyniki do pliku
save_results() {
    local output_file
    output_file="system_software_$(date +%Y%m%d_%H%M%S).txt"

    {
        echo "=== Raport oprogramowania i usług systemu ==="
        echo "Data wygenerowania: $(date)"
        if [ "$TRACK_CHANGES" = true ]; then
            echo "Śledzenie zmian od: $SINCE_DATE"
        fi
        echo ""

        get_system_info
        get_installed_packages
        get_running_services
        check_open_ports
        check_startup_programs
        find_recent_packages
        check_repositories

        if [ "$TRACK_CHANGES" = true ]; then
            check_config_changes
            track_user_changes
            track_binary_changes
            track_scheduled_tasks
            check_network_changes
            check_system_timestamps
        fi

        # Dodaj raport miesięczny
        echo ""
        echo "=== Raport zmian miesięcznych ==="
        echo ""
        generate_monthly_stats

        # Dodaj informację o wizualizacji
        echo ""
        echo "=== Uwaga: Wizualizacja graficzna nie jest dostępna w raporcie tekstowym ==="
        echo "Aby zobaczyć graficzną wizualizację zmian miesięcznych, użyj odpowiedniej opcji w menu."

    } > "$output_file"

    echo -e "\n${GREEN}Raport został zapisany do pliku: ${YELLOW}$output_file${RESET}"

    # Zapytaj, czy użytkownik chce zapisać osobny raport miesięczny
    echo -e "\n${YELLOW}Czy chcesz zapisać szczegółowy raport miesięczny do osobnego pliku? (t/n)${RESET}"
    read -r -n 1 REPLY
    echo
    if [[ $REPLY =~ ^[Tt]$ ]]; then
        local monthly_file
        monthly_file="monthly_changes_$(date +%Y%m%d_%H%M%S).txt"
        {
            echo "=== Szczegółowy raport zmian miesięcznych ==="
            echo "Data wygenerowania: $(date)"
            echo ""

            generate_monthly_reports
        } > "$monthly_file"

        echo -e "${GREEN}Szczegółowy raport miesięczny został zapisany do pliku: ${YELLOW}$monthly_file${RESET}"
    fi
}
# Funkcja do ustawiania daty śledzenia zmian
set_tracking_date() {
    print_header "Ustawienie daty śledzenia zmian"

    echo -e "${YELLOW}Obecna data śledzenia zmian:${RESET} $SINCE_DATE"
    echo -e "${YELLOW}Formaty daty:${RESET}"
    echo "  - YYYY-MM-DD (np. 2023-01-15)"
    echo "  - 'X days ago' (np. '30 days ago')"
    echo "  - 'last month', 'last week', 'yesterday'"
    echo ""

    read -r -p "Podaj nową datę śledzenia zmian (lub naciśnij Enter, aby zachować obecną): " new_date

    if [ -n "$new_date" ]; then
        # Spróbuj przetworzyć datę
        if date -d "$new_date" >/dev/null 2>&1; then
            SINCE_DATE=$(date -d "$new_date" +"%Y-%m-%d")
            TRACK_CHANGES=true
            echo -e "${GREEN}Data śledzenia zmian została ustawiona na: ${YELLOW}$SINCE_DATE${RESET}"
        else
            echo -e "${RED}Nieprawidłowy format daty. Zachowano poprzednią datę.${RESET}"
        fi
    fi
}
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
# Funkcja do śledzenia zmian w crontab i zaplanowanych zadaniach
track_scheduled_tasks() {
    print_header "Zmiany w zaplanowanych zadaniach"

    if [ "$TRACK_CHANGES" = true ]; then
        echo -e "${CYAN}Zmiany w zadaniach cron i systemd-timer po $SINCE_DATE:${RESET}"

        # Sprawdź pliki crontab
        cron_dirs=("/etc/cron.d" "/etc/crontab" "/var/spool/cron" "/var/spool/cron/crontabs")

        for dir in "${cron_dirs[@]}"; do
            if [ -e "$dir" ]; then
                if [ -d "$dir" ]; then
                    echo -e "\n${YELLOW}Zmiany w $dir:${RESET}"
                    find "$dir" -type f -newermt "$SINCE_DATE" | while read -r file; do
                        mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                        echo "$mod_date: $file"
                        grep -v "^#" "$file" | grep -v "^$" | head -n 5
                        echo "..."
                    done
                elif [ -f "$dir" ] && [ "$(stat -c '%Y' "$dir")" -gt "$(date -d "$SINCE_DATE" +%s)" ]; then
                    echo -e "\n${YELLOW}Zmiany w $dir:${RESET}"
                    mod_date=$(stat -c '%y' "$dir" | cut -d. -f1)
                    echo "$mod_date: $dir"
                    grep -v "^#" "$dir" | grep -v "^$" | head -n 5
                    echo "..."
                fi
            fi
        done

        # Sprawdź timery systemd
        if command_exists systemctl; then
            echo -e "\n${YELLOW}Timery systemd zmienione po $SINCE_DATE:${RESET}"
            if [ -d "/etc/systemd/system" ]; then
                find "/etc/systemd/system" -name "*.timer" -type f -newermt "$SINCE_DATE" | while read -r file; do
                    mod_date=$(stat -c '%y' "$file" | cut -d. -f1)
                    timer_name=$(basename "$file")
                    echo "$mod_date: $timer_name"
                    systemctl status "$(basename "$file")" 2>/dev/null | head -n 5 || echo "Timer nieaktywny"
                done
            fi
        fi
    else
        echo -e "${RED}Śledzenie zmian nie jest włączone. Użyj opcji 'Ustaw datę śledzenia zmian'${RESET}"
    fi
}
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
# Funkcja główna
main() {
    # Inicjalizacja zmiennych śledzenia zmian
    TRACK_CHANGES=false
    SINCE_DATE="$DEFAULT_SINCE_DATE"

    # Parsowanie argumentów linii poleceń
    if [ "$#" -gt 0 ]; then
        # Tryb linii poleceń
        for arg in "$@"; do
            case $arg in
                --track-changes=*)
                    date_value="${arg#*=}"
                    if date -d "$date_value" >/dev/null 2>&1; then
                        SINCE_DATE=$(date -d "$date_value" +"%Y-%m-%d")
                        TRACK_CHANGES=true
                        echo -e "${GREEN}Data śledzenia zmian ustawiona na: ${YELLOW}$SINCE_DATE${RESET}"
                    else
                        echo -e "${RED}Nieprawidłowy format daty: $date_value${RESET}"
                        exit 1
                    fi
                    ;;
                --monthly-stats)
                    echo -e "${GREEN}Generowanie statystyk miesięcznych...${RESET}"
                    generate_monthly_stats
                    exit 0
                    ;;
                --monthly-report)
                    echo -e "${GREEN}Generowanie raportu miesięcznego...${RESET}"
                    generate_monthly_reports
                    exit 0
                    ;;
                --monthly-visualize)
                    echo -e "${GREEN}Generowanie wizualizacji miesięcznej...${RESET}"
                    visualize_monthly_changes
                    exit 0
                    ;;
                --save-all)
                    echo -e "${GREEN}Zapisywanie wszystkich informacji do pliku...${RESET}"
                    save_results
                    exit 0
                    ;;
                --help|-h)
                    display_help
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Nieznany parametr: $arg${RESET}"
                    display_help
                    exit 1
                    ;;
            esac
        done

        # Jeśli tylko śledzenie jest włączone, wyświetlamy wszystkie informacje
        if [ "$TRACK_CHANGES" = true ]; then
            get_system_info
            get_installed_packages
            get_running_services
            check_open_ports
            check_startup_programs
            find_recent_packages
            check_repositories
            check_config_changes
            track_user_changes
            track_binary_changes
            track_scheduled_tasks
            check_network_changes
            check_system_timestamps
            exit 0  # Ważne: wyjście po wyświetleniu informacji
        fi

        # Jeśli dotarliśmy tutaj, to znaczy, że nie obsłużyliśmy wszystkich argumentów
        echo -e "${RED}Błąd: Nie podano wymaganych argumentów${RESET}"
        display_help
        exit 1
    else
        # Tryb interaktywny
        echo -e "${BLUE}===== Linux Software Finder =====${RESET}"
        echo -e "${YELLOW}Ten skrypt identyfikuje zainstalowane oprogramowanie i usługi${RESET}"
        echo -e "${YELLOW}oraz śledzi zmiany w systemie od określonej daty${RESET}"

        # Sprawdź, czy skrypt jest uruchomiony jako root
        if [ "$(id -u)" != "0" ]; then
            echo -e "${RED}Uwaga: Skrypt nie jest uruchomiony jako root. Niektóre informacje mogą być niedostępne.${RESET}"
            echo -e "${YELLOW}Zalecane ponowne uruchomienie z sudo:${RESET} sudo $0\n"
            read -r -p "Kontynuować mimo to? (t/n): " -n 1 REPLY
            echo
            if [[ ! $REPLY =~ ^[Tt]$ ]]; then
                exit 1
            fi
        fi

        # Menu wyboru
        while true; do
            echo -e "\n${BLUE}===== Menu główne =====${RESET}"
            if [ "$TRACK_CHANGES" = true ]; then
                echo -e "${CYAN}Śledzenie zmian włączone od: $SINCE_DATE${RESET}"
            else
                echo -e "${YELLOW}Śledzenie zmian wyłączone${RESET}"
            fi
            echo

            echo " 1) Wyświetl wszystkie informacje"
            echo " 2) Informacje o systemie"
            echo " 3) Zainstalowane pakiety"
            echo " 4) Uruchomione usługi"
            echo " 5) Otwarte porty"
            echo " 6) Programy startowe"
            echo " 7) Ostatnio zainstalowane pakiety"
            echo " 8) Skonfigurowane repozytoria"
            echo " 9) Ustaw datę śledzenia zmian"
            echo "10) Zmiany w plikach konfiguracyjnych"
            echo "11) Zmiany w użytkownikach/grupach"
            echo "12) Zmiany w plikach binarnych"
            echo "13) Zmiany w zaplanowanych zadaniach"
            echo "14) Zmiany w konfiguracji sieci"
            echo "15) Zmiany w kluczowych plikach systemowych"
            echo "16) Raport zmian miesięcznych (ostatnie 12 miesięcy)"
            echo "17) Statystyki miesięczne (ostatnie 12 miesięcy)"
            echo "18) Wizualizacja zmian miesięcznych"
            echo "19) Zapisz wszystko do pliku"
            echo "20) Pomoc"
            echo "21) Wyjście"
            echo

            read -r -p "Wybierz opcję (1-21): " choice
            echo

            case $choice in
                1)
                    get_system_info
                    get_installed_packages
                    get_running_services
                    check_open_ports
                    check_startup_programs
                    find_recent_packages
                    check_repositories
                    if [ "$TRACK_CHANGES" = true ]; then
                        check_config_changes
                        track_user_changes
                        track_binary_changes
                        track_scheduled_tasks
                        check_network_changes
                        check_system_timestamps
                    fi
                    ;;
                2)
                    get_system_info
                    ;;
                3)
                    get_installed_packages
                    ;;
                4)
                    get_running_services
                    ;;
                5)
                    check_open_ports
                    ;;
                6)
                    check_startup_programs
                    ;;
                7)
                    find_recent_packages
                    ;;
                8)
                    check_repositories
                    ;;
                9)
                    set_tracking_date
                    ;;
                10)
                    check_config_changes
                    ;;
                11)
                    track_user_changes
                    ;;
                12)
                    track_binary_changes
                    ;;
                13)
                    track_scheduled_tasks
                    ;;
                14)
                    check_network_changes
                    ;;
                15)
                    check_system_timestamps
                    ;;
                16)
                    generate_monthly_reports
                    ;;
                17)
                    generate_monthly_stats
                    ;;
                18)
                    visualize_monthly_changes
                    ;;
                19)
                    save_results
                    ;;
                20)
                    display_help
                    ;;
                21)
                    echo -e "${GREEN}Do widzenia!${RESET}"
                    exit 0
                    ;;
                *)
                    echo -e "${RED}Nieprawidłowa opcja. Wybierz liczbę od 1 do 21.${RESET}"
                    ;;
            esac

            echo -e "\n${YELLOW}Naciśnij Enter, aby kontynuować...${RESET}"
            read -r
        done
    fi
}

# Funkcja pomocy
display_help() {
    echo -e "${BLUE}===== Linux Software Finder - Pomoc =====${RESET}"
    echo -e "${GREEN}Użycie:${RESET}"
    echo -e "  $0 [opcje]"
    echo
    echo -e "${GREEN}Opcje:${RESET}"
    echo -e "  --track-changes=DATA     Ustaw datę śledzenia zmian"
    echo -e "                           Przykłady:"
    echo -e "                           --track-changes=\"1 month ago\""
    echo -e "                           --track-changes=\"2023-01-15\""
    echo -e "  --monthly-stats          Generuj statystyki miesięczne"
    echo -e "  --monthly-report         Generuj szczegółowy raport miesięczny"
    echo -e "  --monthly-visualize      Generuj wizualizację miesięcznych zmian"
    echo -e "  --save-all               Zapisz wszystkie wyniki do pliku"
    echo -e "  --help, -h               Wyświetl tę pomoc"
    echo
    echo -e "${GREEN}Przykłady:${RESET}"
    echo -e "  sudo $0 --track-changes=\"7 days ago\""
    echo -e "  sudo $0 --monthly-stats"
    echo -e "  sudo $0 --save-all"
    echo
}

# Uruchom program
main "$@"
# Thu Apr  3 12:47:27 PM CEST 2025
