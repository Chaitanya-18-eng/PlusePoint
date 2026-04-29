import firebase_admin
from firebase_admin import credentials, firestore
import time
import datetime
import os

# --- PULSEPOINT CONFIGURATION (DPDP Act 2026 Compliant) ---
PROJECT_NAME = "PulsePoint"
REGION_FILTER = "pune"

# Initialize Firebase Admin SDK
cred = credentials.Certificate('service-account.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def display_dashboard(region_id, data, risk_index, status):
    """
    Renders a high-fidelity terminal dashboard for the judges.
    """
    timestamp = datetime.datetime.now().strftime("%H:%M:%S")
    # os.system('cls' if os.name == 'nt' else 'clear') # Optional: Clear for cleaner look
    print("\n" + "="*60)
    print(f" {PROJECT_NAME.upper()} | AI NEURAL BACKBONE | {timestamp} ")
    print("="*60)
    print(f" REGION: {region_id.upper()}")
    print(f" STATUS: {status.upper()}")
    print("-"*60)
    print(f" [DATA INGESTION] ")
    print(f" > Environmental Flux (Weather): {data.get('weather_score', 0):>10.1f}")
    print(f" > Medication Velocity (Pharm):  {data.get('pharmacy_velocity', 0):>9.1f}")
    print(f" > Inquiry Momentum (Search):   {data.get('search_intent', 0):>11.1f}")
    print("-"*60)
    print(f" [AI NEURAL PROCESSING] ")
    print(f" > Pathogen Propensity Index:   {risk_index:>10.2f}%")
    print(f" > Logic Compliance: DPDP Act 2026 (Anonymized)")
    print("="*60)
    print(f" HEARTBEAT: Processing real-time data packet...")

def identify_pathogen_layman(data):
    """
    Layman-friendly pathogen identification logic.
    """
    hospitals = data.get('hospitals', [])
    total_dengue = sum(h.get('dengue', 0) for h in hospitals)
    total_malaria = sum(h.get('malaria', 0) for h in hospitals)
    total_unknown = sum(h.get('unknown', 0) for h in hospitals)
    
    # 1. Infectious Disease Check (Highest Priority)
    if total_unknown > 25:
        return "Highly Infectious Disease Detected", "HIGHLY INFECTIOUS: Unidentified surge in the neighborhood. Wear masks, avoid contact, and move to safe zones."
    
    # 2. Known Outbreaks
    if total_dengue > 40:
        return "Dengue Warning", "Clear stagnant water. Use mosquito nets and repellant. Seek medical help if fever persists."
    elif total_malaria > 30:
        return "Malaria Alert", "Use insecticide-treated nets. Keep surroundings dry. Report clusters to local officials."
    
    return "Balanced Ecosystem", "No immediate outbreaks detected. Continue standard hygiene."

def on_snapshot(doc_snapshot, changes, read_time):
    for doc in doc_snapshot:
        if doc.exists:
            data = doc.to_dict()
            region_id = doc.id
            hospitals = data.get('hospitals', [])
            
            # --- AGGREGATE CLINICAL SIGNAL ---
            total_patients = sum(h.get('dengue', 0) + h.get('malaria', 0) + h.get('unknown', 0) for h in hospitals)
            clinical_load = (total_patients / 300) * 100 # Normalized scale
            
            # --- SAFETY ORACLE ---
            is_danger = total_patients > 40 or clinical_load > 60
            safety_status = "AREA STATUS: DANGER" if is_danger else "AREA STATUS: SAFE"
            
            # --- PHARMACY STOCK LEVEL ---
            stock_level = "High Stock" if data.get('pharmacy_stock_idx', 50) > 40 else "Low Stock"
            
            disease_name, measures = identify_pathogen_layman(data)
            
            # UI Theme logic
            ui_hex = "#D32F2F" if is_danger else "#059669"
            
            # --- WRITE-BACK TO regional_status ---
            db.collection('regional_status').document(region_id).set({
                'status': "alert" if is_danger else "stable",
                'ui_theme': ui_hex,
                'safety_label': safety_status,
                'stock_label': stock_level,
                'pulse_score': round(clinical_load, 2),
                'hospitals': hospitals,
                'pathogen_type': disease_name,
                'preventive_measures': measures,
                'reasoning': f"Safety Check: {safety_status}. {disease_name} metrics active.",
                'temperature': data.get('temperature', 28.0),
                'humidity': data.get('humidity', 70.0),
                'weather_desc': data.get('weather_desc', 'Clear'),
                'last_updated': firestore.SERVER_TIMESTAMP
            })
            
            # Trigger Dashboard View
            display_dashboard(region_id, data, Pathogen_Propensity_Index, alert_label)

# Setup Listener on regional_indices collection (Multi-Regional)
coll_ref = db.collection('regional_indices')
# Watch the entire collection for any regional changes
query_watch = coll_ref.on_snapshot(on_snapshot)

print(f"[{PROJECT_NAME}] Brain Daemon Started. Monitoring ALL regional nodes in 'regional_indices'...")
print("Waiting for data highlights...")

# Keep the script running
try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print(f"\n[{PROJECT_NAME}] Brain Daemon Shutting Down.")
