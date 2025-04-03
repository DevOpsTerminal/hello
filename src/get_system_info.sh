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