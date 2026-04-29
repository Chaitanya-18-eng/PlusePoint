import firebase_admin
from firebase_admin import credentials, firestore
import sys

# Initialize Firebase Admin SDK
cred = credentials.Certificate('service-account.json')
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)
db = firestore.client()

def trigger_scenario(profile_type):
    """
    profile_type: 'vector' or 'respiratory'
    """
    if profile_type == 'vector':
        # High Weather Humidity driver
        weather, pharmacy, search = 92.0, 60.0, 70.0
        disease = "Vector-Borne (Dengue/Malaria)"
    else:
        # High Pharmacy Velocity driver
        weather, pharmacy, search = 65.0, 88.0, 80.0
        disease = "Respiratory (Influenza/Flu)"

    # Formula: (W * 0.4) + (P * 0.4) + (S * 0.2)
    # Vector: (92 * 0.4) + (60 * 0.4) + (70 * 0.2) = 36.8 + 24 + 14 = 74.8 (Borderline)
    # Respiratory: (65 * 0.4) + (88 * 0.4) + (80 * 0.2) = 26 + 35.2 + 16 = 77.2 (Borderline)
    
    # We force them above 78.5 for the alert
    if profile_type == 'vector':
        weather = 96.0 # 38.4 + 24 + 14 = 76.4. Still low. Let's pump search.
        search = 90.0 # 38.4 + 24 + 18 = 80.4 -> ALERT
    else:
        pharmacy = 95.0 # 26 + 38 + 16 = 80.0 -> ALERT

    print(f"--- TRIGGERING {disease.upper()} OUTBREAK ---")
    
    db.collection('regional_indices').document('pune').set({
        'weather_score': weather,
        'pharmacy_velocity': pharmacy,
        'search_intent': search,
        'last_updated': firestore.SERVER_TIMESTAMP
    })
    print(f"Success. Check your phone for Title: 'CRITICAL: Outbreak Predicted'")
    print(f"The Mobile UI should now be RED and show: {disease}")

if __name__ == "__main__":
    profile = sys.argv[1] if len(sys.argv) > 1 else 'vector'
    trigger_scenario(profile)
