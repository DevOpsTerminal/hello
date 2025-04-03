# Funkcja do konwersji daty na uniksowy timestamp
date_to_timestamp() {
    date -d "$1" +%s
}

# Funkcja do sprawdzania, czy data jest po dacie początku śledzenia zmian
is_after_since_date() {
    local file_date="$1"
    local since_timestamp
    local file_timestamp

    since_timestamp=$(date_to_timestamp "$SINCE_DATE")
    file_timestamp=$(date_to_timestamp "$file_date")

    if [ "$file_timestamp" -ge "$since_timestamp" ]; then
        return 0  # prawda
    else
        return 1  # fałsz
    fi
}

# Funkcja sprawdzająca, czy data jest pomiędzy dwoma datami
is_date_between() {
    local check_date="$1"
    local start_date="$2"
    local end_date="$3"
    local check_timestamp
    local start_timestamp
    local end_timestamp

    check_timestamp=$(date_to_timestamp "$check_date")
    start_timestamp=$(date_to_timestamp "$start_date")
    end_timestamp=$(date_to_timestamp "$end_date")

    if [ "$check_timestamp" -ge "$start_timestamp" ] && [ "$check_timestamp" -lt "$end_timestamp" ]; then
        return 0  # prawda
    else
        return 1  # fałsz
    fi
}