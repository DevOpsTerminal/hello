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

                        # Wyświetl wszystkie informacje z śledzeniem zmian
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
                    else
                        echo -e "${RED}Nieprawidłowy format daty: $date_value${RESET}"
                    fi
                    exit 0
                    ;;
                --monthly-stats)
                    generate_monthly_stats
                    exit 0
                    ;;
                --monthly-report)
                    generate_monthly_reports
                    exit 0
                    ;;
                --monthly-visualize)
                    visualize_monthly_changes
                    exit 0
                    ;;
                --save-all)
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

        exit 0
    else
        # Tryb interaktywny
        run_interactive_menu
    fi
}

# Funkcja uruchamiająca interaktywne menu
run_interactive_menu() {
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

    # Menu będzie działać aż do jawnego wyjścia
    while true; do
        # Wyczyść ekran dla lepszej czytelności
        clear

        echo -e "${BLUE}===== Menu główne =====${RESET}"
        if [ "$TRACK_CHANGES" = true ]; then
            echo -e "${CYAN}Śledzenie zmian włączone od: $SINCE_DATE${RESET}"
        else
            echo -e "${YELLOW}Śledzenie zmian wyłączone${RESET}"
        fi
        echo

        # Wypisz menu opcji
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

        # Odczytaj wybór użytkownika
        read -r -p "Wybierz opcję (1-21): " choice

        # Obsłuż wybór użytkownika
        case $choice in
            1)  # Wyświetl wszystkie informacje
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
            2)  # Informacje o systemie
                get_system_info
                ;;
            3)  # Zainstalowane pakiety
                get_installed_packages
                ;;
            4)  # Uruchomione usługi
                get_running_services
                ;;
            5)  # Otwarte porty
                check_open_ports
                ;;
            6)  # Programy startowe
                check_startup_programs
                ;;
            7)  # Ostatnio zainstalowane pakiety
                find_recent_packages
                ;;
            8)  # Skonfigurowane repozytoria
                check_repositories
                ;;
            9)  # Ustaw datę śledzenia zmian
                set_tracking_date
                ;;
            10) # Zmiany w plikach konfiguracyjnych
                check_config_changes
                ;;
            11) # Zmiany w użytkownikach/grupach
                track_user_changes
                ;;
            12) # Zmiany w plikach binarnych
                track_binary_changes
                ;;
            13) # Zmiany w zaplanowanych zadaniach
                track_scheduled_tasks
                ;;
            14) # Zmiany w konfiguracji sieci
                check_network_changes
                ;;
            15) # Zmiany w kluczowych plikach systemowych
                check_system_timestamps
                ;;
            16) # Raport zmian miesięcznych
                generate_monthly_reports
                ;;
            17) # Statystyki miesięczne
                generate_monthly_stats
                ;;
            18) # Wizualizacja zmian miesięcznych
                visualize_monthly_changes
                ;;
            19) # Zapisz wszystko do pliku
                save_results
                ;;
            20) # Pomoc
                display_help
                ;;
            21) # Wyjście
                echo -e "${GREEN}Do widzenia!${RESET}"
                exit 0
                ;;
            *)  # Nieprawidłowa opcja
                echo -e "${RED}Nieprawidłowa opcja. Wybierz liczbę od 1 do 21.${RESET}"
                ;;
        esac

        # Pauza po każdej operacji aby użytkownik mógł przeczytać wyniki
        echo
        read -r -p "${YELLOW}Naciśnij Enter, aby kontynuować...${RESET}" dummy
    done
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