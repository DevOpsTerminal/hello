#!/bin/bash

# Konfiguracja źródeł
PROJECT_BASE_URL="https://raw.githubusercontent.com/DevOpsTerminal/hello/main"
SCRIPT_NAME="hello.sh"
CHECKSUM_FILE="checksums/checksums.sha256"

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

# Funkcja pobierająca sumę kontrolną
fetch_checksum() {
    local urls=(
        "${PROJECT_BASE_URL}/${CHECKSUM_FILE}"
        "https://hello.devopsterminal.com/${CHECKSUM_FILE}"
    )

    for url in "${urls[@]}"; do
        log_info "Próba pobrania sumy kontrolnej z: $url"
        local checksum=$(curl -sSL "$url" 2>/dev/null | grep -E "hello\.sh\s*$" | awk '{print $1}')

        if [ -n "$checksum" ]; then
            echo "$checksum"
            return 0
        fi
    done

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

    return 1
}

# Funkcja pobierająca i weryfikująca sumę kontrolną
download_and_verify() {
    # Pobierz sumę kontrolną
    local remote_checksum
    if ! remote_checksum=$(fetch_checksum 2>&1 | grep -v '\[INFO\]'); then
        log_error "Nie udało się pobrać sumy kontrolnej z żadnego źródła!"
        return 1
    fi

    # Usuń białe znaki z sumy kontrolnej
    remote_checksum=$(echo "$remote_checksum" | tr -d '[:space:]')

    # Pobierz skrypt
    if ! fetch_script 2>&1 | grep -q '\[INFO\]'; then
        log_error "Nie udało się pobrać skryptu z żadnego źródła!"
        return 1
    fi

    # Sprawdź sumę kontrolną
    log_info "Weryfikacja sumy kontrolnej..."
    local local_checksum=$(sha256sum "${SCRIPT_NAME}" | awk '{print $1}')

    # Debugowanie
    log_info "Suma kontrolna zdalna:  $remote_checksum"
    log_info "Suma kontrolna lokalna: $local_checksum"

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