#!/bin/bash
# ---------------------------------------------------------------------------
# Script: 11_verzamelen.sh
# Omschrijving: Verzamelt data van Stad Gent (Parkeren) en Open-Meteo (Lucht)
# ---------------------------------------------------------------------------

# Absolute pad naar het script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# map omhoog gaan voor downloads en logs map
BASE_DIR="${SCRIPT_DIR}/.."
DATA_JSON_DIR="${BASE_DIR}/data/JSON"
LOG_DIR="${BASE_DIR}/logs"
LOG_FILE="${LOG_DIR}/download.log"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# URLs van de API's
# Bron 1: Stad Gent Parkeergarages
URL_PARKING="https://data.stad.gent/api/explore/v2.1/catalog/datasets/bezetting-parkeergarages-real-time/records?limit=20"
# Bron 2: Luchtkwaliteit Gent
URL_AIR="https://air-quality-api.open-meteo.com/v1/air-quality?latitude=51.05&longitude=3.72&current=pm10,pm2_5,nitrogen_dioxide&timezone=Europe%2FBrussels"

# Functies
log_message() {
    local TYPE=$1
    local MSG=$2
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [$TYPE] $MSG" >> "$LOG_FILE"
}

download_source() {
    local URL=$1
    local NAME=$2
    local FILE_PATH="${DATA_JSON_DIR}/${NAME}-${TIMESTAMP}.json"

    if curl -s "$URL" -o "$FILE_PATH"; then
        if [ -s "$FILE_PATH" ]; then
            log_message "INFO" "Succesvol gedownload: $(basename "$FILE_PATH")"
            chmod 444 "$FILE_PATH"
        else
            log_message "ERROR" "Download van $NAME was leeg."
            rm -f "$FILE_PATH"
        fi
    else
        log_message "ERROR" "Kon data niet ophalen voor: $NAME"
    fi
}

# Mappen aanmaken indien ze niet bestaan
mkdir -p "$DATA_JSON_DIR"
mkdir -p "$LOG_DIR"

# De downloads starten
download_source "$URL_PARKING" "parking"
download_source "$URL_AIR" "air-quality"
