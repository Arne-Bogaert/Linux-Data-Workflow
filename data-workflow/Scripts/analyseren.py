import pandas as pd
import matplotlib.pyplot as plt
import os

# ---------------------------------------------------------------------------
# Instellingen en Paden
# ---------------------------------------------------------------------------
# Het script staat in .../data-workflow/Scripts
script_dir = os.path.dirname(os.path.abspath(__file__))

# We gaan één niveau omhoog en dan naar data
data_dir = os.path.join(script_dir, '..', 'data')

csv_path = os.path.join(data_dir, 'dataset_gent.csv')
output_image = os.path.join(data_dir, 'analyse_grafiek.png')
output_stats = os.path.join(data_dir, 'analyse_stats.txt')

print("--- Start Analyse ---")

# 1. Data inlezen
if not os.path.exists(csv_path):
    print(f"FOUT: Bestand niet gevonden: {csv_path}")
    print("Heb je transformeren.sh al uitgevoerd?")
    exit(1)

# Lees CSV in
df = pd.read_csv(csv_path)

# Zet de timestamp kolom om naar datetime
df['timestamp'] = pd.to_datetime(df['timestamp'])
df = df.sort_values('timestamp')

# ---------------------------------------------------------------------------
# 2. Basisstatistieken
# ---------------------------------------------------------------------------
print("Statistieken berekenen...")

with open(output_stats, 'w') as f:
    f.write("=== BASIS STATISTIEKEN DATASET GENT ===\n\n")
    
    # VERBETERING:
    # 1. .transpose() draait de tabel om (variabelen onder elkaar)
    # 2. .round(2) rondt af op 2 cijfers na de komma
    # 3. We filteren de timestamp eruit omdat je daar geen gemiddelde van kan nemen op deze manier
    stats = df.drop(columns=['timestamp']).describe().transpose().round(2)
    stats = stats.drop(columns=['25%', '50%', '75%'])
    
    # We vertalen de kolomnamen naar het Nederlands voor het rapport
    stats = stats.rename(columns={
        'count': 'Aantal',
        'mean': 'Gemiddelde',
        'std': 'Afwijking',
        'min': 'Minimum',
        'max': 'Maximum'
    })

    f.write(stats.to_string())
    
    f.write("\n\n=== CORRELATIE MATRIX ===\n\n")
    numeric_df = df.select_dtypes(include=['float64', 'int64'])
    corr = numeric_df.corr().round(2) # Ook afronden
    f.write(corr.to_string())

print(f"Statistieken opgeslagen in: {output_stats}")

# ---------------------------------------------------------------------------
# 3. Grafiek Genereren
# ---------------------------------------------------------------------------
print("Grafiek genereren...")

fig, ax1 = plt.subplots(figsize=(12, 6))

# As 1: Totaal vrije parkeerplaatsen
color_park = 'tab:blue'
ax1.set_xlabel('Tijd')
ax1.set_ylabel('Vrije Parkeerplaatsen', color=color_park, fontweight='bold')
ax1.plot(df['timestamp'], df['total_free_spots'], color=color_park, label='Vrije Plaatsen', linewidth=2)
ax1.tick_params(axis='y', labelcolor=color_park)
ax1.grid(True, linestyle='--', alpha=0.3)

# As 2: Luchtkwaliteit
ax2 = ax1.twinx()
ax2.set_ylabel('Concentratie (µg/m³)', color='black', fontweight='bold')

ln1 = ax2.plot(df['timestamp'], df['pm2_5'], color='green', linestyle='--', label='PM2.5 (Fijnstof)', alpha=0.8)
ln2 = ax2.plot(df['timestamp'], df['no2'], color='red', linestyle='-', label='NO2 (Stikstof)', alpha=0.8)

ax2.tick_params(axis='y', labelcolor='black')

plt.title('Evolutie Parkeerbezetting vs. Luchtkwaliteit Gent', fontsize=14)
fig.tight_layout()

# Legendes combineren
lines_1, labels_1 = ax1.get_legend_handles_labels()
lines_2, labels_2 = ax2.get_legend_handles_labels()
ax1.legend(lines_1 + lines_2 + ln1 + ln2, labels_1 + labels_2 + ['PM2.5', 'NO2'], loc='upper left')

# Opslaan
plt.savefig(output_image)
print(f"Grafiek opgeslagen als: {output_image}")
print("--- Analyse Voltooid ---")
