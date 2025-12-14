#!/usr/bin/env python3
"""
N-ATLaS Inference Server for RouteGuardian
TRIPLE FALLBACK NEWS SEARCH:
1. NewsAPI.org (reliable, full articles)
2. Google News scraping (free, no key)
3. Demo fallback data (always works)
"""

import json
import sys
import os
import re
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import parse_qs, urlparse, quote_plus
from datetime import datetime, timedelta

# For web requests
try:
    import urllib.request
    HAS_URLLIB = True
except ImportError:
    HAS_URLLIB = False

# Model path
MODEL_PATH = os.path.join(os.path.dirname(__file__), "models", "N-ATLaS.Q2_K.gguf")

# ============================
# API KEYS - ADD YOURS HERE LOCALLY (DO NOT COMMIT)
# Get free NewsAPI key at: https://newsapi.org/register
# Get Google Maps key at: https://console.cloud.google.com/google/maps-apis
# ============================
NEWS_API_KEY = "YOUR_NEWSAPI_KEY_HERE"  # Replace with your NewsAPI.org key
GOOGLE_MAPS_API_KEY = "YOUR_GOOGLE_MAPS_API_KEY_HERE"  # Replace with your Google Maps key
# ============================

# Global model instance
llm = None


def load_model():
    """Load the N-ATLaS model"""
    global llm
    try:
        from llama_cpp import Llama
        print(f"Loading model from: {MODEL_PATH}")
        llm = Llama(
            model_path=MODEL_PATH,
            n_ctx=2048,
            n_threads=4,
            verbose=False
        )
        print("Model loaded successfully!")
        return True
    except Exception as e:
        print(f"Error loading model: {e}")
        return False


# ==========================================
# METHOD 1: NewsAPI.org (Most Reliable)
# ==========================================
def search_newsapi(query, location="Nigeria"):
    """Search using NewsAPI.org - reliable, full articles"""
    if NEWS_API_KEY == "YOUR_API_KEY_HERE":
        print("⚠️ NewsAPI key not configured, skipping...")
        return None
    
    try:
        search_q = quote_plus(f"{query} {location} crime OR accident OR security OR kidnapping")
        url = f"https://newsapi.org/v2/everything?q={search_q}&language=en&sortBy=publishedAt&pageSize=5&apiKey={NEWS_API_KEY}"
        
        req = urllib.request.Request(url, headers={"User-Agent": "RouteGuardian/1.0"})
        
        with urllib.request.urlopen(req, timeout=5) as response:
            data = json.loads(response.read().decode("utf-8"))
            
        if data.get("status") == "ok" and data.get("articles"):
            articles = data["articles"]
            print(f"✅ NewsAPI: Found {len(articles)} articles for '{query}'")
            
            return [{
                "title": a.get("title", ""),
                "description": a.get("description", ""),
                "source": a.get("source", {}).get("name", "Unknown"),
                "date": a.get("publishedAt", datetime.now().isoformat()),
                "url": a.get("url", ""),
                "location": location
            } for a in articles if a.get("title")]
            
    except Exception as e:
        print(f"⚠️ NewsAPI failed: {e}")
    
    return None


# ==========================================
# METHOD 2: Google News Scraping (Free)
# ==========================================
def scrape_google_news(query, location="Nigeria"):
    """Scrape Google News - free but may be blocked"""
    try:
        search_query = quote_plus(f"{query} {location} crime OR accident OR robbery")
        url = f"https://news.google.com/search?q={search_query}&hl=en-NG&gl=NG&ceid=NG:en"
        
        headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
        req = urllib.request.Request(url, headers=headers)
        
        with urllib.request.urlopen(req, timeout=5) as response:
            html = response.read().decode("utf-8", errors="ignore")
        
        # Extract headlines
        titles = re.findall(r'<a[^>]*class="[^"]*JtKRv[^"]*"[^>]*>([^<]+)</a>', html)
        if not titles:
            titles = re.findall(r'>([A-Z][^<]{30,150})</a>', html)
        
        if titles:
            print(f"📰 Scraped {len(titles[:5])} headlines for '{query}'")
            return [{
                "title": t.strip(),
                "description": "",
                "source": "Google News",
                "date": datetime.now().isoformat(),
                "location": location
            } for t in titles[:5] if len(t.strip()) > 20]
            
    except Exception as e:
        print(f"⚠️ Scraping failed: {e}")
    
    return None


