#!/bin/bash

# Konfiguracja źródeł
PROJECT_BASE_URL="https://raw.githubusercontent.com/DevOpsTerminal/hello/main"
SCRIPT_NAME="hello.sh"
CHECKSUM_FILE="checksums/checksums.sha256"

# Domyślna ścieżka instalacji
INSTALL_DIR="/usr/local/bin"
COMMAND_NAME="hello"

# Funkcje logowania z kolorami
log_error() {
    echo -e "\e[31m[BŁĄD]\e[0m $1" >&2
}

log_success() {
    echo -e "\e[32m[SUKCES]\e[0m $1"
}

log_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Funkcja sprawdzająca uprawnienia roota
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "Ten skrypt wymaga uprawnień administratora (root)."
        log_error "Użyj 'sudo' przed poleceniem."
        return 1
    fi
    return 0
}

# Funkcja pobierająca sumę kontrolną
fetch_checksum() {
    local urls=(
        "${PROJECT_BASE_URL}/${CHECKSUM_FILE}"
        "https://hello.devopsterminal.com/${CHECKSUM_FILE}"
    )

    for url in "${urls[@]}"; do
        log_info "Próba pobrania sumy kontrolnej z: $url"
        local output=$(curl -sSL "$url" 2>/dev/null)
        local checksum=$(echo "$output" | grep -E "hello\.sh\s*$" | awk '{print $1}')

        if [ -n "$checksum" ]; then
            echo "$checksum"
            return 0
        fi
    done

    log_error "Nie znaleziono sumy kontrolnej"
    return 1
}

# Funkcja pobierająca skrypt
fetch_script() {
    local urls=(
        "${PROJECT_BASE_URL}/${SCRIPT_NAME}"
        "https://hello.devopsterminal.com/${SCRIPT_NAME}"
    )

    for url in "${urls[@]}"; do
        log_info "Próba pobrania skryptu z: $url"
        if curl -sSL "$url" -o "${SCRIPT_NAME}" 2>/dev/null; then
            return 0
        fi
    done

    log_error "Nie udało się pobrać skryptu"
    return 1
}

# Główna funkcja instalacji
install_command() {
    # Sprawdź sumę kontrolną
    local remote_checksum=$(fetch_checksum)
    if [ $? -ne 0 ]; then
        log_error "Błąd pobierania sumy kontrolnej"
        return 1
    fi

    # Usuń białe znaki z sumy kontrolnej
    remote_checksum=$(echo "$remote_checksum" | tr -d '[:space:]')
    log_info "Pobrana suma kontrolna: $remote_checksum"

    # Pobierz skrypt
    if ! fetch_script; then
        log_error "Błąd pobierania skryptu"
        return 1
    fi

    # Sprawdź sumę kontrolną
    log_info "Weryfikacja sumy kontrolnej..."
    local local_checksum=$(sha256sum "${SCRIPT_NAME}" | awk '{print $1}')

    log_info "Suma kontrolna zdalna:  $remote_checksum"
    log_info "Suma kontrolna lokalna: $local_checksum"

    # Porównaj sumy kontrolne
    if [ "$remote_checksum" != "$local_checksum" ]; then
        log_error "Suma kontrolna nie zgadza się!"
        return 1
    fi

    # Skopiuj skrypt do globalnej lokalizacji i zmień nazwę
    cp "${SCRIPT_NAME}" "${INSTALL_DIR}/${COMMAND_NAME}"
    chmod +x "${INSTALL_DIR}/${COMMAND_NAME}"

    # Usuń tymczasowy plik
    rm "${SCRIPT_NAME}"

    log_success "Komenda 'hello' została zainstalowana w ${INSTALL_DIR}/${COMMAND_NAME}"

    # Wyświetl help
    log_info "Wyświetlanie informacji pomocy:"
    "${INSTALL_DIR}/${COMMAND_NAME}" help
}

# Główna logika
main() {
    # Sprawdź uprawnienia roota
    check_root || return 1

    # Sprawdź wymagane narzędzia
    for tool in curl sha256sum; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Wymagane narzędzie $tool nie jest zainstalowane!"
            return 1
        fi
    done

    # Wykonaj instalację
    if install_command; then
        log_success "Instalacja zakończona sukcesem!"
        return 0
    else
        log_error "Instalacja nie powiodła się!"
        return 1
    fi
}

# Uruchom główną funkcję
main