# CLAUDE.md

Wskazówki dla Claude / AI asystentów pracujących nad tym repozytorium. Ten plik
jest uzupełniany stopniowo – na razie skupia się na **podstawach języka
skryptowego** gry _Polanie II / KnightShift Golden Edition_.

Repo zawiera **skrypty misji, AI graczy i AI jednostek** dla gry RTS z początku
lat 2000. Silnik gry jest zamknięty – modyfikować można **tylko skrypty**. Nie
istnieje kompilator/runtime dostępny lokalnie do szybkiego testu – weryfikacja
działania wymaga uruchomienia gry.

## 1. Jak ten "język" działa

Pliki `.ec` to samodzielne jednostki kompilacji (misje, AI itd.), pliki `.ech`
to pliki nagłówkowe włączane przez `#include "ścieżka\Plik.ech"`. Po
kompilacji (`MakeAll.bat`) powstają `.eco`, które trzeba skopiować do folderu
`Scripts/` w katalogu gry.

Składnia przypomina uproszczone C / C++, **ale jest znacznie uboższa**.

Dostępne:

- bloki `{ ... }`, `;` na końcu instrukcji
- `if` / `else if` / `else`
- `for (init; cond; step) { ... }`
- `return`, `continue`, `break`
- komentarze `// ...` i `/* ... */`
- operatory arytmetyczne, bitowe (`& | ~ ^ << >>`) i logiczne (`&& || !`)
- wywołania metod na obiektach przez kropkę: `rPlayer.SetMoney(100)`

**NIE istnieją** (nie używaj, kompilator albo padnie, albo kod po prostu nie
zadziała):

- `while (...) { }` – nie ma. Pętlę „while” zrób przez `for (; cond; ) { }`
  albo przez licznik.
- `do { } while (...)` – nie ma.
- `switch / case / default` – nie ma. Używaj łańcucha `if / else if`.
- `i++`, `i--` (postfix) – **nie działa**, cicho się nie wykonuje i rozwala
  pętle.
- `+=`, `-=`, `*=`, `/=`, `&=`, `|=` itp. – nie ma, pisz pełną formę
  `x = x + y`.
- wskaźniki, `struct`, `typedef`, definicje własnych typów.
- funkcje wariadyczne użytkownika (`...`) – tylko silnikowe warianty
  `SetStringBuff` przyjmują zmienną liczbę argumentów.

Co **działa** z inkrementacji:

- `++i` (prefix) – **działa**, patrz `gametypes/Common/Math.ech`.
- `i = i + 1` – **działa**, forma preferowana w większości repo
  (np. `DestroyEnemyStructures.ec`). Bezpieczna i czytelna.

Pozostałe ograniczenia:

- Deklaracje zmiennych **tylko na początku bloku** (styl C89). Wszystkie
  lokalne `int`/`unit`/`player` wypisz na górze funkcji/bloku, potem kod.
- Brak dynamicznej alokacji, brak rekursji bez ograniczeń – żadnych kontenerów
  poza `array` (patrz sekcja 2).

### Struktura pliku misji (`.ec`)

Plik misji to blok `mission "..." { ... }` zawierający:

- `#include` – dołączenie pomocników z `Common/` i innych folderów
- `state Nazwa { ... }` – maszyna stanów misji (`Initialize`, `Nothing`,
  `Victory`, `Defeat` – definicje w `gametypes/Common/States.ech`)
- `event NazwaEventu() { ... }` – zdarzenia silnika, m.in.:
  - `Timer0()` … `TimerN()` – uruchamiane cyklicznie po `SetTimer(n, interval)`
  - `SetupInterface()`, `SpecialLevelFlags()`, `RemoveUnits()` itd.
- `command NazwaKomendy(...) button comboX { ... }` – obsługa elementów UI
  (combo boxów) ustawianych w edytorze misji

Przepływ: `Initialize` ustawia graczy, cele, timery, po czym zwraca `Nothing`.
Dalsza logika odpala się z eventów timerów. Zmiana stanu np. `state Victory;`
uruchamia odpowiadający blok `state` (patrz `States.ech`).

## 2. System typów (KLUCZOWE)

Język **nie ma typu zmiennoprzecinkowego**. Każda zmienna jest albo liczbą
całkowitą, albo stringiem, albo uchwytem do obiektu silnika.

### Typy skalarne

