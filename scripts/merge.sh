#!/bin/bash

# Skrypt do łączenia wszystkich plików funkcji w jeden plik wykonawczy

# Lokalizacja plików
MAIN_DIR="main"
FUNCTIONS_DIR="src"
OUTPUT_FILE="hello.sh"

# Nagłówek pliku
cat > "$OUTPUT_FILE" << 'EOF'
#!/bin/bash

# Linux Software Finder
# Skrypt do wyszukiwania zainstalowanego oprogramowania i usług na systemach Linux
# Działa na różnych dystrybucjach (Ubuntu, Debian, Fedora, itp.)
# Umożliwia śledzenie zmian w systemie od określonej daty

EOF

# Dodaj plik konfiguracyjny (kolorów)
if [ -f "$MAIN_DIR/colors.sh" ]; then
    echo "Dodawanie konfiguracji kolorów..."
    cat "$MAIN_DIR/colors.sh" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"  # Dodaj pustą linię dla przejrzystości
fi

# Dodaj zmienne domyślne
if [ -f "$MAIN_DIR/defaults.sh" ]; then
    echo "Dodawanie zmiennych domyślnych..."
    cat "$MAIN_DIR/defaults.sh" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"  # Dodaj pustą linię dla przejrzystości
fi

# Dodaj wszystkie funkcje
echo "Dodawanie funkcji..."
for func_file in "$FUNCTIONS_DIR"/*.sh; do
    if [ -f "$func_file" ]; then
        echo "  Dodawanie $(basename "$func_file")..."
        cat "$func_file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"  # Dodaj pustą linię dla przejrzystości
    fi
done

# Dodaj główny kod programu
if [ -f "$MAIN_DIR/main.sh" ]; then
    echo "Dodawanie głównego kodu programu..."
    cat "$MAIN_DIR/main.sh" >> "$OUTPUT_FILE"
fi

# Ustaw uprawnienia wykonywania
chmod +x "$OUTPUT_FILE"

echo "Pomyślnie utworzono plik $OUTPUT_FILE"
echo "Możesz go uruchomić za pomocą ./$OUTPUT_FILE"