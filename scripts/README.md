# Weryfikacja Sum Kontrolnych

## Jak używać

### Generowanie Sum Kontrolnych
```bash
# Wygeneruj sumy kontrolne
./scripts/checksum.sh generate
```

### Weryfikacja Plików
```bash
# Sprawdź integralność plików
./scripts/checksum.sh verify
```

## Dlaczego to jest bezpieczne?

1. **Automatyczne generowanie**: Skrypt automatycznie tworzy sumy kontrolne dla kluczowych plików.
2. **Łatwa weryfikacja**: Możliwość jednoczesnego sprawdzenia wszystkich plików.
3. **Bezpieczeństwo**: Zapobiega nieautoryzowanym modyfikacjom.

### Przykładowy Scenariusz Użycia

```bash
# Na serwerze/w repozytorium
./scripts/checksum.sh generate  # Generuje aktualny plik sum kontrolnych

# U użytkownika
./scripts/checksum.sh verify    # Sprawdza integralność plików
```

## Uwagi Bezpieczeństwa
- Zawsze weryfikuj źródło skryptu
- Regularnie aktualizuj sumy kontrolne
- Przechowuj plik sum kontrolnych bezpiecznie