| Typ      | Uwagi                                                                  |
| -------- | ---------------------------------------------------------------------- |
| `int`    | Jedyna liczba. 32-bit ze znakiem. **Brak `float`/`double`.**           |
| `string` | Literał w `"..."`. Używany jako ID jednostek/budynków, teksty, klucze. |

Konsekwencje braku floatów – w repo konsekwentnie:

- wartości ułamkowe przekazuje się jako **setne/tysięczne** (sufiks `100x`,
  `1000x`) – np. `SetMoneyPerResource100x(40)` oznacza `0.40`.
- losowość z rozkładu Gaussa i XorShift są emulowane na intach
  (`Math.ech` → `RandXor`, `GaussianDistribution`) – zamiast wbudowanego
  `Rand()`, który jest _skośny_, używaj `RandXor(iMax)`.
- czas mierzony w tickach: `SECOND = 20`, `MINUTE = 1200`
  (`gametypes/Common/Consts.ech`). Silnik tyka 20 Hz.

### Stringi: literały tak, zmienne – przez buffery

Literał stringa (`"translateKOTHGoal"`, `"TD_WITCH"` itd.) można bez problemu
**przekazać jako argument** funkcji silnika i ID jednostki/budynku. Natomiast
**nie istnieje użyteczny typ zmiennej stringowej** – nie można odłożyć
stringa do zmiennej lokalnej i dalej go komponować. Silnik udostępnia zamiast
tego pulę **ponumerowanych buforów tekstowych** (0..N), na których operuje
rodzina funkcji `*StringBuff*` (zdefiniowane w `_manual/objectX.htm` jako
`private static`, więc wywołuje się je bez kropki):

- `SetStringBuff(nBuffNum, "tekst")` – ustaw bufor na literał.
- `SetStringBuff(nBuffNum, "format %s %d ...", arg1, arg2, ...)` – printf-like,
  z `%s` i `%d`; do ~4 argumentów (patrz przeciążenia w manualu).
- `SetStringBuffTranslate(nBuffNum, "translateKey")` – wrzuca do bufora tekst
  z pliku tłumaczeń gry.
- `GetStringBuff(nBuffNum)` – zwraca aktualną zawartość jako stringa, którą
  można podać jako argument do kolejnego `SetStringBuff` lub do
  `SetConsoleText(...)`.
- `CopyStringBuff`, `AppendStringBuff` – kopiowanie/sklejanie buforów.
- `CompareStringBuffNoCase` – porównanie.
- `SetBufferSideColorName(nBuffNum, nSideColor)` – zapisz w buforze
  pokolorowaną nazwę gracza (używane do wyników).

Wzorzec „złóż wynik wielu graczy w jeden tekst” pokazuje
`gametypes/KingOfTheHill.ec` (linie ~349–426). Skrócony szkielet:

```
SetStringBuff(0, "");                              // akumulator
for (i = 0; i < 8; i = i + 1) {
    // ... policz iOccupiedTowers ...
    SetBufferSideColorName(5, rPlayer.GetSideColor());
    SetStringBuff(1, " %s: %d ", GetStringBuff(5), iOccupiedTowers);
    SetStringBuff(0, " %s %s ",  GetStringBuff(0), GetStringBuff(1));
}
SetConsoleText(GetStringBuff(0));
```

Zasady pracy z bufferami:

- Numery buforów są **globalne** – dwie niezależne funkcje piszące do bufora
  `0` **nadpiszą się wzajemnie**. Umawiaj się w obrębie pliku, które indeksy
  są „robocze” (typowo 0 = wynik, 1–5 = tymczasowe).
- Po każdym użyciu `SetStringBuff` zawartość poprzednia znika. Jeśli musisz
  połączyć kilka rzeczy – najpierw `GetStringBuff(src)` do czytelnej zmiennej
  wyniku, potem buduj dalej.
- `GetStringBuff` zwraca string na tyle długo, że można go podać do kolejnego
  `SetStringBuff` w tej samej instrukcji – tak robi `KingOfTheHill.ec`.

### Klucze tłumaczeń `"translate…"`

Ciągi zaczynające się od prefiksu `translate` (`"translateGameTypeDestroyStructures"`,
`"translateDestroyEnemyStrucuresGoal"`, `"translateKOTHConsoleGoal"` itd.) **nie
są zwykłymi tekstami wyświetlanymi graczowi** – to **klucze do tabel
tłumaczeń gry**, które silnik podmienia w runtime na pełny string w aktualnie
wybranym języku (PL/EN/…).