# ==========================================
# METHOD 3: Demo Fallback (Always Works)
# ==========================================
def get_demo_news(query, location="Nigeria"):
    """Demo fallback data - always works, even offline"""
    demo_data = {
        "kaduna": [
            {"title": "Security patrol increased on Kaduna-Zaria highway", "severity": 15, "type": "security"},
            {"title": "Travelers advised to use daytime travel on Kaduna roads", "severity": 10, "type": "advisory"},
        ],
        "zamfara": [
            {"title": "Travel advisory issued for Zamfara state", "severity": 25, "type": "kidnapping"},
        ],
        "lagos": [
            {"title": "Heavy traffic expected on Lagos-Ibadan expressway", "severity": 5, "type": "traffic"},
        ],
        "ibadan": [
            {"title": "Road construction causing delays near Ibadan", "severity": 8, "type": "road"},
        ],
        "jos": [
            {"title": "Security situation stable in Jos - Police", "severity": 5, "type": "security"},
        ],
        "bauchi": [
            {"title": "Bauchi-Kano route remains safe for travel", "severity": -5, "type": "positive"},
        ],
        "kano": [
            {"title": "Normal traffic flow on Kano highways", "severity": 0, "type": "positive"},
        ],
        "abuja": [
            {"title": "Security checkpoints active on Abuja-Kaduna road", "severity": 8, "type": "security"},
        ],
    }
    
    lower_query = query.lower()
    for key, news in demo_data.items():
        if key in lower_query or lower_query in key:
            print(f"📋 Using demo data for '{query}'")
            return [{
                "title": n["title"],
                "description": f"Demo data for {location}",
                "source": "Demo Database",
                "date": datetime.now().isoformat(),
                "location": location,
                "severity_hint": n["severity"],
                "type_hint": n["type"]
            } for n in news]
    
    return []


# ==========================================
# UNIFIED SEARCH (Triple Fallback)
# ==========================================
def search_news_triple_fallback(query, location="Nigeria"):
    """
    Triple fallback news search:
    1. Try NewsAPI.org (best quality)
    2. Try Google scraping (free)
    3. Use demo data (always works)
    """
    # Method 1: NewsAPI
    result = search_newsapi(query, location)
    if result:
        return result, "newsapi"
    
    # Method 2: Google Scraping
    result = scrape_google_news(query, location)
    if result:
        return result, "scraping"
    
    # Method 3: Demo Fallback
    result = get_demo_news(query, location)
    return result, "demo"


