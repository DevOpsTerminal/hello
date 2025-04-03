# Wykryj dystrybucję
detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        echo "$NAME"
    elif [ -f /etc/lsb-release ]; then
        # shellcheck source=/dev/null
        . /etc/lsb-release
        echo "$DISTRIB_ID"
    elif [ -f /etc/debian_version ]; then
        echo "Debian"
    elif [ -f /etc/fedora-release ]; then
        echo "Fedora"
    elif [ -f /etc/redhat-release ]; then
        echo "RedHat/CentOS"
    else
        echo "Nieznana dystrybucja"
    fi
}