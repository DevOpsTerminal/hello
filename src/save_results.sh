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