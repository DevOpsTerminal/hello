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