# System Masek i Customowych Artefaktów (MarkerFunctions)

Silnik gry natywnie obsługuje podnoszenie tylko wbudowanych przedmiotów (np. miecze, zbroje). Aby dodać do gry całkowicie nowe "znajdźki" (np. mikstury doświadczenia, bonusy do HP budynków, pułapki), mod wykorzystuje specyficzny hack oparty na niewidzialnych artefaktach i maskach bitowych.

## 1. Jak to działa pod spodem (Hack moderski)
Zamiast tworzyć jeden obiekt, skrypt tworzy na tej samej kratce dwa elementy:
1. **Obiekt wizualny** (np. `TD_BUILDING_HP2`, `TD_EXP_ITEM`) – atrapa, którą gracz widzi na mapie.
2. **Niewidzialny wyzwalacz** (`ARTIFACT_INVISIBLE`) – to on faktycznie odpala silnikowy `event Artefact(int iArtefactNum, unitex uUnitOnArtefact, player rPlayerOnArtefact)`.

Gdy jednostka wejdzie na pole, skrypt ręcznie obsługuje całą logikę: przyznaje bonus, usuwa obiekt wizualny z mapy (`RemoveUnit()`) i odtwarza odpowiednią animację (np. cząsteczki magii), imitując w ten sposób naturalne podniesienie przedmiotu.

## 2. Magia Masek (Bitmasking)
Aby główny event wiedział, *czym* jest dany niewidzialny artefakt, modyfikujemy jego ID (piąty argument funkcji `CreateArtefact`) za pomocą operacji bitowej OR (`|`). 

Maski są zdefiniowane w `gametypes/Common/MarkerFunctions.ech`:
- **Dolne 11 bitów** (`MASK0 = 2047`) przechowuje **numer markera**. Limit 2047 markerów jest arbitralny (założony przez twórcę moda jako wystarczający) i w razie potrzeby można go rozszerzyć.
- **Górne bity** przechowują **typ akcji** (np. `MASK_EXPERIENCE = 28672`, `MASK_BUILDING_HP = 32768`).

Tworzenie wyzwalacza wygląda tak:
```c
CreateArtefact("ARTIFACT_INVISIBLE", x, y, z, MASK_BUILDING_HP | iMarker);
```

## 3. Przechwytywanie zdarzenia i Stan (Tablice Równoległe)
W pliku `gametypes/Common/MarkerFunctions/Artefact.ech` następuje odkodowanie:
1. Odczytanie typu akcji: `iMaskedArtefact = iArtefactNum & ~MASK0;`
2. Odczytanie oryginalnego markera: `iMarker = iArtefactNum & ~MASK_BUILDING_HP;`

Ponieważ silnik nie przekazuje do eventu uchwytu (handle) do obiektu wizualnego, każdy system (np. `Experience.ech`, `BuildingHp.ech`) posiada **globalne tablice równoległe**:
- `unitex uBuildingHp[]` - przechowuje uchwyty do obiektów wizualnych.
- `int iBuildingHpToAddArray[]` - przechowuje wartości (payload), np. ile % HP dodać.

Indeksem w tych tablicach jest znormalizowany numer markera (np. `j = iMarker - MARKER_FIRST_BUILDING_HP`). Dzięki temu skrypt wie, który obiekt usunąć i jaką wartość przyznać.

## 4. Specyfika silnika i zasady (Ważne!)
- **Siatka (Grid):** Gra działa ściśle na kratkach. Kratka jednostki musi się dokładnie pokryć z kratką artefaktu, aby wywołać event. Nie ma tu "promienia łapania".
- **Brak kolizji eventów:** Na jednej kratce może stać maksymalnie jedna jednostka naraz. Dzięki temu nie ma ryzyka "race condition" (sytuacji, w której dwie jednostki podnoszą przedmiot w tym samym ticku silnika).
- **Jednostki latające:** Nie wywołują eventów wejścia na artefakt. W grze dotyczy to tylko jednej jednostki (Wiedźma / Witch), więc nie trzeba pisać dla niej specjalnych wyjątków w kodzie podnoszenia.
- **Jednorazowe vs Wielorazowe artefakty (Zwracana wartość):** Zdarzenie `event Artefact` oczekuje zwrócenia wartości logicznej (`int`). Jeśli zwrócisz `true`, silnik gry automatycznie zniszczy niewidzialny artefakt z mapy (artefakt jednorazowy, np. paczka doświadczenia). Jeśli zwrócisz `false`, artefakt pozostanie na mapie i będzie mógł wyzwalać event ponownie przy kolejnych wejściach (artefakt wielorazowy, np. pole dodające poziom, które samo w skrypcie sprawdza za pomocą `ScriptData`, czy dana jednostka już z niego skorzystała).
