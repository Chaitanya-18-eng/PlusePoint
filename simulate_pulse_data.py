import firebase_admin
from firebase_admin import credentials, firestore
import random
import time

# Initialize Firebase Admin SDK
cred = credentials.Certificate('service-account.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

from weather_service import fetch_real_weather, calculate_weather_risk

def simulate_update(city_name="Pune"):
    region_id = city_name.lower()
    # Fetch real weather data
    temp, humidity, desc = fetch_real_weather(city_name)
    weather_score = calculate_weather_risk(temp, humidity)
    
    # New: City-Specific Hospital Profiles
    hospital_profiles = {
        "pune": [
            {"name": "Kothrud General", "dengue": random.randint(5, 30), "malaria": random.randint(2, 10), "unknown": random.randint(0, 5)},
            {"name": "Pune City Hospital", "dengue": random.randint(10, 45), "malaria": random.randint(5, 15), "unknown": random.randint(5, 20)},
            {"name": "Sahyadri Node", "dengue": random.randint(2, 12), "malaria": random.randint(1, 5), "unknown": random.randint(0, 2)}
        ],
        "mumbai": [
            {"name": "Gateway Health", "dengue": random.randint(20, 60), "malaria": random.randint(10, 30), "unknown": random.randint(5, 15)},
            {"name": "Metro Mumbai Hosp", "dengue": random.randint(15, 40), "malaria": random.randint(8, 20), "unknown": random.randint(10, 40)},
            {"name": "Juhu Clinic", "dengue": random.randint(5, 15), "malaria": random.randint(2, 8), "unknown": random.randint(0, 5)}
        ],
        "delhi": [
            {"name": "AIIMS Satellite", "dengue": random.randint(30, 80), "malaria": random.randint(15, 40), "unknown": random.randint(10, 25)},
            {"name": "Delhi Central", "dengue": random.randint(20, 50), "malaria": random.randint(10, 25), "unknown": random.randint(20, 60)},
            {"name": "Capital Care", "dengue": random.randint(10, 30), "malaria": random.randint(5, 15), "unknown": random.randint(5, 10)}
        ]
    }
    
    hospitals = hospital_profiles.get(region_id, [])
    pharmacy_stock = random.uniform(20, 100) # For High/Low Logic
    
    print(f"--- Fetched Weather for '{city_name}': {temp}C, {humidity}% ---")
    print(f"Updating {len(hospitals)} hospitals for {region_id}...")
    
    db.collection('regional_indices').document(region_id).set({
        'weather_score': weather_score,
        'temperature': temp,
        'humidity': humidity,
        'weather_desc': desc.capitalize(),
        'pharmacy_stock_idx': pharmacy_stock,
        'hospitals': hospitals,
        'last_updated': firestore.SERVER_TIMESTAMP
    })
    print(f"Update successful for {city_name}!")

if __name__ == "__main__":
    for city in ["Pune", "Mumbai", "Delhi"]:
        simulate_update(city)
        time.sleep(1)
