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