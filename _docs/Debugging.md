# Debugowanie i Testowanie Skryptów

Ze względu na brak wbudowanego debuggera z możliwością stawiania breakpointów, testowanie logiki w silniku Polan II opiera się na skryptach testowych i wypisywaniu wartości na ekran.

## 1. Tworzenie czystego skryptu testowego

**najlepiej stworzyć czysty skrypt testowy od nowa**, bazując na najprostszym trybie gry.

**Kroki:**

1. Skopiuj zawartość pliku `gametypes/DestroyEnemyStructures.ec`. Jest to najczystszy i najprostszy działający szablon misji.
2. Wklej go do nowego pliku (np. `gametypes/MyTest.ec).
3. Zmień nagłówek misji w pierwszej linijce na własny, np.:
   ```c
   mission "Test" // zamiast "translateGameTypeDestroyStructures"
   ```
4. Dodaj swój kod testowy:
   - W `state Initialize` – do jednorazowego spawnowania jednostek, budynków (np. `CreateUnitAtMarker`).
   - W `event Timer0()` – do cyklicznego sprawdzania warunków i wypisywania zmiennych.

## 2. Wypisywanie zmiennych na ekran (Printowanie)

Jak wspomniano w innych dokumentach, wbudowane funkcje `Trace`, `TraceD` i `TraceF` **nie działają** (nie wypisują niczego do logów ani na ekran).

Jedynym skutecznym sposobem na podgląd zmiennych w czasie rzeczywistym jest użycie buforów tekstowych i funkcji `SetConsoleText`, która wyświetla tekst w lewym górnym rogu ekranu gry.

**Wzorzec debug-printa:**

```c
// 1. Formatujemy tekst z użyciem zmiennych (np. %d dla int) i zapisujemy do bufora roboczego (np. 0)
SetStringBuff(0, "Moja zmienna: %d, HP: %d", iMojaZmienna, uUnit.GetHP());

// 2. Wypisujemy zawartość bufora na ekran
SetConsoleText(GetStringBuff(0));
```

**Ważne uwagi do printowania:**

- `SetConsoleText` nadpisuje komunikaty - zawsze jest widoczne ostatnie wywołanie
- Możesz używać wielu buforów i łączyć je za pomocą `GetStringBuff`, jeśli potrzebujesz złożyć bardzo skomplikowany log (patrz `CLAUDE.md` sekcja o stringach).
- Funkcja przyjmuje formatowanie w stylu `printf`, ale obsługuje głównie `%d` (dla liczb całkowitych) i `%s` (dla innych stringów/buforów). Nie ma typu `float`, więc nie używaj `%f`.
