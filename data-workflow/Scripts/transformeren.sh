#!/bin/bash
# ---------------------------------------------------------------------------
# Script: 12_transformeren.sh
# Doel: Zet ruwe JSON (parking + luchtkwaliteit) om naar één CSV-bestand.
# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${SCRIPT_DIR}/.."

# Input en Output mappen
DATA_DIR="${BASE_DIR}/data"
JSON_DIR="${DATA_DIR}/JSON"
OUTPUT_FILE="${DATA_DIR}/dataset_gent.csv"

# Tijdelijke bestanden
TEMP_PARKING="${DATA_DIR}/tmp_parking.csv"
TEMP_AIR="${DATA_DIR}/tmp_air.csv"

# Setup Header
echo "timestamp,total_free_spots,pm2_5,pm10,no2" > "$OUTPUT_FILE"

# ---------------------------------------------------------------------------
# STAP 1: Verwerk Parking Data 
# ---------------------------------------------------------------------------
rm -f "$TEMP_PARKING"

for file in "${JSON_DIR}"/parking-*.json; do
    [ -e "$file" ] || continue 

    #  Check op lege data 
    # We kijken of total_count bestaat en niet 0 is
    HAS_DATA=$(jq '.total_count // 0' "$file")
    
    if [ "$HAS_DATA" == "0" ]; then
        # Als er 0 resultaten zijn, slaan we dit bestand over
        # echo "Skipping empty file: $(basename "$file")"
        continue
    fi

    FILE_ID=$(basename "$file" | sed 's/parking-//; s/.json//')
    TIMESTAMP_ISO="${FILE_ID:0:4}-${FILE_ID:4:2}-${FILE_ID:6:2}T${FILE_ID:9:2}:${FILE_ID:11:2}:${FILE_ID:13:2}"

    TOTAL_FREE=$(jq -r '[.results[].availablecapacity] | add' "$file")
    echo "$FILE_ID,$TIMESTAMP_ISO,$TOTAL_FREE" >> "$TEMP_PARKING"
done

# ---------------------------------------------------------------------------
# STAP 2: Verwerk Air Quality Data
# ---------------------------------------------------------------------------
rm -f "$TEMP_AIR"

for file in "${JSON_DIR}"/air-quality-*.json; do
    [ -e "$file" ] || continue

    FILE_ID=$(basename "$file" | sed 's/air-quality-//; s/.json//')
    VALS=$(jq -r '[.current.pm2_5, .current.pm10, .current.nitrogen_dioxide] | @csv' "$file" | tr -d '"')

    echo "$FILE_ID,$VALS" >> "$TEMP_AIR"
done

# ---------------------------------------------------------------------------
# STAP 3: Samenvoegen
# ---------------------------------------------------------------------------
sort -t, -k1,1 -o "$TEMP_PARKING" "$TEMP_PARKING"
sort -t, -k1,1 -o "$TEMP_AIR" "$TEMP_AIR"

join -t, -1 1 -2 1 -o 1.2,1.3,2.2,2.3,2.4 "$TEMP_PARKING" "$TEMP_AIR" >> "$OUTPUT_FILE"

rm -f "$TEMP_PARKING" "$TEMP_AIR"

echo "Transformatie klaar. Resultaat in: $OUTPUT_FILE"
head -n 5 "$OUTPUT_FILE"
