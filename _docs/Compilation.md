# Kompilacja skryptów (MakeRTS.bat)

Wszystkie skrypty misji i trybów gry (`.ec`) muszą zostać skompilowane do formatu binarnego (`.eco`), aby silnik gry mógł je odczytać. Służy do tego skrypt `MakeRTS.bat` znajdujący się w głównym katalogu projektu.

## Jak działa proces kompilacji?
Uruchomienie `MakeRTS.bat` wykonuje następujące kroki:
1. **Kompilacja:** Przeszukuje folder `gametypes/` w poszukiwaniu wszystkich plików z rozszerzeniem `.ec`.
2. Każdy znaleziony plik jest kompilowany za pomocą narzędzia `_compiler\EarthCP2.bat`.
3. **Kopiowanie:** Utworzone pliki `.eco` są przenoszone do odpowiednich folderów docelowych:
   - `Scripts\gametypes\`
   - `Scripts\gametypes\single\`

Folder `Scripts\` to struktura, którą ostatecznie należy skopiować/podmienić w głównym katalogu zainstalowanej gry Polanie II / KnightShift.

## Jak uruchamiać kompilator?

### Sposób 1: Ręcznie (Eksplorator Windows)
Wystarczy dwukrotnie kliknąć plik `MakeRTS.bat` w głównym folderze projektu. Otworzy się okno wiersza poleceń, wypisze logi z kompilacji poszczególnych plików, a na koniec poprosi o wciśnięcie dowolnego klawisza (instrukcja `pause`).

### Sposób 2: Przez terminal w Cursor / VS Code
Jeśli chcesz skompilować kod bezpośrednio z terminala w edytorze, wpisz:
```bat
cmd /c "MakeRTS.bat < nul"
```
**Dlaczego tak?** Skrypt na samym końcu posiada instrukcję `pause`. Dodanie `< nul` automatycznie "wciska" klawisz, dzięki czemu terminal nie zostaje zablokowany i od razu wraca do znaku zachęty.

## Weryfikacja błędów
Jeśli w kodzie znajduje się błąd składniowy (np. brakujący średnik, literówka w nazwie zmiennej, zła liczba argumentów), kompilator `EarthCP2.bat` przerwie pracę na danym pliku i wypisze w konsoli numer linii oraz rodzaj błędu. 
Jeśli kompilacja przebiegła pomyślnie, zobaczysz po prostu listę plików z dopiskiem `Compiling...` i podsumowanie skopiowanych plików na końcu.