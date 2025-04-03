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