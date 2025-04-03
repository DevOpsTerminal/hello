# Funkcja główna
main() {
    # Inicjalizacja zmiennych śledzenia zmian
    TRACK_CHANGES=false
    SINCE_DATE="$DEFAULT_SINCE_DATE"
    RUN_GUI=true  # Domyślnie uruchamiamy interfejs użytkownika

    # Parsowanie argumentów linii poleceń
    if [ "$#" -gt 0 ]; then
        RUN_GUI=false  # Jeśli są argumenty, nie uruchamiamy GUI

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
    fi

    # Sprawdź, czy skrypt jest uruchomiony jako root - tylko w trybie interaktywnym
    if [ "$RUN_GUI" = true ] && [ "$(id -u)" != "0" ]; then
        echo -e "${RED}Uwaga: Skrypt nie jest uruchomiony jako root. Niektóre informacje mogą być niedostępne.${RESET}"
        echo -e "${YELLOW}Zalecane ponowne uruchomienie z sudo:${RESET} sudo $0\n"
        read -r -p "Kontynuować mimo to? (t/n): " -n 1 REPLY
        echo
        if [[ ! $REPLY =~ ^[Tt]$ ]]; then
            exit 1
        fi
    fi

    # Interfejs użytkownika (tylko gdy nie ma argumentów i RUN_GUI=true)
    if [ "$RUN_GUI" = true ]; then
        echo -e "${BLUE}===== Linux Software Finder =====${RESET}"
        echo -e "${YELLOW}Ten skrypt identyfikuje zainstalowane oprogramowanie i usługi${RESET}"
        echo -e "${YELLOW}oraz śledzi zmiany w systemie od określonej daty${RESET}"

        # Menu wyboru
        while true; do
            echo -e "\n${BLUE}===== Menu główne =====${RESET}"
            if [ "$TRACK_CHANGES" = true ]; then
                echo -e "${CYAN}Śledzenie zmian włączone od: $SINCE_DATE${RESET}"
            else
                echo -e "${YELLOW}Śledzenie zmian wyłączone${RESET}"
            fi
            echo

            PS3="Wybierz opcję: "
            options=("Wyświetl wszystkie informacje"
                    "Informacje o systemie"
                    "Zainstalowane pakiety"
                    "Uruchomione usługi"
                    "Otwarte porty"
                    "Programy startowe"
                    "Ostatnio zainstalowane pakiety"
                    "Skonfigurowane repozytoria"
                    "Ustaw datę śledzenia zmian"
                    "Zmiany w plikach konfiguracyjnych"
                    "Zmiany w użytkownikach/grupach"
                    "Zmiany w plikach binarnych"
                    "Zmiany w zaplanowanych zadaniach"
                    "Zmiany w konfiguracji sieci"
                    "Zmiany w kluczowych plikach systemowych"
                    "Raport zmian miesięcznych (ostatnie 12 miesięcy)"
                    "Statystyki miesięczne (ostatnie 12 miesięcy)"
                    "Wizualizacja zmian miesięcznych"
                    "Zapisz wszystko do pliku"
                    "Pomoc"
                    "Wyjście")

            select opt in "${options[@]}"
            do
                case $opt in
                    "Wyświetl wszystkie informacje")
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
                        break
                        ;;
                    "Informacje o systemie")
                        get_system_info
                        break
                        ;;
                    "Zainstalowane pakiety")
                        get_installed_packages
                        break
                        ;;
                    "Uruchomione usługi")
                        get_running_services
                        break
                        ;;
                    "Otwarte porty")
                        check_open_ports
                        break
                        ;;
                    "Programy startowe")
                        check_startup_programs
                        break
                        ;;
                    "Ostatnio zainstalowane pakiety")
                        find_recent_packages
                        break
                        ;;
                    "Skonfigurowane repozytoria")
                        check_repositories
                        break
                        ;;
                    "Ustaw datę śledzenia zmian")
                        set_tracking_date
                        break
                        ;;
                    "Zmiany w plikach konfiguracyjnych")
                        check_config_changes
                        break
                        ;;
                    "Zmiany w użytkownikach/grupach")
                        track_user_changes
                        break
                        ;;
                    "Zmiany w plikach binarnych")
                        track_binary_changes
                        break
                        ;;
                    "Zmiany w zaplanowanych zadaniach")
                        track_scheduled_tasks
                        break
                        ;;
                    "Zmiany w konfiguracji sieci")
                        check_network_changes
                        break
                        ;;
                    "Zmiany w kluczowych plikach systemowych")
                        check_system_timestamps
                        break
                        ;;
                    "Raport zmian miesięcznych (ostatnie 12 miesięcy)")
                        generate_monthly_reports
                        break
                        ;;
                    "Statystyki miesięczne (ostatnie 12 miesięcy)")
                        generate_monthly_stats
                        break
                        ;;
                    "Wizualizacja zmian miesięcznych")
                        visualize_monthly_changes
                        break
                        ;;
                    "Zapisz wszystko do pliku")
                        save_results
                        break
                        ;;
                    "Pomoc")
                        display_help
                        break
                        ;;
                    "Wyjście")
                        exit 0
                        ;;
                    *)
                        echo "Nieprawidłowa opcja $REPLY"
                        break
                        ;;
                esac
            done

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