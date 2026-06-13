# Operacje bitowe i pułapki preprocesora (#define)

Silnik Polan II posiada **poważny błąd w priorytetach operatorów (operator precedence)**, w szczególności jeśli chodzi o operatory bitowe (`<<`, `>>`, `&`, `|`). Różni się on od standardu języka C, co może prowadzić do absurdalnych i trudnych do zdebugowania błędów matematycznych.

## Krytyczny błąd: Priorytet `&` vs `<<`

W standardowym C operator przesunięcia bitowego (`<<`) wykonuje się **przed** operatorem AND (`&`). W silniku Polan wydaje się to działać odwrotnie lub ewaluować od lewej do prawej w sposób nieprzewidywalny.

### Przykład z życia (Zepsute maski):
Załóżmy, że mamy definicję maski:
```c
#define MASK_SCRIPT_DATA_FUNCTIONAL 63 << 6   // (czyli 4032)
```
Oraz zmienną `iScriptData = 66`.

Chcemy wyciągnąć wartość z maski:
```c
iFunctionalScriptData = iScriptData & MASK_SCRIPT_DATA_FUNCTIONAL;
```
Spodziewany wynik to `64` (bo `66 & 4032 = 64`).

**Co robi silnik?**
Zamiast policzyć `66 & (63 << 6)`, silnik po rozwinięciu makra widzi `66 & 63 << 6` i liczy to tak:
1. `66 & 63 = 2`
2. `2 << 6 = 128`
Wynik: **128 zamiast 64!**

Gdy zamienimy argumenty miejscami:
```c
iFunctionalScriptData = MASK_SCRIPT_DATA_FUNCTIONAL & iScriptData;
```
Silnik widzi `63 << 6 & 66` i liczy to tak:
1. `6 & 66 = 2`
2. `63 << 2 = 252` (często mylone z 256)
Wynik: **252 zamiast 64!**

## ✅ Rozwiązanie: ZAWSZE używaj nawiasów w `#define`

Aby uchronić się przed tym błędem, **każde makro zawierające operacje matematyczne lub bitowe musi być bezwzględnie otoczone nawiasami**. 

### ❌ ŹLE:
```c
#define MASK_SCRIPT_DATA_FUNCTIONAL 63 << 6
#define SCRIPT_DATA_MEDUSA 2 << 26
```

### ✅ DOBRZE:
```c
#define MASK_SCRIPT_DATA_FUNCTIONAL (63 << 6)
#define SCRIPT_DATA_MEDUSA (2 << 26)
```

Wtedy preprocesor wstawi nawiasy do kodu (`iScriptData & (63 << 6)`), zmuszając silnik do poprawnej kolejności działań. Wpisanie wartości "z palca" (np. `4032`) też działa, ale używanie nawiasów w makrach jest znacznie czytelniejsze i chroni przed błędami w całym kodzie.