Nigdy nie wypisuj przez `SetConsoleText("translateFooBar")` – gracz zobaczy
surowy klucz. Do tłumaczeń służą osobne ścieżki:

- `mission "translate...` – pierwsza linia pliku `.ec`, nazwa trybu w UI gry
  (patrz `gametypes/DestroyEnemyStructures.ec` linia 1).
- `RegisterGoal(nNr, "translate...")` – tekst celu misji.
- `AddBriefing(szWave, "translate...")` – briefing na starcie fali/misji.
- `SetStringBuffTranslate(nBuffNum, "translate...")` – wrzuca
  przetłumaczony tekst do bufora, po czym można go dalej komponować
  `SetStringBuff`iem z `%s` / `%d` i wypisać przez `SetConsoleText`
  (patrz wzorzec w `KingOfTheHill.ec`, sekcja „Stringi i buffery”).

Konwencja nazewnicza w repo:

- Klucze są w **camelCase** z wiodącym `translate`, np.
  `translateCommandStateCamouflageModeNormal`.
- Dla jednostek i AI powtarzające się klucze są aliasowane przez `#define`
  (prefiks `TRL_`) w dwóch plikach:
  - `units/Translates.ech`
  - `aiplayers/Translates.ech`

  Przykłady: `#define TRL_STOP "translateCommandStop"`,
  `#define TRL_CAMOUFLAGE_0 "translateCommandStateCamouflageModeNormal"`.
  Jeśli dodajesz nowy tekst w `units/` lub `aiplayers/`, **najpierw zerknij
  do `Translates.ech`** – klucz prawdopodobnie już istnieje pod aliasem
  `TRL_*`. Dodając nowy, trzymaj ten sam wzorzec (stały `TRL_*` w
  `Translates.ech`, a w kodzie używaj aliasu, nie surowego literału).

Źródło samych tłumaczeń (mapowanie klucz → zdanie w danym języku) leży
**poza tym repo** – w plikach tłumaczeń gry. Jeśli klucza tam nie ma, silnik
zwykle wypisze po prostu surowy string klucza, co jest dobrym sygnałem
w QA, że trzeba go dodać po stronie tłumaczeń.

### Typy obiektowe (uchwyty)

Każdy plik w `_manual/` opisuje jeden typ obiektu – zestaw jego metod,
eventów i enumów. Dostępne typy:

| Typ             | Do czego służy                                                                                                                                                                                                 |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `mission`       | Niejawny „this” skryptu misji – funkcje globalne misji (timery, pogoda, cele, markery, tworzenie obiektów). Patrz `_manual/mission.htm`.                                                                       |
| `player`        | Gracz (0–7 normalni + specjalni 10/14/15). Zasoby, AI flags, sojusze, `SetScriptData`, `SetScriptUnit`, statystyki, `Victory()/Defeat()`.                                                                      |
| `unit`          | Podstawowa jednostka/budynek – info statyczne (IFF, IsBuilding, IsFlyable itd.) i proste komendy.                                                                                                              |
| `unitex`        | "Extended unit" – bogaty wariant `unit` zwracany przez większość funkcji tworzących/odnajdujących jednostki (np. `CreateArtefact`, `GetUnit`). Jego metod używamy w 99% przypadków (HP, komendy, ruch, magia). |
| `punit`         | Wariant `unit` używany w skryptach AI jednostek (w `units/`).                                                                                                                                                  |
| `object`        | Bazowy obiekt ze statycznymi narzędziami: `Rand`, `RandD`, `Distance`, `sqrt`, `GetGameTick`, `IsRPGMode`, `GetEntranceX/Y/Z`. (Metody `Trace*` są w manualu, ale **nie działają** – patrz blacklista.)        |
| `objectX`       | Rozszerzona wersja `object` – dodatkowe statyczne helpery.                                                                                                                                                     |
| `commandobject` | Klasa nadrzędna dla obiektów wydających komendy (rozkazy AI jednostek).                                                                                                                                        |
| `builder`       | Rozszerzenie dla budowniczych (znajdowanie miejsc pod budowę, `CallBuildObject`).                                                                                                                              |
| `harvester`     | Rozszerzenie dla zbieraczy zasobów.                                                                                                                                                                            |
| `repairer`      | Rozszerzenie dla naprawiaczy.                                                                                                                                                                                  |
| `platoon`       | Grupa jednostek (formacje AI).                                                                                                                                                                                 |
| `campaign`      | Obiekt kampanii, globalny stan pomiędzy misjami kampanii.                                                                                                                                                      |
| `array`         | Dynamiczna tablica na `VALUE` (int). `Create/Delete/Add/RemoveAt/Sort/SortWithKeys`. Jedyny „kontener” dostępny w języku.                                                                                      |

