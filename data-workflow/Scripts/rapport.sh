#!/bin/bash
# ---------------------------------------------------------------------------
# Script: 14_rapport.sh
# Doel: Genereert automatisch een analyserapport in Markdown en PDF/HTML.
# ---------------------------------------------------------------------------

# 1. Paden Instellen
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${SCRIPT_DIR}/.."
DATA_DIR="${BASE_DIR}/data"

# Output bestanden
REPORT_DIR="${BASE_DIR}/Rapporten"
REPORT_FILENAME="Rapport"

REPORT_MD="${REPORT_DIR}/${REPORT_FILENAME}.md"
REPORT_HTML="${REPORT_DIR}/${REPORT_FILENAME}.html"
REPORT_PDF="${REPORT_DIR}/${REPORT_FILENAME}.pdf"

# Input bestanden
STATS_FILE="${DATA_DIR}/analyse_stats.txt"

GRAPH_REL_PATH="../data/analyse_grafiek.png"

TIMESTAMP=$(date +"%d-%m-%Y %H:%M")

echo "Genereren van Rapport..."

mkdir -p "$REPORT_DIR"

# ---------------------------------------------------------------------------
# 2. Markdown Rapport Schrijven
# ---------------------------------------------------------------------------

cat <<EOF > "$REPORT_MD"
---
title: "Analyse Parkeerbezetting & Luchtkwaliteit Gent"
author: "Arne Bogaert"
date: "$TIMESTAMP"
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

\`\`\`text
$(cat "$STATS_FILE" 2>/dev/null || echo "Geen statistieken gevonden.")
\`\`\`

# 3. Visualisatie

De onderstaande grafiek toont het verloop van de parkeercapaciteit (blauwe as) ten opzichte van de concentraties PM2.5, PM10 en NO2 (zwarte as) over de tijd.

![$TIMESTAMP - Grafiek Parkeren vs Lucht]($GRAPH_REL_PATH)

# 4. Conclusie en Observaties

Op basis van een analyse van de data kunnen we enkele interessante observaties maken:

1.  **Dag/Nacht Cyclus:** Er is een duidelijk patroon zichtbaar in de parkeerbezetting, waarbij de parkings 's nachts leeglopen en overdag voller raken.
2.  **Omgekeerde Correlatie (Weersinvloeden):** Tijdens de metingen stelden we vast dat hoewel de parkeerdrukte toenam (minder vrije plaatsen), de gemeten luchtvervuiling (NO2) juist daalde. 
    
    Dit gaat in tegen de initiële hypothese ("meer auto's = meer vervuiling"). Een waarschijnlijke verklaring hiervoor zijn meteorologische omstandigheden (zoals wind of regen) die de vervuiling 's ochtends hebben "schoongeveegd", ondanks de toegenomen verkeersdrukte. Dit toont aan dat luchtkwaliteit sterk afhankelijk is van weersfactoren en niet enkel van lokale emissies.

---
*Gegenereerd door: Geautomatiseerd script workflow.sh*
EOF

echo "Markdown rapport aangemaakt: $REPORT_MD"

# ---------------------------------------------------------------------------
# 3. Conversie naar Eindformaat (Pandoc)
# ---------------------------------------------------------------------------

cd "$REPPORT_DIR" || exit

if command -v pandoc &> /dev/null; then
    echo "Pandoc gevonden. Start conversie..."
    
    # HTML Conversie
    pandoc "$REPORT_MD" -s -o "$REPORT_HTML" --metadata title="Data Rapport"
    echo "- HTML versie aangemaakt: $REPORT_HTML"

    # PDF Conversie
    if pdflatex --version &> /dev/null; then
        pandoc "$REPORT_MD" -o "$REPORT_PDF"
        
        if [ -f "$REPORT_PDF" ]; then
             echo "- PDF versie aangemaakt: $REPORT_PDF"
        else
             echo "! Fout bij maken PDF. Controleer of 'texlive-latex-extra' is geïnstalleerd."
        fi
    else
        echo "! Geen PDF gegenereerd (pdflatex niet gevonden)."
    fi
else
    echo "! Pandoc niet geïnstalleerd."
fi

echo "Klaar!"
