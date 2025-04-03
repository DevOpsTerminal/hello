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
        local output=$(curl -sSL "$url" 2>/dev/null)
        local checksum=$(echo "$output" | grep -E "hello\.sh\s*$" | awk '{print $1}')

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
        if curl -sSL "$url" -o "${SCRIPT_NAME}" 2>/dev/null; then
            return 0
        fi
    done

    return 1
}

# Funkcja pobierająca i weryfikująca sumę kontrolną
download_and_verify() {
    local log_output=""
    local error_output=""
    local success=0

    # Pobierz sumę kontrolną
    local remote_checksum
    {
        if ! remote_checksum=$(fetch_checksum); then
            error_output+="Nie udało się pobrać sumy kontrolnej z żadnego źródła!\n"
            success=1
        fi
    } 2>&1 | while read -r line; do
        log_output+="$line\n"
    done

    # Usuń białe znaki z sumy kontrolnej
    remote_checksum=$(echo "$remote_checksum" | tr -d '[:space:]')

    # Pobierz skrypt
    {
        if ! fetch_script; then
            error_output+="Nie udało się pobrać skryptu z żadnego źródła!\n"
            success=1
        fi
    } 2>&1 | while read -r line; do
        log_output+="$line\n"
    done

    # Sprawdź sumę kontrolną
    local local_checksum=$(sha256sum "${SCRIPT_NAME}" | awk '{print $1}')

    # Dodaj informacje o sumach kontrolnych do logów
    log_output+="Suma kontrolna zdalna:  $remote_checksum\n"
    log_output+="Suma kontrolna lokalna: $local_checksum\n"

    # Porównaj sumy kontrolne
    if [ "$remote_checksum" != "$local_checksum" ]; then
        error_output+="OSTRZEŻENIE: Suma kontrolna nie zgadza się!\n"
        error_output+="Suma zdalna:  $remote_checksum\n"
        error_output+="Suma lokalna: $local_checksum\n"
        rm "${SCRIPT_NAME}"
        success=1
    fi

    # Zwróć wyniki
    echo -e "$log_output"
    echo -e "$error_output" >&2
    return $success
}

# Główna logika
main() {
    local log_output=""
    local error_output=""
    local success=0

    # Sprawdź wymagane narzędzia
    for tool in curl sha256sum; do
        if ! command -v "$tool" &> /dev/null; then
            error_output+="Wymagane narzędzie $tool nie jest zainstalowane!\n"
            success=1
        fi
    done

    # Wykonaj pobieranie i weryfikację
    if [ $success -eq 0 ]; then
        {
            if download_and_verify; then
                log_output+="Instalacja zakończona sukcesem!\n"
            else
                error_output+="Instalacja nie powiodła się!\n"
                success=1
            fi
        } 2>&1 | while read -r line; do
            log_output+="$line\n"
        done
    fi

    # Wyświetl logi
    echo -e "$log_output"
    echo -e "$error_output" >&2

    return $success
}

# Uruchom główną funkcję
main