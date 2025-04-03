#!/bin/bash

# Katalog przechowywania sum kontrolnych
CHECKSUM_DIR="checksums"
mkdir -p "$CHECKSUM_DIR"

# Funkcja generująca sumy kontrolne
generate_checksums() {
    # Lista plików, dla których chcemy generować sumy kontrolne
    local files_to_check=(
        "hello.sh"
        # Dodaj kolejne pliki, które chcesz sprawdzać
    )

    # Czyszczenie poprzednich sum kontrolnych
    > "$CHECKSUM_DIR/checksums.sha256"

    # Generowanie sum kontrolnych
    for file in "${files_to_check[@]}"; do
        if [ -f "$file" ]; then
            sha256sum "$file" >> "$CHECKSUM_DIR/checksums.sha256"
            echo "Wygenerowano sumę kontrolną dla $file"
        else
            echo "Uwaga: Plik $file nie istnieje"
        fi
    done

    # Wyświetlenie sum kontrolnych
    cat "$CHECKSUM_DIR/checksums.sha256"
}

# Funkcja weryfikująca sumy kontrolne
verify_checksums() {
    echo "Weryfikacja sum kontrolnych:"
    if [ -f "$CHECKSUM_DIR/checksums.sha256" ]; then
        sha256sum -c "$CHECKSUM_DIR/checksums.sha256"
    else
        echo "Nie znaleziono pliku sum kontrolnych"
        return 1
    fi
}

# Obsługa argumentów
case "$1" in
    generate)
        generate_checksums
        ;;
    verify)
        verify_checksums
        ;;
    *)
        echo "Użycie: $0 {generate|verify}"
        exit 1
        ;;
esac

exit 0