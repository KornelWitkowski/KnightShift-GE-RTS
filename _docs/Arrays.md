# Obsługa tablic i pułapki arytmetyczne

Tablice (np. `int tab[]`, `unitex uRewards[]`) to jedyne dostępne kontenery w języku skryptowym silnika Polan II. Uwaga: **nie można** deklarować ich rozmiaru z góry w stylu C (np. `int tab[10];` jest niedozwolone). Rozmiar zawsze nadajemy dynamicznie przez `.Create()`. Choć ich deklaracja i użycie przypominają standardowe C/C++, silnik posiada krytyczny błąd (quirk) związany z modyfikowaniem wartości w miejscu.

## Krytyczny błąd: `tab[i] = tab[i] + 1`
Kompilator/silnik ma ogromne problemy z poprawną ewaluacją wyrażeń, w których ten sam indeks tablicy znajduje się po obu stronach operatora przypisania. 

Próba bezpośredniej inkrementacji wartości w tablicy **nie wyrzuci błędu kompilacji**, ale w trakcie gry (runtime) **wynik arytmetyczny będzie błędny** (często wartość zostanie zepsuta, wyzerowana lub nadpisana śmieciami).

### ❌ ŹLE (Nie zadziała poprawnie w grze):
```c
// Próba bezpośredniej modyfikacji - SILNIK TEGO NIE LUBI
iBins[j] = iBins[j] + 1;
```
*(Uwaga: operatory takie jak `+=` czy `++` w postaci sufiksu `iBins[j]++` w ogóle nie są wspierane przez język).*

### ✅ DOBRZE (Bezpieczne obejście):
Aby bezpiecznie zmodyfikować wartość w tablicy, operację należy rozbić na mniejsze kroki przy użyciu zmiennej tymczasowej (`iTemp`). Najpierw wyciągamy wartość, modyfikujemy ją w zwykłej zmiennej, a następnie wpisujemy z powrotem do tablicy.

```c
int iTemp;

// 1. Wyciągnięcie wartości do zmiennej tymczasowej
iTemp = iBins[j];

// 2. Operacja arytmetyczna na zwykłej zmiennej
iTemp = iTemp + 1;

// 3. Zapisanie wyniku z powrotem do tablicy
iBins[j] = iTemp;
```

## Inne zasady pracy z tablicami
1. **Tworzenie dynamiczne:** Ponieważ nie można podać rozmiaru przy deklaracji, przed użyciem tablicy musisz zaalokować dla niej pamięć wywołując metodę `.Create(rozmiar)`, np. `uRewards.Create(10)`.
2. **Wyjście poza zakres (Out of bounds):** Próba odwołania się do indeksu, który nie istnieje (np. `tab[10]` w tablicy o rozmiarze 10) **natychmiastowo wywala grę (hard crash)**. Silnik nie wybacza pomyłek w indeksowaniu, dlatego zawsze upewnij się, że indeks mieści się w zaalokowanym rozmiarze.
3. **Inicjalizacja:** Zawsze ręcznie zeruj/czyść nowo utworzone tablice w pętli `for` (np. przypisując `0` dla intów i `null` dla uchwytów obiektów). Silnik nie gwarantuje, że nowa tablica będzie wypełniona zerami.