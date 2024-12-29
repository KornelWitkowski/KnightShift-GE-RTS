# Polanie 2 Golden Edition RTS/ Knightshift Golden Edition RTS

**For English scroll down**

Repozytorium zawiera kod źródłowy trybu RTS do najnowszej wersji `Polanie 2 Golden Edition`. W repozytorium znajdują się skrypty misji, AI graczy oraz AI jednostek.

## Nowości względem wersji podstawowej:

- nowe tryby: Król Wzgórza, Ekonomiczny, Adventure
- odświeżone tryby: Wojna Wiosek i Bitwa, a także dodano kilka wariacji Wojny Wiosek: 8 obór, bez ulepszeń i inne
- dodatkowe, trudniejsze boty: Ekspercki, Arcymistrzowski i Boski
- skryptowanie map za pomocą markerów w edytorze: teleporty, bramy, pola z doświadczeniem, pułapki, nekromancja i wiele innych
- poprawiona generacja artefaktów na mapie
- możliwość ustawiania sojuszy z graczami komputerowymi
- ulepszone AI jednostek

## Jak zacząć modowanie

Aby rozpocząć samodzielne modyfikowanie gry należy posiadać podstawową wiedzę z programowania - wystarczy znajomość zmiennych, pętli, wyrażeń warunkowych i funkcji w dowolnym języku programowania. Należy pobrać kod repozytorium, który można skompilować plikiem `MakeAll.bat`. Utworzy to folder `Scripts` - umieszczenie tego folderu w folderze głównym gry spowoduje nadpisanie plików gry, które zmieni jej działanie zgodnie z wprowadzonymi w kodzie zmianami.

### Manual

W folderze `_manual` znajdują się nagłówki funkcji, które można wykorzystać w skryptach. Nie ma możliwości wyjścia ponad te funkcje poza podstawowymi funkcjonalnościami języka C. Nie ma dostępu do kodu źródłowego tych funkcji. Przykłady ich wykorzystania można znaleźć w tym repozytorium. Uwaga: nie wszystkie funkcje działają poprawnie, jak np. funkcja `GetName` dla unitów i playerów.

### Pliki `.ec`, `.ech` i `.eco`

Pliki z rozszerzeniem `.ec` są plikami z kodem, które mogą być skompilowane. Pliki z rozszerzeniem `.ech` są plikami pomocniczymi wykorzystywanymi w plikach `.ec`. Skompilowane pliki dostają rozszerzenie `.eco`

### Kompilator

W folderze `_compiler` znajduje się kompilator, który jest wywoływany za pomocą pliku `MakeAll.bat`. Folder nie powinien być modyfikowany.

### Podmiana plików

- Aby wprowadzić zmiany do gry należy dostarczyć do folderu głównego zmodyfikowane pliki. Przykładowo: jeśli chcemy zmodyfikować tryb `Wojna Wiosek` należy:
  1. Wprowadzić zmiany w kodzie `DestroyEnemyStructures.ec`
  2. Skompilować pliki za pomocą `MakeAll.bat`
  3. W folderze z kodem powinien pojawić się folder `Scripts`, który powinien być przeniesiony do folderu głównego gry. Umieszczenie tego folderu sprawia, że skrypty są nadpisywane najnowszymi zmianami. Można zmodyfikować plik `MakeAll.bat`, aby automatycznie tworzył folder `Scripts` w folderze głównym gry poprzez określenie ścieżki.

### Zadania

W przyszłości zostanie tu umieszczona lista zadań, które mogą służyć jako punkt startowy do modyfikacji gry.

# English

This repository contains the source code for the RTS mode of the latest version of `Polanie 2 Golden Edition`. The repository includes mission scripts, player AI, and unit AI.

## New features compared to the base version:

- new modes: King of the Hill, Economic, Adventure
- refreshed modes: Village War and Battle, plus several Destroy Enemy Structures variations: 8 sheds, zero upgrades, and more
- additional, harder bots: Expert, Archmage, and Divine
- map scripting using editor markers: teleports, gates, experience fields, traps, necromancy, and more
- improved artifact generation on the map
- ability to set alliances with computer players
- improved unit AI

## How to start modding

To begin modifying the game independently, you need basic programming knowledge - familiarity with variables, loops, conditional statements, and functions in any programming language is sufficient. Download the repository code, which can be compiled using the `MakeAll.bat` file. This will create a `Scripts` folder - placing this folder in the game's main directory will overwrite the game files, changing its behavior according to the modifications made in the code.

### Manual

The `_manual` folder contains function headers that can be used in scripts. It's not possible to go beyond these functions except for basic C language functionality. There is no access to the source code of these functions. Examples of their usage can be found in this repository. Note: not all functions work correctly, such as the `GetName` function for units and players.

### `.ec`, `.ech`, and `.eco` files

Files with the `.ec` extension are code files that can be compiled. Files with the `.ech` extension are helper files used in `.ec` files. Compiled files get the `.eco` extension.

### Compiler

The `_compiler` folder contains the compiler that is called using the `MakeAll.bat` file. This folder should not be modified.

### File replacement

- To implement changes to the game, you need to provide modified files to the main folder. For example: if we want to modify the `Destroy Enemy Structures` mode:
  1. Make changes to the `DestroyEnemyStructures.ec` code
  2. Compile the files using `MakeAll.bat`
  3. A `Scripts` folder should appear in the code folder, which should be moved to the game's main folder. Placing this folder ensures that the scripts are overwritten with the latest changes. You can modify the `MakeAll.bat` file to automatically create the `Scripts` folder in the game's main folder by specifying the path.

### Tasks

A list of tasks that can serve as a starting point for game modification will be placed here in the future.
