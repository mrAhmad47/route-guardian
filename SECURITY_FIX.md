# 🔐 API Keys Security Setup

## ⚠️ IMPORTANT: API Keys Were Exposed on GitHub

Your API keys were committed to GitHub and need to be regenerated for security.

## ✅ What I Did

1. **Removed API keys from code**
   - `natlas_server.py` - Now uses placeholders
   - `lib/config/api_config.dart` - Now uses environment variables
   - `web/index.html` - Now uses placeholder

2. **Created `.env.example`** - Template for API keys

3. **Updated `.gitignore`** - Already protects `.env` files

## 🚨 CRITICAL: You MUST Do This

### 1. Regenerate Your API Keys (ASAP!)

**Google Maps API:**
1. Go to: https://console.cloud.google.com/google/maps-apis
2. Select your project
3. Credentials → Find your old key
4. **DELETE the exposed key**: `AIzaSyDLgxgrNJq-4xjRi_cc9RPvX-kKC06VwyQ`
5. Create a new key
6. Add restrictions (HTTP referrers, Android apps, etc.)

**NewsAPI:**
1. Go to: https://newsapi.org/account
2. **Regenerate key** (delete old one: `9903f645f23748949387d1e34811bfd8`)
3. Get new key

### 2. Add Keys Locally (NOT on GitHub)

**File:** `natlas_server.py` (lines 32-33)
```python
NEWS_API_KEY = "your_new_newsapi_key_here"
GOOGLE_MAPS_API_KEY = "your_new_google_maps_key_here"
```

**File:** `web/index.html` (line 18)
```html
<script src="https://maps.googleapis.com/maps/api/js?key=your_new_google_maps_key_here"></script>
```

## ⚡ Quick Fix for Now (To Keep Working)

Since you need to test/demo:

1. **Locally edit these files** with your current keys
2. **DO NOT commit them** (Git will ignore if you don't `git add` them)
3. **After regenerating**, use new keys everywhere

## 🔒 Future: Use Environment Variables

Create `.env` file (already in `.gitignore`):
```
NEWS_API_KEY=your_key_here
GOOGLE_MAPS_API_KEY=your_key_here
```

## 📝 Note

The old keys are still in Git history. To completely remove them, you'd need to:
```bash
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch natlas_server.py lib/config/api_config.dart web/index.html" \
  --prune-empty --tag-name-filter cat -- --all
```

**But easier:** Just regenerate the keys (they're invalid when deleted anyway).

## ✅ Verification

After regenerating and adding new keys:
1. Test web app: `flutter run -d chrome`
2. Routes should work
3. News discovery should work
4. No keys visible on GitHub!
