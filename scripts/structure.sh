#!/bin/bash

# Skrypt do tworzenia struktury folderów dla projektu Linux Software Finder

# Utwórz główny katalog projektu
mkdir -p linux_software_finder
cd linux_software_finder

# Utwórz katalog dla funkcji
mkdir -p src/functions
mkdir -p src/main

# Komunikat powodzenia
echo "Struktura katalogów została utworzona pomyślnie."
echo "Katalog główny: $(pwd)"