#!/bin/bash
# ---------------------------------------------------------------------------
# Script: 15_workflow.sh
# Doel: Voert de volledige data-workflow uit:
#       1. Data Verzamelen
#       2. Transformeren naar CSV
#       3. Analyseren (Grafiek + Stats)
#       4. Rapport Genereren (PDF/HTML)
# ---------------------------------------------------------------------------

# Bepaal de map waar dit script staat
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${SCRIPT_DIR}/../logs/workflow.log"

# Functie voor logging
log() {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] [WORKFLOW] $1" >> "$LOG_FILE"
}

log "=== Start Volledige Workflow ==="

# Stap 1: Verzamelen
# (Dit script is silent van zichzelf, dus we loggen expliciet de start/stop)
log "Stap 1: Data Verzamelen..."
"$SCRIPT_DIR/verzamelen.sh"
if [ $? -ne 0 ]; then log "FOUT tijdens verzamelen!"; exit 1; fi

# Stap 2: Transformeren
log "Stap 2: Transformeren naar CSV..."
"$SCRIPT_DIR/transformeren.sh" > /dev/null
if [ $? -ne 0 ]; then log "FOUT tijdens transformeren!"; exit 1; fi

# Stap 3: Analyseren
log "Stap 3: Analyseren en Grafieken..."
python3 "$SCRIPT_DIR/analyseren.py" > /dev/null
if [ $? -ne 0 ]; then log "FOUT tijdens analyseren!"; exit 1; fi

# Stap 4: Rapport
log "Stap 4: Rapport Genereren..."
"$SCRIPT_DIR/rapport.sh" > /dev/null
if [ $? -ne 0 ]; then log "FOUT tijdens rapportage!"; exit 1; fi

log "=== Workflow Succesvol Voltooid ==="
