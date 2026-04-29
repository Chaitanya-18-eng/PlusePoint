import requests

# --- CONFIGURATION ---
# Replace with your free key from: https://openweathermap.org/api
OPENWEATHER_API_KEY = "YOUR_OPENWEATHER_API_KEY"
DEFAULT_CITY = "Pune"

def fetch_real_weather(city=DEFAULT_CITY):
    """
    Fetches real-time weather data for a given city.
    Returns: (temp_c, humidity_pct, description)
    """
    try:
        url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={OPENWEATHER_API_KEY}&units=metric"
        response = requests.get(url, timeout=10)
        data = response.json()
        
        if response.status_code == 200:
            temp = data['main']['temp']
            humidity = data['main']['humidity']
            desc = data['weather'][0]['description']
            return temp, humidity, desc
        else:
            print(f"[WEATHER] API Error: {data.get('message', 'Unknown Error')}")
            return 28.5, 72.0, "connection error (fallback)"
    except Exception as e:
        print(f"[WEATHER] Exception: {e}")
        return 28.5, 72.0, "exception (fallback)"

def calculate_weather_risk(temp, humidity):
    """
    Translates raw weather metrics into a 0-100 risk score.
    Logic: High humidity (>75%) triggers vector-borne risk. 
    Temp shifts away from 24 deg C trigger respiratory/stress risk.
    """
    # 1. Humidity Contribution (Max 70 points)
    # Scaled such that 85% humidity = 70 points
    h_contribution = (humidity / 85.0) * 70.0
    h_contribution = min(h_contribution, 70.0)
    
    # 2. Temperature Contribution (Max 30 points)
    # Baseline is 24°C. Deviation of 8 degrees = 30 points
    t_diff = abs(temp - 24.0)
    t_contribution = (t_diff / 8.0) * 30.0
    t_contribution = min(t_contribution, 30.0)
    
    final_score = h_contribution + t_contribution
    return round(final_score, 2)

if __name__ == "__main__":
    t, h, d = fetch_real_weather()
    score = calculate_weather_risk(t, h)
    print(f"City: {DEFAULT_CITY} | Temp: {t}°C | Humidity: {h}% | Desc: {d}")
    print(f"Calculated Environmental Risk Score: {score}/100")
