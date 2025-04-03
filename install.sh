#!/bin/bash

# Konfiguracja źródeł
PROJECT_BASE_URL="https://raw.githubusercontent.com/DevOpsTerminal/hello/main"
SCRIPT_NAME="hello.sh"
CHECKSUM_FILE="checksums/checksums.sha256"

# Funkcja pobierająca sumę kontrolną
fetch_checksum() {
    local urls=(
        "${PROJECT_BASE_URL}/${CHECKSUM_FILE}"
        "https://hello.devopsterminal.com/${CHECKSUM_FILE}"
    )

    for url in "${urls[@]}"; do
        echo "Próba pobrania sumy kontrolnej z: $url" >&2
        local output=$(curl -sSL "$url" 2>/dev/null)
        local checksum=$(echo "$output" | grep -E "hello\.sh\s*$" | awk '{print $1}')

        if [ -n "$checksum" ]; then
            echo "$checksum"
            return 0
        fi
    done

    echo "Nie znaleziono sumy kontrolnej" >&2
    return 1
}

# Funkcja pobierająca skrypt
fetch_script() {
    local urls=(
        "${PROJECT_BASE_URL}/${SCRIPT_NAME}"
        "https://hello.devopsterminal.com/${SCRIPT_NAME}"
    )

    for url in "${urls[@]}"; do
        echo "Próba pobrania skryptu z: $url" >&2
        if curl -sSL "$url" -o "${SCRIPT_NAME}" 2>/dev/null; then
            return 0
        fi
    done

    echo "Nie udało się pobrać skryptu" >&2
    return 1
}

# Główna funkcja weryfikacji
download_and_verify() {
    # Pobierz sumę kontrolną
    local remote_checksum=$(fetch_checksum)
    if [ $? -ne 0 ]; then
        echo "Błąd pobierania sumy kontrolnej" >&2
        return 1
    fi

    # Usuń białe znaki z sumy kontrolnej
    remote_checksum=$(echo "$remote_checksum" | tr -d '[:space:]')
    echo "Pobrana suma kontrolna: $remote_checksum" >&2

    # Pobierz skrypt
    if ! fetch_script; then
        echo "Błąd pobierania skryptu" >&2
        return 1
    fi

    # Sprawdź sumę kontrolną
    echo "Weryfikacja sumy kontrolnej..." >&2
    local local_checksum=$(sha256sum "${SCRIPT_NAME}" | awk '{print $1}')

    echo "Suma kontrolna zdalna:  $remote_checksum" >&2
    echo "Suma kontrolna lokalna: $local_checksum" >&2

    # Porównaj sumy kontrolne
    if [ "$remote_checksum" != "$local_checksum" ]; then
        echo "BŁĄD: Suma kontrolna nie zgadza się!" >&2
        return 1
    fi

    # Nadaj uprawnienia wykonania
    chmod +x "${SCRIPT_NAME}"
    echo "Suma kontrolna zweryfikowana poprawnie" >&2

    # Uruchom skrypt
    echo "Uruchamianie skryptu..." >&2
    ./"${SCRIPT_NAME}"
}

# Główna logika
main() {
    # Sprawdź wymagane narzędzia
    for tool in curl sha256sum; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Wymagane narzędzie $tool nie jest zainstalowane!" >&2
            return 1
        fi
    done

    # Wykonaj pobieranie, weryfikację i uruchomienie z help
    if download_and_verify; then
        echo "Instalacja i weryfikacja zakończone sukcesem!" >&2
        return 0
    else
        echo "Instalacja nie powiodła się!" >&2
        return 1
    fi
}

# Uruchom główną funkcję
main