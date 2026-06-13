# Specyficzne i zepsute funkcje silnika

Silnik gry posiada szereg funkcji, które są udokumentowane w `_manual/`, ale w praktyce nie działają, zwracają śmieci, lub ich zachowanie jest bardzo specyficzne i nieintuicyjne.

## 1. Funkcje o specyficznym / nieudokumentowanym działaniu

### `unit.ChangePlayer()`
- **Działanie:** Zmienia właściciela (gracza) danej jednostki w trakcie gry.
- **Haczyk:** Wywołanie tej funkcji powoduje zauważalny mikro-lag (zacięcie gry na ok. 0.1-0.2 sekundy). Wynika to z faktu, że silnik musi w jednej klatce przeliczyć na nowo mgłę wojny (Fog of War) dla nowej jednostki, zaktualizować listy celów dla AI wszystkich graczy, odświeżyć minimapę i zresetować pathfinding.
- **Zastosowanie:** Należy mieć świadomość, że masowe lub częste przekazywanie jednostek tą funkcją będzie powodować "klatkowanie" gry. Nie da się tego obejść z poziomu skryptów.

### `unit.GetBuildingType()`
- **Działanie:** Zwraca typ budynku na podstawie wbudowanych stałych (np. `buildingTower`, `buildingGate`, `buildingWall`).
- **Haczyk:** Funkcja ta **wykrywa tylko budynki obronne** (wieże, bramy, palisady/mury). Nie wykrywa budynków produkcyjnych czy ekonomicznych (np. chata drwala, chata wojów, obora) - dla nich nie zwraca użytecznych wartości pozwalających na ich rozróżnienie.
- **Zastosowanie:** Jest to idealne do bezpiecznej identyfikacji struktur obronnych. Wcześniej używano do tego sprawdzania maksymalnego HP (`GetMaxHP() == 1200`), co psuło się w momencie dodania mechanik modyfikujących zdrowie budynków (np. artefakty z bonusem do HP).

## 2. Czarna lista - funkcje zepsute lub bezużyteczne

| Funkcja | Problem | Obejście |
|---------|---------|----------|
| `player.GetName()` | Zwraca śmieci / pusty string. | Zapisuj czytelną nazwę samodzielnie w skrypcie, albo używaj `GetSideColor()` + `SetBufferSideColorName` do etykiet. |
| `unit.GetName()` / `unitex.GetName()` | Jw. – nie zwraca nic użytecznego. | Operuj na ID (stringu) używanym przy tworzeniu lub `GetNumberOfUnits("ID")`. |
| `object.Trace(...)`, `TraceD`, `TraceF` | Nie ma ich gdzie oglądać – nie wypisują do konsoli gry ani do pliku. | **Jedyny działający debug-print to `SetConsoleText(GetStringBuff(0))`.** |
| `Rand(n)` (wbudowany) | Skośny – rozkład nie jest równomierny. | Używaj `RandXor(n)` z `gametypes/Common/Math.ech`. |

*Jeśli znajdziesz kolejną „martwą” lub dziwnie działającą funkcję – dopisz ją tutaj razem z obejściem. To jest najcenniejsza wiedza w tym repo, bo nie stoi w żadnym oficjalnym manualu.*