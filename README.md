# AstroGuide

AstroGuide is a friendly Indonesian astrology and numerology coach for
Android. The app calculates the birth chart and Pythagorean name numbers on
the device. Its optional Gemini API receives only the calculated chart,
numerology values, and the user's question, never the saved name or raw birth
details.

## Project layout

- `apps/astroguide/` - Android app built with Flutter.
- `backend/` - Node.js API proxy for the Gemini reading.
- `tasks/plan.md` - approved product decisions, design direction, and milestones.
- `tasks/todo.md` - implementation checklist.

## Requirements

- Flutter stable and Dart as pinned by `apps/astroguide/pubspec.yaml`.
- Android Studio, Android SDK, and Java 17 or later.
- Node.js 22 or later for the API.
- A Gemini Developer API key and HTTPS backend host to enable live AI readings.

## Local development

Run the API:

```powershell
cd backend
Copy-Item .env.example .env
# Add your own GEMINI_API_KEY to .env before requesting an AI reading.
npm start
```

Run backend tests:

```powershell
cd backend
npm test
```

Run the Flutter app from PowerShell:

```powershell
Push-Location apps\astroguide
flutter pub get
flutter run --dart-define=ASTROGUIDE_API_BASE_URL=http://10.0.2.2:3000
Pop-Location
```

`10.0.2.2` is the Android emulator's host-machine address. For a physical
device, use the host's reachable HTTPS development URL instead. Never put a
Gemini API key in `--dart-define` or in the Android app.

## Privacy and astrology

Profiles are stored locally on the device. Selecting a city and birth time is
necessary to calculate an Ascendant and houses. When the time is unknown,
AstroGuide must not guess them; it reports only chart placements that remain
certain across the birth date. Sending an insight request transmits computed
chart signs, name-number results, and (for follow-ups) the text the user
chooses to send to the Gemini API. The server does not intentionally persist
request or response content.

Astrology and numerology content is for personal reflection and entertainment,
not medical, legal, financial, or other professional advice.

## Licensing

AstroGuide is distributed under the GNU Affero General Public License v3.0.
Swiss Ephemeris and its bundled data carry additional license and notice
requirements. See `LICENSE` and `THIRD_PARTY_NOTICES.md` before distributing a
build or operating the API for other users.
