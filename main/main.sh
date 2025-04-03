# Funkcja główna
main() {
    # Inicjalizacja zmiennych śledzenia zmian
    TRACK_CHANGES=false
    SINCE_DATE="$DEFAULT_SINCE_DATE"

    # Jeśli brak argumentów, wyświetl pomoc
    if [ "$#" -eq 0 ]; then
        display_help
        exit 0
    fi

    # Parsowanie argumentów linii poleceń
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --track-changes=*)
                date_value="${1#*=}"
                if date -d "$date_value" >/dev/null 2>&1; then
                    SINCE_DATE=$(date -d "$date_value" +"%Y-%m-%d")
                    TRACK_CHANGES=true
                    echo -e "${GREEN}Data śledzenia zmian ustawiona na: ${YELLOW}$SINCE_DATE${RESET}"
                    shift
                else
                    echo -e "${RED}Nieprawidłowy format daty: $date_value${RESET}"
                    exit 1
                fi
                ;;
            --system-info)
                get_system_info
                shift
                ;;
            --packages)
                get_installed_packages
                shift
                ;;
            --services)
                get_running_services
                shift
                ;;
            --ports)
                check_open_ports
                shift
                ;;
            --startup)
                check_startup_programs
                shift
                ;;
            --recent-packages)
                find_recent_packages
                shift
                ;;
            --repositories)
                check_repositories
                shift
                ;;
            --config-changes)
                check_config_changes
                shift
                ;;
            --user-changes)
                track_user_changes
                shift
                ;;
            --binary-changes)
                track_binary_changes
                shift
                ;;
            --scheduled-tasks)
                track_scheduled_tasks
                shift
                ;;
            --network-changes)
                check_network_changes
                shift
                ;;
            --system-timestamps)
                check_system_timestamps
                shift
                ;;
            --monthly-report)
                generate_monthly_reports
                shift
                ;;
            --monthly-stats)
                generate_monthly_stats
                shift
                ;;
            --monthly-visualize)
                visualize_monthly_changes
                shift
                ;;
            --save-all)
                save_results
                shift
                ;;
            --all)
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
                shift
                ;;
            --version)
                echo -e "${GREEN}Linux Software Finder v1.0${RESET}"
                echo -e "${CYAN}Copyright (c) 2023 DevOpsTerminal${RESET}"
                shift
                ;;
            --help|-h)
                display_help
                shift
                ;;
            *)
                echo -e "${RED}Nieznany parametr: $1${RESET}"
                echo -e "${YELLOW}Użyj --help aby zobaczyć dostępne opcje.${RESET}"
                exit 1
                ;;
        esac
    done

    # Jeśli włączone śledzenie zmian ale nie podano konkretnej funkcji
    if [ "$TRACK_CHANGES" = true ] && [ "$#" -eq 0 ]; then
        echo -e "${YELLOW}Podano tylko datę śledzenia zmian. Wyświetlam wszystkie informacje...${RESET}"
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
    fi

    exit 0
}

# Funkcja pomocy - szczegółowy opis dostępnych opcji
display_help() {
    echo -e "${BLUE}===========================================================${RESET}"
    echo -e "${GREEN}Linux Software Finder - narzędzie do analizy systemu Linux${RESET}"
    echo -e "${BLUE}===========================================================${RESET}"
    echo -e "${YELLOW}Wersja 1.0${RESET}"
    echo -e "Ten skrypt identyfikuje zainstalowane oprogramowanie i usługi w systemie Linux oraz umożliwia śledzenie zmian od określonej daty."
    echo
    echo -e "${CYAN}SPOSÓB UŻYCIA:${RESET}"
    echo -e "  $0 [OPCJE]"
    echo
    echo -e "${CYAN}PODSTAWOWE OPCJE:${RESET}"
    echo -e "  --help, -h               Wyświetla tę pomoc"
    echo -e "  --version                Wyświetla informacje o wersji programu"
    echo -e "  --all                    Wyświetla wszystkie dostępne informacje"
    echo -e "  --save-all               Zapisuje wszystkie wyniki do pliku"
    echo
    echo -e "${CYAN}INFORMACJE O SYSTEMIE:${RESET}"
    echo -e "  --system-info            Wyświetla podstawowe informacje o systemie"
    echo -e "  --packages               Wyświetla listę zainstalowanych pakietów"
    echo -e "  --services               Wyświetla listę uruchomionych usług"
    echo -e "  --ports                  Wyświetla listę otwartych portów"
    echo -e "  --startup                Wyświetla listę programów uruchamianych przy starcie"
    echo -e "  --recent-packages        Wyświetla ostatnio zainstalowane pakiety"
    echo -e "  --repositories           Wyświetla skonfigurowane repozytoria"
    echo
    echo -e "${CYAN}ŚLEDZENIE ZMIAN:${RESET}"
    echo -e "  --track-changes=DATA     Ustawia datę śledzenia zmian"
    echo -e "                           Przykłady:"
    echo -e "                           --track-changes=\"1 month ago\""
    echo -e "                           --track-changes=\"2023-01-15\""
    echo -e "  --config-changes         Wyświetla zmiany w plikach konfiguracyjnych"
    echo -e "  --user-changes           Wyświetla zmiany w użytkownikach i grupach"
    echo -e "  --binary-changes         Wyświetla zmiany w plikach binarnych"
    echo -e "  --scheduled-tasks        Wyświetla zmiany w zaplanowanych zadaniach"
    echo -e "  --network-changes        Wyświetla zmiany w konfiguracji sieci"
    echo -e "  --system-timestamps      Wyświetla zmiany w kluczowych plikach systemowych"
    echo
    echo -e "${CYAN}RAPORTY MIESIĘCZNE:${RESET}"
    echo -e "  --monthly-report         Generuje szczegółowy raport miesięczny"
    echo -e "  --monthly-stats          Generuje statystyki miesięczne"
    echo -e "  --monthly-visualize      Generuje wizualizację miesięcznych zmian"
    echo
    echo -e "${CYAN}PRZYKŁADY UŻYCIA:${RESET}"
    echo -e "  # Wyświetlenie podstawowych informacji o systemie:"
    echo -e "  sudo $0 --system-info"
    echo
    echo -e "  # Wyświetlenie wszystkich informacji z śledzeniem zmian od tygodnia:"
    echo -e "  sudo $0 --track-changes=\"1 week ago\" --all"
    echo
    echo -e "  # Wygenerowanie statystyk miesięcznych i zapisanie ich do pliku:"
    echo -e "  sudo $0 --monthly-stats --save-all"
    echo
    echo -e "  # Sprawdzenie zmian w plikach konfiguracyjnych od konkretnej daty:"
    echo -e "  sudo $0 --track-changes=\"2023-06-01\" --config-changes"
    echo
    echo -e "${CYAN}UWAGI:${RESET}"
    echo -e "  - Niektóre funkcje wymagają uprawnień roota (sudo)."
    echo -e "  - Aby wyświetlić zmiany, należy użyć opcji --track-changes wraz z odpowiednią datą."
    echo -e "  - Można łączyć wiele opcji w jednym poleceniu."
    echo -e "  - Wyniki można zapisać do pliku za pomocą opcji --save-all."
    echo
    echo -e "${BLUE}===========================================================${RESET}"
}

# Uruchom program
main "$@"