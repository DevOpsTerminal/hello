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