#!/bin/bash

# Adres projektu i główny skrypt
PROJECT_URL="https://raw.githubusercontent.com/DevOpsTerminal/hello/main"
SCRIPT_NAME="hello.sh"
CHECKSUM_NAME="checksums.sha256"

# Funkcja do logowania z kolorami
log_error() {
    echo -e "\e[31m[BŁĄD]\e[0m $1" >&2
}

log_success() {
    echo -e "\e[32m[SUKCES]\e[0m $1"
}

log_info() {
    echo -e "\e[34m[INFO]\e[0m $1"
}

# Funkcja pobierająca i weryfikująca sumę kontrolną
download_and_verify() {
    # Pobierz sumę kontrolną
    log_info "Pobieranie sumy kontrolnej..."
    local remote_checksum=$(curl -sSL "${PROJECT_URL}/${CHECKSUM_NAME}" | grep "${SCRIPT_NAME}" | awk '{print $1}')

    if [ -z "$remote_checksum" ]; then
        log_error "Nie udało się pobrać sumy kontrolnej!"
        return 1
    fi

    # Pobierz skrypt
    log_info "Pobieranie skryptu instalacyjnego..."
    curl -sSL "${PROJECT_URL}/${SCRIPT_NAME}" > "${SCRIPT_NAME}"

    # Sprawdź sumę kontrolną
    log_info "Weryfikacja sumy kontrolnej..."
    local local_checksum=$(sha256sum "${SCRIPT_NAME}" | awk '{print $1}')

    if [ "$remote_checksum" != "$local_checksum" ]; then
        log_error "OSTRZEŻENIE: Suma kontrolna nie zgadza się!"
        log_error "Suma zdalna:  $remote_checksum"
        log_error "Suma lokalna: $local_checksum"
        rm "${SCRIPT_NAME}"
        return 1
    fi

    # Nadaj uprawnienia wykonania
    chmod +x "${SCRIPT_NAME}"
    log_success "Suma kontrolna zweryfikowana poprawnie!"

    # Uruchom skrypt
    log_info "Uruchamianie skryptu..."
    ./"${SCRIPT_NAME}"
}

# Główna logika
main() {
    # Sprawdź wymagane narzędzia
    for tool in curl sha256sum; do
        if ! command -v "$tool" &> /dev/null; then
            log_error "Wymagane narzędzie $tool nie jest zainstalowane!"
            exit 1
        fi
    done

    # Wykonaj pobieranie i weryfikację
    if download_and_verify; then
        log_success "Instalacja zakończona sukcesem!"
        exit 0
    else
        log_error "Instalacja nie powiodła się!"
        exit 1
    fi
}

# Uruchom główną funkcję
main