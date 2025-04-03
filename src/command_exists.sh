# Funkcja do sprawdzania dostępności polecenia
command_exists() {
    command -v "$1" &> /dev/null
}