Dodatkowo istnieje pseudo-typ w deklaracjach `array` – `VALUE` – reprezentujący
element tablicy (w praktyce `int`).

Zwykłe tablice intów deklaruje się jak w C: `int arr[];` lub `int arr[10];` –
patrz sygnatura `SortWithKeys(int arrKeys[], ...)` w `_manual/array.htm`.

### Wartości specjalne

- `null` – pusty uchwyt; **zawsze** sprawdzaj `if (rPlayer != null)` zanim
  wywołasz metodę.
- Stałe IFF / numery graczy specjalnych siedzą w `_manual/object.htm` (enum
  block): `neutralIFF`, `wildAnimalsIFF`, `towersIFF`, `maxNormalPlayersCnt`
  itd.

## 3. Konwencje w tym repo

- **Węgierska notacja** dla prefiksów zmiennych:
  - `i`, `n` – int (np. `iX`, `nWaveNumber`, `nMode`)
  - `b` – bool-jak-int (0/1) (np. `bEnable`, `bActiveEnemies`)
  - `r` – referencja do `player` (np. `rPlayer`)
  - `u` – `unit` / `unitex` (np. `uUnit`, `uTarget`)
  - `str`, `sz` – `string`
  - `combo*` – zmienne powiązane z comboboxami UI
- Stałe `SCREAMING_SNAKE_CASE` (patrz `Consts.ech`).
- Komentarze w repo są **po polsku** – zachowuj polski, gdy modyfikujesz
  istniejący plik; nowy kod publiczny może być po angielsku, ale bądź spójny w
  obrębie pliku.
- **Unikaj zagnieżdżeń (Early returns / Guard clauses):** Funkcje powinny robić `return` na negacjach warunków tak wcześnie, jak to możliwe, zamiast pakować główną logikę w wielkie bloki `if { ... }`. Zmniejsza to poziom wcięć i poprawia czytelność.
- `state != Nothing` używane do bail-outu w eventach, żeby nie wykonywać
  logiki po zwycięstwie/porażce.
- Gdy dodajesz nowy event do timera, dodaj `SetTimer(n, interval)` w
  `Initialize` i zachowaj numerację (timery 0, 1, 2, … bez dziur tam, gdzie
  nadpisujesz istniejące).

## 4. Zasady dla AI edytującego ten kod

1. **Nie wymyślaj funkcji ani metod.** Wszystkie dostępne symbole są w
   `_manual/*.htm`. Jeśli czegoś tam nie ma – nie istnieje. Przed dodaniem
   wywołania nowej funkcji zweryfikuj ją w manualu (Grep po nazwie w
   `_manual/`).
2. **Zero floatów.** Każde obliczenie wykonuj na intach. Przy wartościach
   ułamkowych skaluj (×100, ×1000) i szukaj w manualu funkcji z sufiksem
   `100x` / `1000x` zamiast dzielić.
3. **Dzielenie to dzielenie całkowite.** `1/2 == 0`. Mnóż najpierw, potem
   dziel.
4. **Null-check uchwyty.** Zwłaszcza `GetPlayer(i)`, `GetUnit(...)`,
   `GetScriptUnit(...)` – mogą zwrócić `null`.
5. **Pętle po graczach** zwykle idą `for(i=0; i<8; i=i+1)` – 8 „normalnych”
   slotów. Gracze specjalni (10, 14, 15) są adresowani po numerze bezpośrednio.
6. **Timery mierzą tickami.** Zawsze używaj stałych `SECOND`/`MINUTE` z
   `Consts.ech`, nie hardkoduj magicznych liczb.
7. **RNG**: preferuj `RandXor(iMax)` z `Math.ech` zamiast `Rand(iMax)`.
8. **Zmienne na górze bloku.** Nie mieszaj deklaracji z kodem w środku bloku.
9. **Zachowuj istniejący styl** (prefiksy, polskie komentarze, tabulacja 4
   spacje) – czytelność w tym kodzie jest krytyczna, bo nie ma debuggera.
