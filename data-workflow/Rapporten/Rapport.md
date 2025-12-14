---
title: "Analyse Parkeerbezetting & Luchtkwaliteit Gent"
author: "Arne Bogaert"
date: "07-12-2025 18:00"
geometry: margin=2cm
output: pdf_document
---

# 1. Inleiding

Dit rapport is onderdeel van de opdracht van de geautomatiseerde data-workflow. 
Het doel is om te onderzoeken of er een correlatie bestaat tussen de verkeersdrukte (gemeten aan de hand van vrije parkeerplaatsen) en de luchtkwaliteit in Gent.

De data is automatisch verzameld en verwerkt met behulp van Linux bash-scripts en Python.

# 2. Statistische Analyse

Hieronder volgen de berekende basisstatistieken van de verzamelde dataset. We gebruiken total_free_spots om te weten hoeveel vrije parkeerplaatsen er zijn op de moment, we gebruiken ook pm
2_5 en pm10 om de kleine deeltjes stofvervuiling te meten. pm2_5 zijn de heel fijne stofdeeltjes terwijl pm10 de iets grovere deeltjes zijn. Als laatste gebruiken we ook No2 om het aantal stikstofdioxide te meten in de lucht. Als metingswaarden gebruiken we Aantal om te weten hoeveel metingen er zijn, het gemiddelde voor het gemiddeld aantal parkeerplaatsen, de standaardafwijking om te kijken hoe hard de metingen schommelen, en dan uiteindelijk het minimum en maximum.

```text
=== BASIS STATISTIEKEN DATASET GENT ===

                  Aantal  Gemiddelde  Afwijking  Minimum  Maximum
total_free_spots    19.0     6020.79     624.40   4960.0   6702.0
pm2_5               19.0        4.70       1.11      3.5      6.3
pm10                19.0        6.60       2.23      4.2      9.8
no2                 19.0        6.82       0.96      5.2      8.5

=== CORRELATIE MATRIX ===

                  total_free_spots  pm2_5  pm10   no2
total_free_spots              1.00   0.79  0.78  0.17
pm2_5                         0.79   1.00  0.98 -0.25
pm10                          0.78   0.98  1.00 -0.16
no2                           0.17  -0.25 -0.16  1.00
```

# 3. Visualisatie

De onderstaande grafiek toont het verloop van de parkeercapaciteit (blauwe as) ten opzichte van de concentraties PM2.5, PM10 en NO2 (zwarte as) over de tijd.

![07-12-2025 18:00 - Grafiek Parkeren vs Lucht](../data/analyse_grafiek.png)

# 4. Conclusie en Observaties

Op basis van een analyse van de data kunnen we enkele interessante observaties maken:

1.  **Dag/Nacht Cyclus:** Er is een duidelijk patroon zichtbaar in de parkeerbezetting, waarbij de parkings 's nachts leeglopen en overdag voller raken.
2.  **Omgekeerde Correlatie (Weersinvloeden):** Tijdens de metingen stelden we vast dat hoewel de parkeerdrukte toenam (minder vrije plaatsen), de gemeten luchtvervuiling (NO2) juist daalde. 
    
    Dit gaat in tegen de initiële hypothese ("meer auto's = meer vervuiling"). Een waarschijnlijke verklaring hiervoor zijn meteorologische omstandigheden (zoals wind of regen) die de vervuiling 's ochtends hebben "schoongeveegd", ondanks de toegenomen verkeersdrukte. Dit toont aan dat luchtkwaliteit sterk afhankelijk is van weersfactoren en niet enkel van lokale emissies.

---
*Gegenereerd door: Geautomatiseerd script workflow.sh*
