# Tryb Tower Defense (TD)

Dokument ten stanowi skrócony opis mechanik i struktury trybu Tower Defense w modyfikacji _KnightShift Golden Edition RTS_.

## 1. Ogólne założenia

Tryb Tower Defense polega na obronie przed nacierającymi falami przeciwników. Gracze (od 1 do 3 osób, sloty 0-2) współpracują, budując struktury obronne i rekrutując jednostki, aby przetrwać jak najdłużej.

## 2. Fale i Bossowie (Waves & Bosses)

- **Cykl gry:** Gra podzielona jest na naprzemienne fazy: czas trwania fali (atak) oraz czas przerwy (Break Time), podczas którego gracze mogą się leczyć, budować i zbierać nagrody.
- **Bossowie:** Co 10 fal następuje runda z Bossem (np. Minotaur, Demon, Necromancer, Titan, Witch). Po pokonaniu Bossa gracze otrzymują dodatkowy czas na przygotowanie przed kolejnymi falami.
- **Skalowanie:** Czas trwania fal oraz przerw skaluje się dynamicznie w zależności od numeru fali i wybranego poziomu trudności.

## 3. System Nagród (Rewards)

Po zakończeniu każdej fali, na specjalnych markerach (od `FIRST_REWARD_MARKER` do `LAST_REWARD_MARKER`) pojawiają się nagrody.

- **Rodzaje nagród:**
  - **Jednostki (Więźniowie):** Podzielone na 6 poziomów (Tier 1-6). Gracz przejmuje jednostkę podchodząc do niej (mechanika `MASK_PRISONER`).
  - **Ekwipunek (Equipment):** Bronie, pancerze.
  - **Doświadczenie (Experience):** Pola dodające poziom doświadczenia jednostkom.
  - **Suplementy (Supplements):** Mikstury i bonusy statystyk.
- **Mleko (Milk Reward):** Specjalna nagroda pojawiająca się na `MILK_MARKER`. Ponieważ mleko to główny surowiec w grze, zebranie tej nagrody daje graczom potężny zastrzyk ekonomiczny na rozbudowę obrony i rekrutację.
- Pula nagród jest losowana z użyciem bezpiecznego ziarna (Seed), aby zapobiec oszukiwaniu poprzez wczytywanie zapisu gry (save scumming).

## 4. Skalowanie i Rozwój (Research & Buildings)

- **Gracze (Obrońcy):** Wraz z postępem fal, gracze otrzymują zwiększone limity budynków obronnych (wieże, mury, bramy) oraz dostęp do nowych technologii.
- **Przeciwnicy (AI):** Przeciwnicy (w tym jednostki elitarne) regularnie otrzymują ulepszenia pancerza, broni i magii (`UpdateAiResearch`), co sprawia, że stają się coraz silniejsi.
- **Więźniowie:** Jednostki otrzymywane jako nagrody również są automatycznie ulepszane (`UpdatePrisonerPlayerResearch`), aby ich statystyki nadążały za poziomem trudności późniejszych fal.

## 5. Role Graczy (Numery IFF / Player ID)

W skryptach trybu TD poszczególni gracze (numery od 0 do 15) mają przypisane sztywne role:

- **0, 1, 2:** Gracze (Obrońcy)
- **9, 11, 12:** Fale przeciwników (AI)
- **10:** Bossowie
- **13:** Gracz "Więźniów" (Neutralny, posiada jednostki-nagrody zanim zostaną przejęte)
- **14:** Pułapki i specyficzne mechaniki mapy

## 6. Statystyki

Tryb posiada dedykowaną zakładkę statystyk (`InitializeTDStatistics`), która śledzi m.in.:

- Przetrwane fale
- Zbudowane mury, wieże i bramy
- Zdetonowane krowy (Exploded Cows)
