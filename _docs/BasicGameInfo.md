# Podstawowe Informacje o Grze (Polanie II / KnightShift)

Ten dokument zawiera kluczowe informacje o fundamentalnych mechanikach gry, które odróżniają ją od klasycznych RTS-ów i są istotne przy tworzeniu skryptów i modyfikacji.

## Ekonomia: Krowy i Mleko

W przeciwieństwie do gier, w których zbiera się drewno, złoto czy kamień, **absolutną podstawą ekonomii w Polanach II jest mleko**.

- **Krowy (Cows):** Pełnią rolę "zbieraczy" (harvesters) w grze. Krowy pasą się na trawie (która z czasem odrasta i nie może zostać wyeksploatowana do końca), a następnie wracają do Obory (Cowshed), by oddać zebrane mleko. Proces wypasu krów może zostać znacznie przyspieszony przez **Pastuszka (Shepherd)**.
- **Mleko (Milk):** To uniwersalna i główna waluta (surowiec) w grze. Mleka używa się do:
  - Budowania i ulepszania budynków.
  - Rekrutacji jednostek wojskowych, dystansowych i magicznych.
  - Wynajdowania nowych technologii i ulepszeń (Research).

Ochrona własnych krów oraz pastwisk przed wrogiem jest kluczowym elementem strategii. Utrata krów lub dostępu do trawy oznacza całkowite zatrzymanie ekonomii gracza. Wszelkie nagrody w postaci "Mleka" (np. artefakty `ART_MILK_GE_400`) to po prostu bezpośredni zastrzyk gotówki dla gracza.

## Budowanie i Rekrutacja

W grze występuje unikalny system budowania i przypisania jednostek do konkretnych struktur:

- **Budowanie:** Do wznoszenia budynków służy **Drwal (Woodcutter)**. Proces budowy może zostać znacznie przyspieszony, jeśli do pomocy zostanie przydzielona **Teściowa (Mother-in-law)**.
- **Struktury obronne:** Oprócz standardowych budynków produkcyjnych i rekrutacyjnych, w grze można budować również **palisady (mury)**, **wieże**, **bramy** oraz **mosty zwodzone**.
- **Zasady rozmieszczania budynków:** Standardowe budynki muszą być stawiane bezpośrednio przy **drodze**, którą gracz może kupować (budować). Wyjątkiem od tej reguły jest **Obora (Cowshed)**, którą można postawić na dowolnym płaskim terenie – najczęściej stawia się ją zaraz przy trawie, aby zoptymalizować czas wędrówki krów.

**Miejsca rekrutacji jednostek:**
- **Chata drwali (Hut):** Drwal (Woodcutter), Teściowa (Mother-in-law), Łowca (Hunter).
- **Chata wojów (Barracks):** Woj (Fighter), Włócznik (Spearman).
- **Dwór (Court):** Rycerz (Knight).
- **Wieża magów (Shrine):** Mag (Mage), Czarodziejka (Sorceress).
- **Świątynia (Temple):** Kapłan (Priest), Wiedźma (Witch).