10. **Debugowanie = `SetConsoleText`.** `Trace` / `TraceD` / `TraceF`
    **nie działają** w tej wersji silnika (patrz blacklista – sekcja 7).
    Jedyny
    sprawdzony sposób, żeby zobaczyć wartość w runtime, to złożyć ją w buforze
    i wypisać:
    ```
    SetStringBuff(0, "DBG: i=%d hp=%d", i, uUnit.GetHP());
    SetConsoleText(GetStringBuff(0));
    ```
    Pamiętaj usunąć wywołania diagnostyczne przed commitowaniem – nadpisują
    normalne komunikaty HUD-u.

## 5. Wzorzec: custom eventy (most między mission ↔ unit)

Wiele funkcji na `unit` / `punit` jest w `_manual/` oznaczonych jako
`private` – oznacza to, że są „widoczne” tylko wewnątrz kodu jednostki
(w `units/*.ech`) i **nie można ich wywołać „po kropce”** z poziomu
skryptu misji ani z `unitex` w `gametypes/`. Przykłady: `IsAttacking()`,
`DistanceTo(...)`, `CallMoveToPointAlpha(...)`, `HaveMagic(...)`,
`IsFreePoint(...)`, `IsBridgeInPoint(...)`.

Obejście to **publiczne eventy `Custom0`..`Custom4`** zdefiniowane na typie
`unit` (patrz `_manual/unit.htm`, linie ~337–341):

```
int Custom0(int, int, int, int, unit) public
int Custom1(int, int, int, int, unit) public
int Custom2(int, int, int, int, unit) public
int Custom3(int, int, int, int, unit) public
int Custom4(int, int, int, int, unit) public
```

oraz parująca z nimi publiczna metoda (synchroniczna – zwraca `int`):

```
int SetCustomEvent(int nEventNum, int nGx, int nGy, int nLz, int nParam, unit uObject) public
```

### Jak to zorganizować

**Strona unit script** (`units/*.ech`) – definiujesz jeden event
`CustomN`, w środku robisz dispatch na pierwszym parametrze (numer
„sub-komendy”). Wywołujesz w nim dowolne `private` funkcje jednostki.
Zwracany `int` wraca do wołającego. Przykład z `units/Attack.ech`
(1732–1771):

```
#define IS_ATTACKING 0
#define GET_DISTANCE_TO_ATTACK_TARGET 1
#define MOVE_BACK_IF_FAR_FROM_ATTACK_TARGET 1
#define IS_FREE_POINT 2
#define IS_BRIDGE_IN_POINT 3
#define HAVE_MAGIC 4

event Custom3(int nParam1, int nParam2, int nParam3, int nParam4, unit uUnit)
{
    if (nParam1 == IS_ATTACKING)             return IsAttacking();
    else if (nParam1 == IS_FREE_POINT)       return IsFreePoint(nParam2, nParam3, nParam4);
    else if (nParam1 == IS_BRIDGE_IN_POINT)  return IsBridgeInPoint(nParam2, nParam3, nParam4);
    else if (nParam1 == HAVE_MAGIC)          return HaveMagic(nParam2);
    // ...
    return 0;
}
```

**Strona mission script** (`gametypes/Common/EmitUnitEvent.ech`) – cienkie
opakowania, które wołają `SetCustomEvent` i ukrywają numery eventów /
sub-komend. Dzięki temu reszta kodu misji pisze `IsUnitAttacking(uUnit)`
zamiast pamiętać `(3, 0, 0, 0, 0, null)`:

```
function int IsUnitAttacking(unitex uUnit)
{
    return uUnit.SetCustomEvent(3, IS_ATTACKING, 0, 0, 0, null);
}

function int IsFreePoint(unitex uUnit, int nX, int nY, int nZ)
{
    return uUnit.SetCustomEvent(3, IS_FREE_POINT, nX, nY, nZ, null);
}
```

### Zasady używania custom eventów

- **Synchronizacja `#define`.** Stałe sub-komend (`IS_ATTACKING` itd.) muszą
  być _identyczne_ po obu stronach. W tym repo jest to robione przez
  zdublowanie `#define`'ów na górze pliku unit-owego i misyjnego – jeśli
  zmienisz wartość po jednej stronie, po cichu wywołasz złą gałąź po
  drugiej. Rozważ trzymanie ich w jednym współdzielonym `.ech`.