def analyze_news_with_ai(news_items, location, source_type):
    """Use N-ATLaS to analyze news for safety"""
    global llm
    
    if not news_items:
        return {"location": location, "has_danger": False, "severity": 0}
    
    # Check for severity hints from demo data
    total_severity = 0
    for item in news_items:
        if "severity_hint" in item:
            total_severity += item["severity_hint"]
    
    if total_severity != 0:
        # Use demo severity hints
        severity = max(0, min(100, 30 + total_severity))
        return {
            "location": location,
            "news_count": len(news_items),
            "has_danger": severity > 30,
            "danger_type": news_items[0].get("type_hint", "security") if news_items else "none",
            "severity": severity,
            "source": source_type,
            "headlines": [n["title"] for n in news_items[:3]]
        }
    
    # AI analysis for real news
    all_text = " ".join([f"{n['title']} {n.get('description', '')}" for n in news_items]).lower()
    
    severity = 0
    danger_type = "none"
    
    if any(word in all_text for word in ["kidnap", "abduct", "hostage", "ransom"]):
        severity = 80
        danger_type = "kidnapping"
    elif any(word in all_text for word in ["kill", "murder", "shoot", "bandit", "terrorist"]):
        severity = 70
        danger_type = "crime"
    elif any(word in all_text for word in ["robbery", "attack", "armed", "gunmen"]):
        severity = 60
        danger_type = "crime"
    elif any(word in all_text for word in ["security", "military", "patrol", "troops"]):
        severity = 25
        danger_type = "security"
    elif any(word in all_text for word in ["accident", "crash", "collision"]):
        severity = 45
        danger_type = "accident"
    elif any(word in all_text for word in ["flood", "road", "blocked", "construction"]):
        severity = 35
        danger_type = "road"
    elif any(word in all_text for word in ["traffic", "congestion", "delay"]):
        severity = 15
        danger_type = "traffic"
    
    # If we have the AI model, use it for better analysis
    if llm is not None and severity > 20:
        try:
            headlines = "\n".join([n["title"] for n in news_items[:3]])
            prompt = f"""Rate travel safety for {location} based on this news (0=dangerous, 100=safe):

{headlines}

Safety rating (0-100):"""
            
            response = llm(prompt, max_tokens=20, temperature=0.3)
            result = response["choices"][0]["text"].strip()
            numbers = re.findall(r'\d+', result)
            if numbers:
                ai_safety = int(numbers[0])
                severity = 100 - ai_safety  # Convert safety to severity
        except:
            pass
    
    return {
        "location": location,
        "news_count": len(news_items),
        "has_danger": severity > 25,
        "danger_type": danger_type,
        "severity": severity,
        "source": source_type,
        "headlines": [n["title"] for n in news_items[:3]]
    }


def search_route_news(locations):
    """Search news for multiple locations with triple fallback"""
    results = []
    total_severity = 0
    sources_used = set()
    
    for location in locations:
        news_items, source = search_news_triple_fallback(location)
        sources_used.add(source)
        
        analysis = analyze_news_with_ai(news_items, location, source)
        results.append(analysis)
        total_severity += analysis.get("severity", 0)
    
    avg_severity = total_severity / len(locations) if locations else 0
    safety_score = max(10, 95 - int(avg_severity * 0.7))
    
    return {
        "locations_analyzed": locations,
        "safety_score": safety_score,
        "location_reports": results,
        "sources_used": list(sources_used),
        "timestamp": datetime.now().isoformat()
    }


# ... (keep existing analyze_text and assess_severity functions)

def analyze_text(text):
    """Analyze text for safety incidents"""
    global llm
    
    if llm is None:
        return {"error": "Model not loaded"}
    
    prompt = f"""Analyze the following text for safety-related incidents. 
    
Text: "{text}"

Respond in JSON format with:
- has_incident: true/false
- type: incident type (robbery, accident, harassment, etc.)
- severity: 0.0 to 1.0
- confidence: 0.0 to 1.0  
- summary: brief description

JSON Response:"""

    try:
        response = llm(prompt, max_tokens=256, temperature=0.7, stop=["```", "\n\n"])
        result_text = response["choices"][0]["text"].strip()
        
        try:
            if "{" in result_text:
                json_str = result_text[result_text.index("{"):result_text.rindex("}")+1]
                return json.loads(json_str)
        except:
            pass
        
        return {
            "has_incident": "incident" in text.lower() or "crime" in text.lower(),
            "type": "Unknown",
            "severity": 0.5,
            "confidence": 0.6,
            "summary": result_text[:200] if result_text else "Analysis complete"
        }
        
    except Exception as e:
        return {"error": str(e)}


def assess_severity(description, incident_type):
    """Assess incident severity"""
    global llm
    
    severity_map = {"robbery": 80, "harassment": 60, "accident": 70, "vandalism": 40, "suspicious": 50}
    
    if llm is None:
        for key, value in severity_map.items():
            if key in incident_type.lower():
                return {"severity": value, "reasoning": "Rule-based"}
        return {"severity": 50, "reasoning": "Default"}
    
    prompt = f"Rate severity 0-100: {incident_type} - {description}\nSeverity:"
    
    try:
        response = llm(prompt, max_tokens=20, temperature=0.3)
        numbers = re.findall(r'\d+', response["choices"][0]["text"])
        if numbers:
            return {"severity": min(100, max(0, int(numbers[0]))), "reasoning": "AI"}
    except:
        pass
    
    return {"severity": 50, "reasoning": "Default"}


class RequestHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
    
    def do_GET(self):
        parsed = urlparse(self.path)
        
        if parsed.path == "/status":
            self.send_json({
                "status": "ok",
                "model_loaded": llm is not None,
                "newsapi_configured": NEWS_API_KEY != "YOUR_API_KEY_HERE"
            })
        elif parsed.path == "/health":
            self.send_json({"healthy": True})
        else:
            self.send_error(404)
    
    def do_POST(self):
        content_length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(content_length).decode('utf-8')
        data = json.loads(body) if body else {}
        
        parsed = urlparse(self.path)
        
        if parsed.path == "/analyze":
            result = analyze_text(data.get("text", ""))
            self.send_json(result)
            
        elif parsed.path == "/severity":
            result = assess_severity(data.get("description", ""), data.get("type", ""))
            self.send_json(result)
        
        elif parsed.path == "/search_news":
            locations = data.get("locations", [data.get("location", "Nigeria")])
            print(f"\n🔍 N-ATLaS searching news for: {locations}")
            result = search_route_news(locations)
            print(f"✅ Safety Score: {result['safety_score']} (Sources: {result['sources_used']})")
            self.send_json(result)
        
        elif parsed.path == "/directions":
            # Proxy for Google Directions API to bypass CORS
            origin = data.get("origin", "")
            destination = data.get("destination", "")
            print(f"\n🗺️ Directions: {origin} → {destination}")
            result = self.proxy_directions(origin, destination)
            self.send_json(result)
            
        else:
            self.send_error(404)
    
    def send_json(self, data):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())
    
    def proxy_directions(self, origin, destination):
        """Proxy Google Directions API requests to bypass CORS"""
        try:
            encoded_origin = quote_plus(origin)
            encoded_dest = quote_plus(destination)
            url = f"https://maps.googleapis.com/maps/api/directions/json?origin={encoded_origin}&destination={encoded_dest}&alternatives=true&key={GOOGLE_MAPS_API_KEY}"
            
            req = urllib.request.Request(url, headers={"User-Agent": "RouteGuardian/1.0"})
            with urllib.request.urlopen(req, timeout=10) as response:
                data = json.loads(response.read().decode("utf-8"))
                
            if data.get("status") == "OK":
                print(f"✅ Found {len(data.get('routes', []))} routes")
            else:
                print(f"⚠️ Directions API status: {data.get('status')}")
            
            return data
            
        except Exception as e:
            print(f"❌ Directions proxy error: {e}")
            return {"status": "ERROR", "error_message": str(e)}
    
    def log_message(self, format, *args):
        pass


def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 8765
    
    print("=" * 50)
    print("N-ATLaS Inference Server - Triple Fallback")
    print("=" * 50)
    
    if not load_model():
        print("WARNING: Running without AI model")
    
    if NEWS_API_KEY == "YOUR_API_KEY_HERE":
        print("⚠️  NewsAPI key not set - will use scraping/demo")
        print("   Get free key at: https://newsapi.org/register")
    else:
        print("✅ NewsAPI key configured")
    
    server = HTTPServer(("0.0.0.0", port), RequestHandler)
    print(f"\nServer: http://0.0.0.0:{port} (accessible on network)")
    print(f"Local:  http://localhost:{port}")
    print(f"Network: http://10.227.22.32:{port}")  # Your laptop's IP
    print("\nNews Search Fallback Order:")
    print("  1. NewsAPI.org (if key configured)")
    print("  2. Google News scraping")
    print("  3. Demo database")
    print("-" * 50)
    
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.shutdown()


if __name__ == "__main__":
    main()
