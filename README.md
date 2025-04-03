# DevOpsTerminal - Hello System Scanner

![DevOpsTerminal Logo](https://github.com/DevOpsTerminal/hello/raw/main/assets/logo.png)

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

---

<p align="center">
  Tworzony z ❤️ przez zespół <a href="https://devopsterminal.com">DevOpsTerminal</a>
</p>
<p align="center">
  © 2023-2025 DevOpsTerminal. Wszelkie prawa zastrzeżone.
</p>