# AstroGuide Task List

## Phase 1: Foundation

- [ ] Task 1: Prepare the Flutter and Android toolchain, initialize Git without disturbing existing workspace files, and create a minimal Flutter app and backend workspace.
- [ ] Task 2: Configure AGPL project and dependency notices, safe environment handling, and reproducible development commands.

## Checkpoint: Foundation

- [ ] Starter test and Android debug build pass.
- [ ] Backend contract tests pass.
- [ ] No secrets or generated build artifacts are tracked.

## Phase 2: Local astrology and numerology

- [ ] Task 3: Add failing-first tests and Pythagorean name-number calculations.
- [ ] Task 4: Add failing-first tests and Swiss Ephemeris sidereal charts for Lahiri, Raman, and KP.
- [ ] Task 5: Persist and edit the profile locally with a clear deletion path.

## Checkpoint: Calculation

- [ ] Calculation fixtures and edge cases pass.
- [ ] The chart never fabricates Rising or houses when time/location is unknown.

## Phase 3: AI coach

- [ ] Task 6: Add failing-first backend tests for input validation, privacy, fixed output shape, rate limiting, and missing credentials.
- [ ] Task 7: Implement the secured Gemini API integration and Indonesian coaching response.
- [ ] Task 8: Implement the mobile API boundary and visible error/timeout states.

## Checkpoint: AI

- [ ] Test evidence proves raw profile data is not sent to Gemini.
- [ ] A live Gemini response is tested only after a valid API key is provided.

## Phase 4: Android experience and delivery

- [ ] Task 9: Build the onboarding, profile, chart, and reading screens.
- [ ] Task 10: Run tests, Android build, accessibility/responsive checks, and emulator walkthrough.
- [ ] Task 11: Document setup, privacy, licenses, API configuration, and build steps.

## Checkpoint: Complete

- [ ] Android debug build generated and verified.
- [ ] No secrets ship in the APK.
- [ ] Beta distribution and signing decisions are explicit.
