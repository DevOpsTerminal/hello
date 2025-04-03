# Funkcja główna
main() {
    # Inicjalizacja zmiennych śledzenia zmian
    TRACK_CHANGES=false
    SINCE_DATE="$DEFAULT_SINCE_DATE"

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
}

# Uruchom program
main