- **Jeden event = jedna „rodzina” komend.** `Custom0`..`Custom4` jest
  pięć – w repo `Custom3` jest zarezerwowany na komendy AI ataku
  (patrz `Attack.ech`). Zanim weźmiesz kolejny numer, zgrepuj
  `event Custom` w `units/`, żeby nie nadpisać istniejącego.
- **Sygnatura jest sztywna**: `(int, int, int, int, unit)` → `int`.
  `nGx/nGy/nLz` w `SetCustomEvent` to po prostu trzy inty, można je
  wykorzystać jak chcesz (w `EmitUnitEvent.ech` są używane jako
  koordynaty dla `IsFreePoint`, ale dla `IS_ATTACKING` to zwykłe zera).
  Ostatni argument `unit uObject` bywa `null`.
- **`SetCustomEvent` zwraca wartość eventu synchronicznie.** Używaj go
  jak funkcji – `if (IsUnitAttacking(u)) { ... }`. Nie trzeba czekać na
  tick.
- **Custom eventy działają tylko na uchwytach `unit`/`unitex`** – nie ma
  ich na `player` ani na samej misji.

### Kiedy warto dopisać nową sub-komendę

Jeśli w skrypcie misji chcesz przeczytać stan jednostki lub wydać jej
„miękki” rozkaz z użyciem `private` funkcji – zamiast próbować wywołać to
bezpośrednio (nie da się), dopisz nowy `#define NEW_CMD X`, dodaj
gałąź `else if (nParam1 == NEW_CMD)` w `event CustomN` po stronie unita,
i opakuj to funkcją `function int NewCmd(unitex uUnit, ...)` w
`gametypes/Common/EmitUnitEvent.ech`.

## 6. Pliki i foldery, które warto znać zanim coś dotkniesz

### Pliki referencyjne

- `README.md` – opis repo, struktura, jak kompilować (`MakeAll.bat`) i
  instalować (`Scripts/` w katalogu gry).
- `_docs/` – baza wiedzy moda. Koniecznie przeczytaj:
  - `_docs/MarkerFunctions.md` (system masek i customowych artefaktów).
  - `_docs/Arrays.md` (pułapki arytmetyczne przy pracy z tablicami).
  - `_docs/Bitwise.md` (krytyczne błędy priorytetów operatorów bitowych).
  - `_docs/Compilation.md` (jak kompilować kod i uruchamiać `MakeRTS.bat`).
  - `_docs/EngineQuirks.md` (zepsute funkcje silnika i ich specyficzne zachowania).
  - `_docs/Debugging.md` (jak tworzyć czyste środowisko testowe i używać printów).
- `_manual/` – **jedyne źródło prawdy** o API silnika.
- `gametypes/Common/Consts.ech` – stałe czasu, etapy, statusy graczy.
- `gametypes/Common/States.ech` – szablon `Nothing` / `Victory` / `Defeat`.
- `gametypes/Common/Math.ech` – `MIN/MAX/ABS/Power`, XorShift RNG, Gauss.
- `gametypes/Common/EmitUnitEvent.ech` – opakowania na custom eventy do
  wywoływania `private` funkcji jednostek ze skryptów misji (patrz sekcja 5).
- `units/Attack.ech` – m.in. `event Custom3`: druga strona mostu z sekcji 5.
- `units/Translates.ech`, `aiplayers/Translates.ech` – aliasy `TRL_*` na
  klucze tłumaczeń; dodając nowy tekst zacznij tu, a nie od surowego
  `"translate…"` w kodzie.
- `gametypes/DestroyEnemyStructures.ec` – wzorcowy, krótki plik misji pokazujący
  pełny szkielet: `Initialize`, eventy, timery, komendy UI.

### Foldery – gdzie pisać, a czego nie ruszać

- **`gametypes/`** – główne miejsce pracy. Każdy `.ec` tu to tryb gry
  (Wojna Wiosek, KOTH, Tower Defense, Adventure itd.). Nowe mechaniki
  trybów, AI misyjne i helpery (`Common/`, podfoldery per-tryb) trafiają
  tutaj. **Tu piszemy 90% nowego kodu.**
