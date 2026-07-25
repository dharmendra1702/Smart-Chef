# Smart-Chef — Complete Original (from Smart-Chef-main.zip)

This is your **real, complete original project** — the full GitHub repo, with every
feature intact: the "Welcome to Smart Chef" split-screen home page, Chef Buddy chat,
Ingredients-to-Recipe, Food-image-to-Recipe, and the Info screen. It uses the proper
`flutter_gemini` package rather than raw HTTP calls, so it's more robust than the
partial zip we were patching before.

## ⚠️ Before you run it

1. **Rotate your Gemini API key.** It was hardcoded in `lib/constants/constants.dart`
   and is now exposed. Get a fresh one at https://aistudio.google.com/ and generate a
   new key, then revoke the old one.

2. This zip previously contained a full Chrome browser profile at
   `.dart_tool/chrome-device/` (history, saved logins, cookies, etc. from your dev
   machine) — that folder has been **removed** from this cleaned copy. Worth knowing
   in case you share the original `Smart-Chef-main.zip` with anyone else.

## Run it

```bash
flutter pub get
flutter run -d chrome --dart-define=GEMINI_API_KEY=your_new_key_here
```

## Build for deployment

```bash
flutter build web --dart-define=GEMINI_API_KEY=your_new_key_here
```
Deploy the `build/web` folder (e.g. to Vercel).

## What's inside
- `lib/views/home/web_view.dart` — the real split-screen "Welcome to Smart Chef" desktop layout
- `lib/views/home/mobile_view.dart` — the mobile/narrow layout with the tool cards
- `lib/views/chat/chat_view.dart` — Chef Buddy chatbot (ChatScreen)
- `lib/views/recipe_generate/recipe_generate_view.dart` — ingredients/food image → recipe
- `lib/views/info/info_screen.dart` — the info/about screen
- `lib/services/gemini_services.dart` — all Gemini AI calls, using the `flutter_gemini` package
