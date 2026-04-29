from firebase_functions import firestore_fn
from firebase_admin import initialize_app, firestore, messaging
import google.generativeai as genai

initialize_app()

@firestore_fn.on_document_written(document="regional_indices/{regionId}")
def analyze_pulse_risk(event: firestore_fn.Event[firestore_fn.Change[firestore_fn.DocumentSnapshot]]):
    db = firestore.client()
    data = event.data.after.to_dict()
    region_id = event.params["regionId"]

    # --- THE MULTIVARIATE FORMULA (Plagiarism-Free) ---
    # Weighting: Weather(40%) + Pharmacy(40%) + Search(20%)
    env_flux = data.get('weather_score', 0) * 0.4
    med_velocity = data.get('pharmacy_velocity', 0) * 0.4
    intent_momentum = data.get('search_intent', 0) * 0.2
    
    pulse_index = env_flux + med_velocity + intent_momentum

    # Threshold: 78.5 for Alert
    is_alert = pulse_index > 78.5
    status_label = "alert" if is_alert else "stable"
    hex_theme = "#FF5252" if is_alert else "#4CAF50"

    # --- FIRESTORE UPDATE: Drives the UI ---
    db.collection('regional_status').document(region_id).set({
        'status': status_label,
        'ui_theme': hex_theme,
        'pulse_score': round(pulse_index, 2),
        'reasoning': f"Regional Pulse at {pulse_index:.1f}%. Monitoring active.",
        'last_updated': firestore.SERVER_TIMESTAMP
    })

    # --- PUSH NOTIFICATION ---
    if is_alert:
        messaging.send(messaging.Message(
            notification=messaging.Notification(
                title=f"⚠️ PulsePoint Alert: {region_id.upper()}",
                body="Predictive outbreak risk detected. Stay informed."
            ),
            topic=f"pulse_alerts_{region_id}"
        ))