- **`aiplayers/`** – skrypty AI dla nowych botów (Ekspercki, Arcymistrzowski,
  Boski). Ograniczone API (brak cross-player info – patrz sekcja 8),
  dlatego część „AI” nowych botów faktycznie żyje w `gametypes/`.
- **`campaigns/`** – zawiera **oryginalny kod gry** (spaghetti, zagmatwany,
  mało komentarzy). **Nie modyfikuj go w ramach nowych trybów**, ale
  traktuj jako **kopalnię działających przykładów** – jeśli nie wiesz, jak
  wywołać konkretną funkcję silnika albo jak coś zrobić „oficjalnie”,
  najpierw `Grep` po `campaigns/` – tam są wzorce, które gra na pewno
  obsługuje w runtime. Do repo trafiły tylko funkcje pomocnicze; pełne
  skrypty kampanii są linkowane z `README.md`.
- **`units/`** – AI jednostek (atakowanie, budowanie, zbieranie,
  patrolowanie). **Jeszcze bardziej zagmatwane niż `campaigns/`** i ściśle
  powiązane z silnikiem – drobna zmiana może zepsuć zachowanie wszystkich
  unitów w grze. **Nie edytuj tego folderu bez bardzo konkretnego,
  świadomego celu.** Preferowana droga dotarcia do logiki jednostek ze
  skryptu misji to mechanizm custom eventów (sekcja 5), nie przepisywanie
  AI.
- **`_manual/`** – tylko do czytania. Nie zmieniaj, nie generuj – to
  dokumentacja silnika.
- **`_docs/`** – baza wiedzy moda. Dokumentacja specyficznych hacków i systemów.
- **`_compiler/`** – narzędzia kompilatora. **Nie dotykaj.**

## 7. Blacklista – funkcje i konstrukcje, które NIE działają

Rzeczy, które są udokumentowane w `_manual/` albo wyglądają jak standardowe
C, ale **w praktyce zawodzą** w tej wersji silnika. Nie używaj ich, nawet
jeśli IDE / kompilator ich nie odrzucą.

### Język

| Konstrukcja               | Status    | Zamiast tego                              |
| ------------------------- | --------- | ----------------------------------------- |
| `while (...)`             | brak      | `for (; cond; ) { }`                      |
| `do { } while`            | brak      | `for` + flaga wyjścia                     |
| `switch / case`           | brak      | `if / else if / else`                     |
| `i++`, `i--` (postfix)    | nie dział | `++i` lub `i = i + 1`                     |
| `+=`, `-=`, `*=`, `/=`    | brak      | `x = x + y`                               |
| zmienne string lokalne    | bezużyt.  | buffery `SetStringBuff` / `GetStringBuff` |
| deklaracja w środku bloku | błąd      | wszystkie deklaracje na górze bloku       |

### Funkcje silnika, które są udokumentowane, ale psute/bezużyteczne

Pełna lista zepsutych funkcji silnika (np. `GetName()`, `Trace()`, `Rand()`) oraz funkcji o specyficznym / nieudokumentowanym działaniu (np. `GetBuildingType()`) została przeniesiona do bazy wiedzy.

**Koniecznie przeczytaj:** `_docs/EngineQuirks.md`

Jeśli znajdziesz kolejną „martwą” funkcję – dopisz ją do tego dokumentu razem z obejściem. To jest najcenniejsza wiedza w tym repo, bo nie stoi w żadnym oficjalnym manualu.

## 8. Inne pułapki silnika

- Ze skryptów jednostek/graczy **nie ma dostępu** do pełnej informacji o innych
  graczach – logika cross-player powinna żyć w skryptach misji (`gametypes/`).
- Niektóre funkcje są `private` vs `public` w manualu – `private` oznacza, że
  są wołane tylko jako metoda na obiekcie danego typu (np. `mission`,
  `objectX`), a nie z zewnątrz / nie są wołane „po kropce” na innym uchwycie.
  Dla `unit`/`punit` obejściem jest mechanizm custom eventów z sekcji 5
  (`SetCustomEvent` + `event CustomN` po stronie unita).
- `SetConsoleText` nadpisuje inne komunikaty HUD-a – debug-printy kasuj przed
  commitem.

---

_Ten plik jest pracą w toku. Rozbudowujemy go iteracyjnie – jeśli natkniesz się
na nieudokumentowaną tu pułapkę języka lub silnika, dopisz notatkę w sekcji
7 („Blacklista”) albo 8 („Inne pułapki silnika”)._
