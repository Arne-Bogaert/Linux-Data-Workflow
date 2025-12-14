# Data Workflow opdracht 
**Linux for Data Scientists (2025-2026)**

* **Auteur:** Arne Bogaert
* **Onderwerp:** Correlatieonderzoek Parkeerdrukte in Gent vs. Luchtkwaliteit in Gent

---

## Inleiding

Dit project is een geautomatiseerde data pipeline. De workflow verzamelt periodiek data uit verschillende bronnen, transformeert deze naar een analyseerbaar formaat, voert een statistische analyse uit en genereert automatisch een eindrapport in PDF en HTML formaat.

De centrale onderzoeksvraag is: **"Is er een verband tussen de bezettingsgraad van parkeergarages in Gent en de lokale luchtkwaliteit?"**

---

## 📂 Directory Structuur

Het project is modulair opgebouwd om de verschillende fasen van de data-engineering lifecycle te scheiden:

```text
linux-2526-ArneBogaert/
├── .github/workflows/      # configuratie voor Github Actions
├── data-workflow/
│   ├── data/
│   │   ├── JSON/           # Opslag voor ruwe data
│   │   ├── dataset_gent.csv        # Het getransformeerde eindbestand
│   │   ├── analyse_grafiek.png     # png van gegenereerde grafiek
│   │   └── analyse_stats.txt 
│   ├── logs/               # Logbestanden (download.log, workflow.log)
│   ├── Rapporten/          # Gegenereerde output (PDF, HTML, MD)
│   ├── Scripts/            # Alle uitvoerbare scripts
│   │   ├── 11_verzamelen.sh        # Verzamelt de data in JSON formaat
│   │   ├── 12_transformeren.sh     # Transformeert de data naar een bruikbaar CSV bestand
│   │   ├── 13_analyseren.py        # Analyseert de data met python en python libraries(pandas)
│   │   ├── 14_rapport.sh           # Genereert automatisch een rapport in PDF, HTML en MD formaat
│   │   └── 15_workflow.sh          # Master script dat alles bij elkaar samenvoegt en de hele workflow uitvoert
│   └── README.md           # Deze documentatie
└── ...
```

---

## Workflow Onderdelen

### 1.1 Verzamelen ruwe tijdseriedata
**Doel:** Het periodiek ophalen van data uit externe API's.

* **Bronnen:**
    * **Stad Gent Open Data:** Real-time bezetting van parkeergarages (JSON).
    * **Open-Meteo Air Quality API:** Actuele waarden voor PM2.5, PM10 en NO2 (JSON).
* **Keuzes & Technieken:**
    * **Immutability:** Ruwe data wordt opgeslagen in aparte JSON-bestanden met een tijdstempel in de naam. Deze bestanden worden **read-only** (`chmod 444`) gemaakt om de integriteit van de ruwe data te garanderen.
    * **Silent Script:** Het script draait zonder output naar het scherm en logt statusmeldingen naar `logs/download.log`.
* **Periode:** Data is verzameld van 3 december 2025 t.e.m. 7 december 2025, voor de demo wordt nog data voorzien van een paar dagen om te tonen dat het script ook met nieuwe data kan omgaan.

### 1.2 Data Transformeren
**Doel:** De ongestructureerde JSON-bestanden omzetten naar één CSV-dataset.

* **Tools:** `jq` (voor JSON parsing), `sort`, `join`.
* **Keuzes:**
    * **JSON Parsing:** We gebruiken `jq` om diep in de JSON-structuur te duiken en specifieke velden eruit te filteren.
    * **Aggregatie:** De beschikbare plaatsen van alle parkings in Gent worden opgeteld tot één totaalcijfer per tijdstip.
    * **Foutafhandeling:** Bestanden die door API-fouten leeg zijn of 0 resultaten bevatten, worden automatisch gedetecteerd en overgeslagen om de dataset niet te vervuilen.
    * **Merging:** De data van parkeren en luchtkwaliteit wordt samengevoegd op basis van de tijdstempel in de bestandsnaam.

### 1.3 Data Analyseren
**Doel:** Visualisatie en statistische berekening.

* **Tools:** Python (`pandas`, `matplotlib`).
* **Keuzes:**
    * **Grafiek:** Omdat parkeerplaatsen en fijnstof totaal verschillende schalen hebben, gebruiken we een grafiek met twee Y-assen.
    * **Data Cleaning:** In de statistiekentabel worden verwarrende kwartielen (25%/75%) weggelaten en kolomnamen vertaald naar het Nederlands voor leesbaarheid in het rapport.
    * **Correlatiematrix:** Er wordt berekend of er een wiskundig verband is tussen de variabelen.

### 1.4 Rapport Genereren
**Doel:** Automatische verslaggeving.

* **Tools:** Bash, `pandoc`, `pdflatex`.
* **Keuzes:**
    * **Multi-format:** Het rapport wordt gegenereerd in Markdown, en vervolgens door `pandoc` geconverteerd naar HTML en PDF.
    * **Dynamische Inhoud:** De datum, de berekende statistieken en de grafiek worden automatisch in het sjabloon gegenereerd.
    * **Relatieve Paden:** Het script houdt rekening met de werkmap van Pandoc om afbeeldingen correct te vinden, ongeacht waar het script wordt aangeroepen.

### 1.5 Automatisering
**Doel:** De volledige workflow zonder menselijke tussenkomst laten draaien.

* **Master Script:** `workflow.sh` voert alle bovenstaande stappen sequentieel uit en stopt bij fouten.
* **Crontab:** De VM is geconfigureerd om dit script elk uur uit te voeren.
* **Github Actions:** Bij elke push van nieuwe data naar de repository bouwt Github automatisch de pagina's opnieuw op.

---

# Handleiding

## 1. Vereisten
Zorg dat de volgende tools geïnstalleerd zijn op je Linux-systeem:

```bash
sudo apt update
sudo apt install jq pandoc texlive-latex-recommended texlive-latex-extra python3-pandas python3-matplotlib
```

## 2. Installatie
Clone de repo en maak de scripts uitvoerbaar 
```bash
git clone https://github.com/HoGentTIN/linux-2526-ArneBogaert
cd linux-2526-ArneBogaert/data-workflow
chmod +x Scripts/*.sh
```

## 3. De workflow uitvoeren
Je kan de volledige workflow uitvoeren met 1 commando
```bash
./Scripts/15_workflow.sh
```
Dit zal:

* Nieuwe data downloaden.
* De CSV updaten.
* De grafiek en statistieken verversen.
* Een nieuw rapport genereren in de map `Rapporten/`.

## 4. Het resultaat bekijken
Na uitvoering vind je de resultaten hier:

* **Rapport:** Open `Rapporten/Rapport.pdf` of `Rapporten/Rapport.html` in je browser.
* **Data:** Bekijk `data/dataset_gent.csv`.
* **Logs:** Controleer `logs/workflow.log` om te zien of alles goed is gegaan.



