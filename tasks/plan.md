# AstroGuide Implementation Plan

## Overview

Build an installable Android astrology and numerology companion for Indonesian users. Birth details and the full name stay on the device. The device computes a Vedic sidereal chart using a selectable Lahiri, Raman, or KP ayanamsha and Pythagorean name numbers. An optional backend sends only the derived chart and number summary to Gemini and returns warm, non-fatalistic Indonesian guidance.

## Confirmed Product Decisions

- Flutter Android app and a small Gemini API backend.
- No account in the first release; save the profile on the device.
- Keep full name, date, time, city, latitude, and longitude out of AI requests.
- Support Indonesian birth locations first. A missing birth time must never be presented as a verified Ascendant or house chart.
- Default sidereal method: Lahiri. Allow the user to select Lahiri, Raman, or KP.
- Use Pythagorean name numerology.
- Dark, dramatic, premium, gold-accented visual direction, supplied by the product owner. Use a text wordmark rather than inventing a logo.
- No-cost beta target: fewer than 100 users. Gemini credentials and a deployment host are not available yet.
- Swiss Ephemeris is licensed under AGPL-3.0; the owner approved releasing this app's source under AGPL.

## Design Read

Reading this as: a personal astrology and numerology coach for Indonesian Android users, in a dark, dramatic, gold-accented night-sky language, dial ENERGY 2 / RHYTHM 2 / MOTION 1.

### Compact design tokens

- **Color:** ink navy `#0B1020`, deep plum `#171326`, parchment `#F3EAD8`, antique gold `#D8B56D`, and sea glass `#8CB9B2`.
- **Type:** Android's system serif for chart titles and reflection; system sans-serif for forms and reading text.
- **Layout:** left-aligned, scrollable onboarding form; a chart-summary screen where a clearly labeled chart wheel is the focal point; stacked, editorial reading sections rather than repetitive cards.
- **Principles:** use gold to indicate selected method and important chart relationships, not as decoration everywhere. Keep motion to responsive state changes and respect reduced motion. Avoid invented planet positions, predictions, statistics, customer quotes, and a logo.

### Uniqueness check

The identity comes from the user's specific request for dramatic gold Vedic astrology and a friendly Indonesian coach, not the common cream-and-terracotta or blue-purple application defaults. The chart wheel is used because it helps read actual chart placements. There will be no decorative horoscope imagery that could be mistaken for a computed result.

See `DESIGN.md` for the onboarding wireframe and visual critique.

## Architecture Decisions

- Flutter client handles form validation, Pythagorean calculations, chart calculations, local profile storage, and presentation.
- Swiss Ephemeris handles sidereal positions and house calculations, subject to preserving its AGPL and third-party license notices. Configure Lahiri, Raman, and KP from Swiss Ephemeris's built-in sidereal modes; never approximate an ayanamsha or planet position.
- A Node.js API proxy owns the Gemini API key. The mobile binary never contains the provider key. Validate and bound every request/response, avoid logging request contents, and fail clearly when the key is absent.
- Gemini receives a minimized summary: computed chart signs and relevant positions, numeric name readings, the selected ayanamsha label, and uncertainty flags. It must not receive the user's name or raw birth location/time/date.
- Separate calculation, storage, provider integration, and UI code so each can be verified without live credentials.
- Encrypt saved birth-profile fields with Android secure storage. Bundle a filtered GeoNames Indonesia city catalog so city and time-zone lookup works offline.
- Use a standard Flutter Android build and local emulator check. Record missing external credentials or deployment access rather than claiming an unperformed live integration.

## Task List

### Phase 1: Foundation

- [x] Task 1: Prepare the Flutter and Android toolchain, initialize Git without disturbing the existing `.agents`, `.idea`, or `skills-lock.json`, and create the Flutter app and backend workspace in separate directories.
- [x] Task 2: Configure the AGPL license and dependency notices, safe environment handling, and reproducible development commands.

### Checkpoint: Foundation

- [x] Flutter app/widget tests and backend contract tests pass.
- [ ] Android debug APK builds and is verified.
- [ ] No real credentials or generated build artifacts are tracked.

### Phase 2: Local astrology and numerology

- [x] Task 3: Add failing-first tests and Pythagorean name-number calculations, including input normalization and master-number handling.
- [ ] Task 4: Add failing-first tests and verify Swiss Ephemeris sidereal charts for Lahiri, Raman, and KP on Android. Keep Ascendant unavailable without a known birth time.
- [x] Task 5: Persist and edit the profile in encrypted local storage; add a user-controlled deletion path and keep sensitive values out of AI requests.

### Checkpoint: Calculation

- [x] Numerology, offline city search, and historical time-zone edge-case tests pass.
- [ ] Swiss Ephemeris chart fixtures pass on Android for each selectable method.
- [ ] Unknown birth time/location never produces a fabricated Rising sign or house placement.

### Phase 3: AI coach

- [x] Task 6: Write failing-first tests for request validation, minimized-input privacy, fixed response shape, rate limits, generic errors, and absent-key behavior.
- [x] Task 7: Implement the Gemini server integration and Indonesian coach prompt; live provider behavior is not yet verified.
- [x] Task 8: Add the mobile API boundary and visible configuration, timeout, and service error states.

### Checkpoint: AI

- [ ] Automated tests prove that names and raw birth data cannot enter provider requests.
- [ ] Backend reports missing credentials clearly and does not produce success-shaped fallback readings.
- [ ] With a user-provided Gemini API key, verify an actual request and response before deployment.

### Phase 4: Android experience and delivery

- [x] Task 9: Build onboarding, profile editing, method selection, chart overview, and the requested AstroGuide reading layout using the approved design direction.
- [ ] Task 10: Verify Flutter tests, backend tests, Android debug build, keyboard/accessibility behavior, screen-size layouts, empty/loading/error states, and a local emulator walkthrough.
- [x] Task 11: Document setup, privacy boundaries, license obligations, API configuration, and build steps.

### Checkpoint: Complete

- [ ] Acceptance criteria met and Android debug build generated.
- [ ] No functional API key or other secret shipped in the APK.
- [ ] No live Gemini behavior is claimed until verified with credentials.
- [ ] Owner reviews the tested beta and makes the distribution decision.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Flutter SDK download is large and slow | Android build cannot start | Verify the official archive SHA-256 and do not use unverified binaries |
| Swiss Ephemeris uses AGPL-3.0 by default | Source-distribution obligations | Owner approved open source; include license and preserve upstream notices |
| Swiss Ephemeris's Flutter FFI integration may need native setup | Android install/build or calculations fail | Confirm Android FFI and sidereal behavior with tests before building dependent UI |
| Birthplace geocoding/time-zone data needs coverage and ongoing updates | Incorrect Ascendant or houses | Limit initial supported locations and identify data source, precision, and time-zone uncertainty; never silently guess |
| Gemini requires a provider credential and internet access | Cloud reading unavailable in beta until configured | Provide an explicit, tested unavailable/error state; never ship the key in the mobile client |
| Birth data and names are sensitive personal data | Privacy and trust harm | Keep profile on-device; send only derived, de-identified insights; offer local deletion |

## Open Questions

- The Gemini API key and hosting provider remain to be supplied. Until then, test the backend using deterministic provider fixtures, not a fake production reading.
- The GeoNames-derived Indonesia city list is bundled under CC BY 4.0; confirm its precision and coverage during the Android chart walkthrough.
- Confirm the distribution channel and signing owner before producing a release build. A debug APK is only a development artifact.
