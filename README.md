# DevOpsTerminal - Hello System Scanner

![DevOpsTerminal Logo](https://github.com/DevOpsTerminal/hello/raw/main/assets/logo.png)

# Linux Software Finder

Skrypt do wyszukiwania zainstalowanego oprogramowania i usług na systemach Linux. Działa na różnych dystrybucjach (Ubuntu, Debian, Fedora, itp.) i umożliwia śledzenie zmian w systemie od określonej daty.

## Struktura projektu

Projekt został podzielony na wiele plików dla łatwiejszej modyfikacji i rozszerzalności:

```
hello/
├── src/
│   ├── functions/        # Katalog zawierający pliki z poszczególnymi funkcjami
│   │   ├── command_exists.sh
│   │   ├── date_timestamp.sh
│   │   ├── detect_distro.sh
│   │   └── ...
│   ├── main/             # Katalog z głównymi plikami programu
│       ├── colors.sh     # Konfiguracja kolorów
│       ├── defaults.sh   # Domyślne wartości zmiennych
│       └── main.sh       # Główna funkcja programu
├── hello.sh  # Finalny skrypt (wygenerowany)
├── create_structure.sh       # Skrypt tworzący strukturę folderów
└── merge_files.sh           # Skrypt łączący pliki w jeden skrypt wykonawczy
```

## Jak korzystać

### Rozwój i modyfikacja

1. Utwórz strukturę katalogów używając `create_structure.sh`:
   ```
   ./scripts/structure.sh
   ```

2. Modyfikuj poszczególne pliki z funkcjami w katalogu `src/functions/` lub pliki konfiguracyjne w `src/main/`.

3. Po zakończeniu modyfikacji, użyj skryptu `merge_files.sh` aby połączyć wszystkie pliki w jeden wykonawczy skrypt:
   ```
   ./scripts/merge.sh
   ```

4. Wygenerowany skrypt `hello.sh` jest gotowy do uruchomienia:
   ```
   ./hello.sh
   ```

### Używanie finalnego skryptu

Uruchom skrypt jako użytkownik root, aby uzyskać pełny dostęp do informacji o systemie:

```
sudo ./hello.sh
```

Po uruchomieniu skryptu zostanie wyświetlone menu główne z różnymi opcjami:

- Informacje o systemie
- Zainstalowane pakiety
- Uruchomione usługi
- Otwarte porty
- Programy startowe
- i wiele innych...

## Śledzenie zmian

Skrypt umożliwia śledzenie zmian w systemie od określonej daty:

1. Wybierz opcję "Ustaw datę śledzenia zmian" z menu głównego
2. Wprowadź datę w jednym z następujących formatów:
   - YYYY-MM-DD (np. 2023-01-15)
   - 'X days ago' (np. '30 days ago')
   - 'last month', 'last week', 'yesterday'

Po ustawieniu daty śledzenia, dodatkowe opcje związane ze zmianami staną się dostępne.

## Generowanie raportów

Skrypt może generować raporty i zapisywać wyniki do pliku:

1. Wybierz opcję "Zapisz wszystko do pliku" z menu głównego
2. Raport zostanie zapisany w bieżącym katalogu z nazwą zawierającą bieżącą datę i czas

## Wymagania

- System Linux (Ubuntu, Debian, Fedora, CentOS, Arch Linux, itp.)
- Bash (wersja 4.0+)
- Podstawowe narzędzia systemowe (find, grep, awk, sed, itp.)

## 🌟 Przegląd

**Hello System Scanner** (`hello.sh`) to zaawansowane narzędzie diagnostyczne dla systemów Linux, które umożliwia kompleksową analizę i śledzenie zmian w systemie. Skrypt zapewnia administratorom, specjalistom DevOps i entuzjastom Linuksa pełny wgląd w instalowane oprogramowanie, uruchomione usługi oraz zmiany systemowe w czasie.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/DevOpsTerminal/hello/blob/main/LICENSE)
[![Wsparcie](https://img.shields.io/badge/Support-Active-brightgreen.svg)](https://devopsterminal.com/support)
[![Wersja](https://img.shields.io/badge/Version-1.2.0-blue.svg)](https://github.com/DevOpsTerminal/hello/releases)

## 🚀 Funkcje kluczowe

- **Uniwersalna kompatybilność** - działa na wszystkich głównych dystrybucjach Linux (Ubuntu, Debian, Fedora, CentOS, RHEL, Arch i innych)
- **Kompleksowa analiza systemu** - wykrywanie zainstalowanego oprogramowania, usług, portów i konfiguracji
- **Śledzenie zmian w czasie** - identyfikacja zmian dokonanych w określonym czasie
- **Analiza miesięczna** - przegląd zmian w systemie miesiąc po miesiącu z ostatnich 12 miesięcy
- **Wizualizacja danych** - graficzne przedstawienie trendów w formie wykresów ASCII
- **Raportowanie** - generowanie szczegółowych raportów do dalszej analizy

## 📋 Wymagania

- System operacyjny Linux (dowolna dystrybucja)
- Uprawnienia administratora (root) dla pełnej funkcjonalności
- Bash w wersji 4.0 lub nowszej

## 🔍 Szybki start

### Instalacja

```bash
# Pobranie bezpośrednio z GitHub
curl -sSL https://github.com/DevOpsTerminal/hello/raw/main/hello.sh -o hello.sh
chmod +x hello.sh

# LUB instalacja przez instalator
curl -sSL https://devopsterminal.com/install | bash
```

### Podstawowe użycie

```bash
# Uruchomienie z pełnymi uprawnieniami
sudo ./hello.sh

# Uruchomienie interaktywnej wersji z menu
./hello.sh
```

## 💻 Przykłady użycia

### Analiza systemowa

Uzyskanie kompleksowego widoku systemu:

```bash
sudo ./hello.sh --all
```

### Śledzenie zmian od określonej daty

```bash
# Sprawdzenie zmian od ostatniego miesiąca
sudo ./hello.sh --track-changes="1 month ago"

# Sprawdzenie zmian od konkretnej daty
sudo ./hello.sh --track-changes="2023-01-15"
```

### Generowanie raportów miesięcznych

```bash
# Generowanie statystyk miesięcznych
sudo ./hello.sh --monthly-stats

# Szczegółowy raport miesięczny
sudo ./hello.sh --monthly-report

# Wizualizacja miesięcznych zmian
sudo ./hello.sh --monthly-visualize
```

### Zapisywanie wyników do pliku

```bash
sudo ./hello.sh --save-all
```

## 📈 Przykładowe wyniki

### Wykres zmian miesięcznych

```
Zainstalowane pakiety miesięcznie:

   50 │ █                                     
   45 │ █                                     
   40 │ █                                     
   35 │ █                █                    
   30 │ █     █          █                    
   25 │ █     █          █ █                  
   20 │ █     █     █    █ █                  
   15 │ █ █   █     █    █ █                  
   10 │ █ █   █ █   █    █ █ █                
    5 │ █ █ █ █ █ █ █    █ █ █ █ █            
     └────────────────────────────────────
       Sty Feb Mar Kwi Maj Cze Lip Sie Wrz Paź Lis Gru
```

### Fragment tabeli statystyk miesięcznych

```
Miesiąc         Pakiety Usługi Konfiguracje Użytkownicy Sieć
----------------------------------------------------------------------
Styczeń 2023    45      12     87           2           4
Luty 2023       12      3      24           0           1
Marzec 2023     28      5      32           1           2
```

## Examples

### 16) Raport zmian miesięcznych (ostatnie 12 miesięcy)

![16.png](img/16.png)

### 17) Statystyki miesięczne (ostatnie 12 miesięcy)

![17.png](img/18.png)


### 18) Wizualizacja zmian miesięcznych

![18.png](img/17.png)


## 🔧 Opcje zaawansowane

| Opcja                      | Opis                                            |
|----------------------------|------------------------------------------------|
| `--system-info`            | Podstawowe informacje o systemie               |
| `--packages`               | Lista zainstalowanych pakietów                 |
| `--services`               | Lista uruchomionych usług                      |
| `--ports`                  | Lista otwartych portów                         |
| `--startup`                | Programy uruchamiane na starcie                |
| `--recent-packages`        | Ostatnio zainstalowane pakiety                 |
| `--repositories`           | Skonfigurowane repozytoria                     |
| `--config-changes`         | Zmiany w plikach konfiguracyjnych              |
| `--user-changes`           | Zmiany w użytkownikach i grupach               |
| `--binary-changes`         | Zmiany w plikach binarnych i skryptach         |
| `--scheduled-tasks`        | Zmiany w zaplanowanych zadaniach               |
| `--network-changes`        | Zmiany w konfiguracji sieci                    |
| `--system-file-changes`    | Zmiany w kluczowych plikach systemowych        |

## ⚙️ Rozwiązywanie problemów

### Typowe problemy

1. **Brak uprawnień**
   ```
   Uwaga: Skrypt nie jest uruchomiony jako root. Niektóre informacje mogą być niedostępne.
   ```
   **Rozwiązanie**: Uruchom skrypt z uprawnieniami administratora (`sudo ./hello.sh`)

2. **Brak znalezionego menedżera pakietów**
   ```
   Nie znaleziono znanego menedżera pakietów
   ```
   **Rozwiązanie**: Sprawdź, czy system używa nietypowego menedżera pakietów lub skontaktuj się z pomocą techniczną.

### Kontakt i pomoc techniczna

Jeśli napotkasz problemy podczas korzystania z naszych narzędzi:

- **Dokumentacja**: [docs.devopsterminal.com](https://docs.devopsterminal.com)
- **GitHub Issues**: [github.com/DevOpsTerminal/hello/issues](https://github.com/DevOpsTerminal/hello/issues)
- **Wsparcie e-mail**: support@devopsterminal.com
- **Live Chat**: Dostępny na naszej stronie [devopsterminal.com](https://devopsterminal.com)
- **Konsultacje wideo**: Zarezerwuj sesję pomocy przez [devopsterminal.com/video-support](https://devopsterminal.com/video-support)

## 💰 Wersje i cennik

| Wersja             | Funkcje                                   | Cena              | Link                                         |
|--------------------|-----------------------------------------|-------------------|----------------------------------------------|
| **Community**      | Podstawowe skanowanie i raporty         | Darmowa           | [Pobierz](https://github.com/DevOpsTerminal/hello) |
| **Professional**   | Wszystkie funkcje + historie miesięczne | $10 USD (jednorazowo) | [Kup teraz](https://devopsterminal.com/buy) |
| **Enterprise**     | Pro + wsparcie + aktualizacje           | Kontakt           | [Zapytaj o cenę](https://devopsterminal.com/enterprise) |

### Opcje płatności
- PayPal
- Karty kredytowe
- Przelewy bankowe (tylko Enterprise)
- Kryptowaluty (BTC, ETH)

## 📜 Licencja

Ten projekt jest objęty licencją MIT - szczegóły w pliku [LICENSE](https://github.com/DevOpsTerminal/hello/blob/main/LICENSE).

## 🤝 Współpraca

Jesteśmy otwarci na współpracę! Jeśli chcesz przyczynić się do rozwoju projektu:

1. Stwórz fork repozytorium
2. Utwórz swoją gałąź funkcji (`git checkout -b feature/AmazingFeature`)
3. Zatwierdź swoje zmiany (`git commit -m 'Add some AmazingFeature'`)
4. Wypchnij do gałęzi (`git push origin feature/AmazingFeature`)
5. Otwórz Pull Request


Poniżej znajduje się lista wszystkich plików w projekcie Linux Software Finder:

### Pliki główne:
1. `hello.sh` - finalny skrypt (wygenerowany)
2. `create_structure.sh` - skrypt tworzący strukturę folderów
3. `merge_files.sh` - skrypt łączący pliki w jeden skrypt wykonawczy
4. `README.md` - dokumentacja projektu

### Katalog src/main/:
1. `src/main/colors.sh` - definicje kolorów dla interfejsu
2. `src/main/defaults.sh` - domyślne wartości zmiennych
3. `src/main/main.sh` - główna funkcja programu

### Katalog src/functions/:
1. `src/functions/print_header.sh` - funkcja wyświetlająca nagłówki
2. `src/functions/command_exists.sh` - sprawdzanie dostępności polecenia
3. `src/functions/date_timestamp.sh` - funkcje obsługi dat i czasów
4. `src/functions/detect_distro.sh` - wykrywanie dystrybucji Linux
5. `src/functions/get_system_info.sh` - pobieranie informacji o systemie
6. `src/functions/get_installed_packages.sh` - pobieranie listy zainstalowanych pakietów
7. `src/functions/get_running_services.sh` - pobieranie listy uruchomionych usług
8. `src/functions/check_open_ports.sh` - sprawdzanie otwartych portów
9. `src/functions/check_startup_programs.sh` - sprawdzanie programów startowych
10. `src/functions/check_config_changes.sh` - sprawdzanie zmian w plikach konfiguracyjnych
11. `src/functions/find_recent_packages.sh` - znajdowanie ostatnio zainstalowanych pakietów
12. `src/functions/check_repositories.sh` - sprawdzanie repozytoriów
13. `src/functions/track_user_changes.sh` - śledzenie zmian w użytkownikach i grupach
14. `src/functions/track_binary_changes.sh` - śledzenie zmian w plikach binarnych
15. `src/functions/track_scheduled_tasks.sh` - śledzenie zmian w zadaniach cron
16. `src/functions/check_network_changes.sh` - sprawdzanie zmian w konfiguracji sieci
17. `src/functions/check_system_timestamps.sh` - sprawdzanie czasów modyfikacji plików systemowych
18. `src/functions/visualize_monthly_changes.sh` - wizualizacja zmian miesięcznych
19. `src/functions/generate_monthly_stats.sh` - generowanie statystyk miesięcznych
20. `src/functions/generate_monthly_reports.sh` - generowanie raportów miesięcznych
21. `src/functions/save_results.sh` - zapisywanie wyników do pliku
22. `src/functions/set_tracking_date.sh` - ustawianie daty śledzenia zmian

Ta struktura zapewnia modułową organizację kodu, gdzie każda funkcja jest w osobnym pliku, co ułatwia utrzymanie i rozwijanie projektu.


---

<p align="center">
  Tworzony z ❤️ przez zespół <a href="https://devopsterminal.com">DevOpsTerminal</a>
</p>
<p align="center">
  © 2023-2025 DevOpsTerminal. Wszelkie prawa zastrzeżone.
</p>