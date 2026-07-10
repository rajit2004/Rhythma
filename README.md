[![Rhythma logo](https://github.com/ishita2740/Rhythma/raw/main/landing-page/public/logo1.png)](/ishita2740/Rhythma/blob/main/landing-page/public/logo1.png)

# Rhythma 🌸

*Her Rhythm. Her Health. Her Power.*

A multilingual, offline-capable AI-powered women's health companion built for women in India.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev) [![FastAPI](https://img.shields.io/badge/FastAPI-0.111-green?logo=fastapi)](https://fastapi.tiangolo.com) [![Gemini API](https://img.shields.io/badge/Gemini-API-orange?logo=google)](https://ai.google.dev) [![License: MIT](https://img.shields.io/badge/License-MIT-purple.svg)](https://github.com/ishita2740/Rhythma/blob/main/LICENSE) [![Status](https://img.shields.io/badge/Status-Active%20Development-yellow)](#project-status)

---

> **A note on this README:** This document is kept in sync with the actual code in this repository, not with the long-term vision for the product. If a feature isn't in the code yet, it's listed under **Future Features**, not under **Implemented**. See [Project Status](#project-status) for the full breakdown.

---

## 🎯 The Problem

1 in 5 Indian women have PCOD — yet **70% of cases go undetected for years**. Women in tier-2 and tier-3 cities face a uniquely difficult combination of challenges:

- Popular apps (Flo, Clue) assume 28-day cycles, English fluency, and stable internet
- Limited access to gynecologists in smaller cities
- Deep social stigma that prevents open conversations about menstrual health
- No dedicated, age-appropriate guidance for girls experiencing their first period
- No AI-powered early detection tool built specifically for Indian languages and contexts

**Rhythma was built from the ground up for Indian women — not adapted from a solution built for another market.**

---

## Solution

Rhythma aims to be an offline-first, multilingual women's health companion for tier-2 and tier-3 Indian cities — supporting cycle tracking, an AI health assistant, and personalized wellness scoring in regional languages.

Today, the repository contains:

- A **polished Flutter UI** for five core screens (Home, Cycle, AI Assistant, Insights, Profile) plus Settings, in 5 languages, with light/dark theming — now gated behind real **login/registration**.
- A **working FastAPI backend** with real authentication (JWT + bcrypt), Firestore-backed users, and Firestore-backed **cycle log persistence**.
- A real **`/dashboard` endpoint** that reads a user's persisted cycle logs and computes live CVI/MHS scores from them (heuristic model, not yet a trained one).
- The Flutter **Home screen calls that real `/dashboard` endpoint** — the first place in the app where backend and client are actually connected end-to-end.
- A **directly-integrated Gemini AI assistant** in the Flutter app (calls Google's API straight from the client) — separate from the backend's own `/assistant` endpoint, which still isn't called by either front end.
- Local **Hive** storage for profile, settings, and emergency contacts.
- An early **React + Vite web app** (`web/`) with real login/registration against the same backend, protected routing, and i18n — no cycle tracking, insights, or assistant pages yet.
- **GitHub Actions CI** running Flutter analyze/format/test and backend pytest on every PR.
- A separate **Next.js marketing landing page**, unrelated to the app's functionality.

Several pieces (the Cycle screen actually saving what a user logs, cloud sync, on-device encryption, SMS delivery from the app, WhatsApp access, first-period onboarding, Ayurvedic content) are **not yet functional** — see [Implemented Features](#implemented-features) vs. [Features In Progress](#features-in-progress) vs. [Future Features](#future-features) below for the exact line.

---

## Platforms

Rhythma consists of **two front ends sharing one backend**, not two separate products:

1. **Flutter mobile app** (`rhythma_flutter/`) — the primary experience today. Most of the UI described in this README lives here.
2. **Website** (`web/`) — a browser-based client aiming for **the same features as the app** (cycle tracking, AI Assistant, Insights, Profile), talking to the same FastAPI backend, for women who don't have or don't want to install a mobile app. **Scaffolding has started**: a React + Vite + TypeScript app with working registration, login, protected routing, and i18n (same 5 locales as Flutter) against the real backend `/auth` endpoints — but it only has a placeholder home page so far. Cycle tracking, AI Assistant, and Insights pages don't exist on the web yet.

This is separate from `landing-page/`, a Next.js **marketing** site that explains the product but runs none of its functionality. Don't confuse the two when navigating the codebase. Bringing the website to feature parity is tracked under [Roadmap Phase 6](#phase-6--platform-expansion).

---

## Who Rhythma Is For

Rhythma is designed to grow into support for multiple groups of Indian women, each with different needs. Not all of these are served by the app yet — this is the target scope, not a claim about current functionality.

| Group | Age / context | What they need |
| --- | --- | --- |
| **Teen girls (first period journey)** | 12–17 | Simple, non-clinical first-period guidance and menstrual education — **planned, not yet built** (see [First Period Guidance](#future-features)) |
| **College students & working women** | 18–35 | Irregular-cycle tracking, PCOD/PCOS awareness, hormonal health support — **primary users of the current app** |
| **Women with irregular cycles** | 18–35+ | Long-term pattern detection (CVI), not single-cycle guesswork | 
| **Community / self-help groups** | Extended ecosystem (NGOs, rural users, shared devices) | Offline access, SMS support, and eventually WhatsApp-based access without needing to install an app — **partially planned** |

Contributors working on onboarding flows, content, or accessibility should keep these different personas in mind, especially the gap between the current adult-focused experience and the still-unbuilt teen-focused one.

---

## Screenshots

*(Screenshots below reflect UI mockups for screens that are visually complete but, in some cases, not yet wired to real data — see [Project Status](#project-status).)*

| Dashboard | Cycle Calendar | AI Assistant |
| --- | --- | --- |
| [![Dashboard](https://github.com/ishita2740/Rhythma/raw/main/screenshots/dashboard.png)](/ishita2740/Rhythma/blob/main/screenshots/dashboard.png) | [![Calendar](https://github.com/ishita2740/Rhythma/raw/main/screenshots/calender.png)](/ishita2740/Rhythma/blob/main/screenshots/calender.png) | [![AI Assistant](https://github.com/ishita2740/Rhythma/raw/main/screenshots/AI_assistant.png)](/ishita2740/Rhythma/blob/main/screenshots/AI_assistant.png) |

| Health Insights | CVI Score | MHS Score | SMS Summary |
| --- | --- | --- | --- |
| [![Health Insights](https://github.com/ishita2740/Rhythma/raw/main/screenshots/Health_Insights.png)](/ishita2740/Rhythma/blob/main/screenshots/Health_Insights.png) | [![CVI](https://github.com/ishita2740/Rhythma/raw/main/screenshots/CVI.png)](/ishita2740/Rhythma/blob/main/screenshots/CVI.png) | [![MHS](https://github.com/ishita2740/Rhythma/raw/main/screenshots/MHS.png)](/ishita2740/Rhythma/blob/main/screenshots/MHS.png) | [![SMS](https://github.com/ishita2740/Rhythma/raw/main/screenshots/SMS.png)](/ishita2740/Rhythma/blob/main/screenshots/SMS.png) |

---

## 🚀 Key Features

| Feature | Description | Status |
| --- | --- | --- |
| 🔐 **Account Login / Registration** | JWT-based sign up and sign in, gating access to the app. | ✅ Implemented (backend + Flutter + web) |
| 🌸 **Smart Cycle Tracking** | Handles irregular cycles. No fixed 28-day assumption. Tracks flow, mood, and daily symptoms. | ⚠️ Logging UI built (calendar + bottom sheet), but entries aren't saved anywhere yet — see [status](#features-in-progress) |
| 🤖 **Gemini-Powered AI Assistant** | Multilingual health education and wellness guidance in Hindi, Marathi, Tamil, English, and more. | ✅ Implemented (client-side) |
| 📊 **Cycle Variability Index™ (CVI)** | Proprietary 0–100 score quantifying hormonal instability over rolling 6–12 months. | ⚠️ Heuristic model computed live by the backend `/dashboard` endpoint from persisted logs; shown on the Flutter Home screen but not yet on the Insights screen, and not yet trained on real data |
| ❤️ **Menstrual Health Score™ (MHS)** | Holistic composite score: CVI + lifestyle + sleep + stress + symptoms. | ⚠️ Same as CVI above — live heuristic via `/dashboard`, surfaced on Home only |
| 🏥 **Hormonal Risk Indicator** | 3-tier alert system (Low / Medium / High) based on cycle gaps and symptom clusters. (Awareness tool, not a diagnosis.) | ⚠️ Risk level computed by `/dashboard`; not yet surfaced with its own UI treatment |
| 📱 **Offline-First Architecture** | Hive local storage → Firestore cloud sync when connectivity is available. | ⚠️ Local storage done; sync stubbed |
| 🔒 **Privacy-First Design** | On-device encryption. No data leaves the phone without explicit user consent. | ❌ Not implemented |
| 🌍 **Indian Regional Languages** | Full UI localization across Indian languages. | ✅ Implemented (English, Hindi, Marathi, Tamil, Telugu) in Flutter and web |
| 📩 **SMS Health Summaries** | Weekly summaries via Twilio SMS for users in low-data areas. | ⚠️ Backend done; not linked in app |
| 🩸 **First Period Guidance** | A dedicated, age-appropriate onboarding and education flow for first-time users (ages 12–17) — separate tone, content, and simplicity level from the adult cycle-tracking experience. | ❌ Not implemented — see [Future Features](#future-features) |
| 🌿 **Ayurvedic Correlation Layer** | Educational wellness insights that connect lifestyle and cycle patterns with traditional Ayurvedic wellness concepts, for cultural relevance (educational only, not medical advice). | ❌ Not implemented — see [Future Features](#future-features) |
| 💬 **WhatsApp Bot Integration** | Gemini-powered WhatsApp assistant (via Twilio/Meta Cloud API) for cycle tracking and health Q&A without requiring an app install — aimed at community/self-help-group users on shared or low-end devices. | ❌ Not implemented — see [Future Features](#future-features) |
| 🌐 **Website (feature parity)** | A browser-based client offering the same cycle tracking, AI Assistant, Insights, and Profile features as the Flutter app, on the same backend. | ⚠️ Scaffolded — login/register/routing/i18n work; no product pages yet, see [Platforms](#platforms) |

---

### Implemented Features

These exist in the code today and function as described:

- **Backend authentication** — registration and login with bcrypt password hashing and JWT issuance (`backend/core/auth.py`, `backend/core/auth_router.py`). Protected routes verify the token via `get_current_user`.
- **In-app authentication (Flutter)** — real login and registration screens (`screens/auth/`) calling the backend, JWT stored via `flutter_secure_storage`, and a session-validation check on app start that routes to `LoginScreen` when there's no valid token. The app no longer opens straight into the main UI.
- **In-app authentication (web)** — the same login/registration flow, reimplemented in React (`web/src/auth/`), with an Axios interceptor that attaches the token and redirects to `/login` on a 401.
- **Cycle log persistence (backend)** — `POST /cycle/log` writes real documents to a Firestore `cycle_logs` collection, and `GET /cycle/{user_id}/history` reads them back (`services/firestore_service.py::CycleService`).
- **Live dashboard scoring (backend)** — `GET /dashboard` pulls a user's persisted cycle logs, derives cycle-length/flow/symptom features, and returns real CVI/MHS/risk-level output plus a `hasEnoughDataForInsights` flag rather than static placeholders (`backend/api/dashboard.py`).
- **Home screen ↔ backend integration (Flutter)** — the Home screen calls `GET /dashboard` on load and renders whatever it gets back (cycle day, next-period estimate, MHS, CVI risk level, average sleep), including a real error state if the call fails.
- **AI Assistant (client-side)** — the Flutter app talks directly to the Gemini API (`gemini_service.dart`) with a system prompt tuned for menstrual health guidance, graceful fallback text when no API key is configured, and multi-turn chat history.
- **Local storage (Hive)** — user profile, app settings, and emergency contacts are saved and loaded from on-device Hive boxes (`local_storage_service.dart`). This data persists across app restarts.
- **Profile management** — full create/edit flow with input validation (name, age, cycle length), backed by Hive.
- **Emergency contacts** — full add/edit/delete flow with phone number validation, backed by Hive.
- **Local notifications** — permission requests, scheduled reminders, and instant test notifications via `flutter_local_notifications` (`notification_service.dart`), wired to toggles in Settings.
- **Theming** — light/dark mode and a selectable accent color, persisted to Hive and applied app-wide via `ThemeProvider`.
- **Localization** — full UI translation into English, Hindi, Marathi, Tamil, and Telugu (~125 keys each) in Flutter, switchable in-app and persisted; the same 5 locales exist in the web app via i18next.
- **Settings screen** — notification toggles, language/theme navigation, permission shortcuts, and a logout confirmation flow.
- **Website scaffold** — a React + Vite + TypeScript app (`web/`) with working registration and login against the real backend, protected routes (`ProtectedRoute.tsx`), and an Axios client that mirrors the Flutter app's token-refresh/401 handling.
- **Backend health/CORS/router scaffolding** — a real FastAPI app with a lifespan hook, CORS middleware, and modular routers.
- **Backend Firestore integration (users and cycle logs)** — real create/read/update operations against Firestore `users` and `cycle_logs` collections.
- **CI/CD** — GitHub Actions workflows (`.github/workflows/flutter.yml`, `backend.yml`) run Flutter analyze/format/test and backend `pytest` on every PR and push to `main`.
- **Backend tests** — 9 passing `pytest` tests covering login success/failure, protected-route rejection, and SMS rate limiting, with Gemini mocked out.
- **Flutter tests** — a widget test suite plus dedicated tests for onboarding (`onboarding_test.dart`) and the cycle calendar grid (`widgets/calendar_grid_test.dart`).

### Features In Progress

These have partial code, UI, or backend logic, but are **not end-to-end functional**:

- **Cycle tracking** — a daily-logging bottom sheet and calendar interactions were built (`cycle_screen.dart`, `cycle_provider.dart`), so the UI now feels interactive. But `CycleProvider` still tracks logged days in an in-memory `Set` seeded with mock entries — nothing the user taps calls Hive **or** the backend's working `POST /cycle/log` endpoint. This is the main gap blocking real end-to-end data: the backend can persist and score logs, and the Home screen can display scores, but nothing currently writes a real log to get scored.
- **Symptoms / mood / sleep / stress logging** — the backend data model (`CycleLog`) supports these fields, and `/dashboard` will use them once logs exist, but no Flutter screen currently collects and submits them.
- **Health Insights (CVI / MHS) screen** — the scoring math is live on the backend and already consumed by the Home screen (see [Implemented Features](#implemented-features)), but the dedicated Insights screen in Flutter still shows static UI and doesn't call `/dashboard` or `/insights/{user_id}/scores` itself.
- **`/insights/{user_id}/scores` endpoint** — still a stub that returns a placeholder message; real scoring now lives in `/dashboard` instead. This older endpoint should probably be removed or redirected once the Insights screen is wired up, rather than maintained in parallel.
- **AI Assistant (backend endpoint)** — a fully built `/assistant/chat` FastAPI endpoint exists (with the same system prompt design), but neither the Flutter app nor the web app calls it yet; Flutter talks to Gemini directly instead. One of these two paths will be deprecated as the architecture consolidates.
- **SMS summaries** — the backend has a real Twilio integration with rate limiting, and Flutter has a complete `SmsScreen` UI, but the screen isn't yet linked into app navigation and doesn't yet call the backend endpoint.
- **Website product pages** — auth works end-to-end on the web app, but there's no cycle tracking, AI Assistant, or Insights page yet — only a placeholder `HomePage.tsx` behind the protected route.
- **Cloud sync (Firestore, client-side)** — `firestore_service.dart` on the Flutter side is currently a stub with the real Firestore calls commented out pending Firebase client setup.
- **Testing (Flutter)** — the suite now covers onboarding and the cycle calendar grid in addition to the original widget test, but hasn't been extended to cover the new auth screens or the daily-logging bottom sheet yet.

### Future Features

These are on the roadmap but have **no implementation yet** — no code, no content, no UI. Contributors interested in any of these should open an issue first (see [CONTRIBUTING.md](./CONTRIBUTING.md#issue-workflow)) to discuss scope before building, since these are also the areas most likely to need product/content decisions, not just code.

- **First Period Guidance** — a separate onboarding path and education content for girls aged 12–17 experiencing their first period. Needs its own tone, simplified UI, and content review (likely with input from a health educator) before implementation. Nothing exists in the codebase yet — no screen, no content, no data model changes.
- **Ayurvedic Correlation Layer** — educational content connecting lifestyle and cycle patterns to traditional Ayurvedic wellness concepts. Requires sourcing and reviewing culturally accurate, non-prescriptive content, plus a lightweight rules layer to surface it contextually. No content or code exists yet.
- **WhatsApp Bot Integration** — a Gemini-powered WhatsApp assistant (via Twilio/Meta Cloud API) offering cycle tracking and health Q&A without an app install, aimed at community/self-help-group users and shared/low-end devices. Depends on the backend `/assistant/chat` endpoint being production-ready first (see [Features In Progress](#features-in-progress)).
- **Website product pages** — cycle tracking, AI Assistant, and Insights pages for the web app (see [Platforms](#platforms)). Auth and routing are already in place; these pages themselves don't exist yet.
- End-to-end offline-first sync with conflict resolution and a visible sync-status indicator
- On-device encryption for locally stored health data
- Connectivity-aware sync (detecting online/offline state)
- Water, weight, and medication tracking
- Data export/import and shareable health reports
- A trained CVI/MHS model (current logic runs on a heuristic, not a trained model)
- Verified healthcare-provider directory / connect feature
- Regional, anonymized health-trend insights
- Automated release process (CI already runs analyze/format/test on every PR — see [Implemented Features](#implemented-features))
- Accessibility support (screen reader labels, semantic markup)

---

## Technology Stack

| Layer | Technology | Status | Why |
| --- | --- | --- | --- |
| Mobile app | **Flutter** | Implemented (UI + auth + partial backend integration) | Single codebase across Android/iOS |
| Website (planned product client) | **React + Vite + TypeScript** | Scaffolded — auth/routing/i18n done, no product pages yet | Consumes the same backend as the Flutter app; not to be confused with the Next.js marketing site below |
| Marketing landing page | **Next.js** | Implemented | Public-facing site explaining the product; no app functionality |
| Backend | **FastAPI** | Implemented | Lightweight async Python API layer |
| Auth | **JWT + bcrypt** | Implemented (backend, Flutter, and web) | Stateless, standard token auth |
| Cloud database | **Firebase / Firestore** | Implemented for user accounts and cycle logs; not yet used for any other health data | Managed NoSQL store, pairs with Firebase Auth long-term |
| Local storage | **Hive** | Implemented | Fast, dependency-light on-device storage for offline access |
| AI assistant | **Google Gemini API** | Implemented (called directly from Flutter) | Strong multilingual generation for Indian languages |
| State management | **Provider** | Implemented | Simple, sufficient reactivity for theme/locale |
| Notifications | **flutter_local_notifications** | Implemented | Local reminder scheduling without a push backend |
| Localization | **Flutter intl / ARB files** (mobile), **i18next** (web) | Implemented | Native i18n tooling per platform |
| Charts | Custom `CustomPainter` | Implemented (basic) | `fl_chart` is a listed dependency but not yet used |
| SMS | **Twilio** | Implemented on backend; not connected to the app UI yet | Reaches users without reliable data connectivity |
| WhatsApp messaging | **Twilio / Meta Cloud API (planned)** | Not implemented | Needed for the planned WhatsApp bot |
| ML scoring | **XGBoost / Logistic Regression (planned), heuristic fallback (current)** | Partially implemented — heuristic version is live behind `/dashboard` | Efficient, interpretable scoring approach once trained |
| Routing | Manual `IndexedStack` / `Navigator` (Flutter), `react-router-dom` (web) | Implemented | `go_router` is a listed Flutter dependency but not yet used |
| CI/CD | **GitHub Actions** | Implemented | Runs Flutter analyze/format/test and backend `pytest` on every PR/push to `main` |
| Encryption | — | Not implemented | `encrypt` / `flutter_secure_storage` are listed dependencies; `flutter_secure_storage` is now used for the JWT, the rest is unused |
| Connectivity detection | — | Not implemented | `connectivity_plus` is a listed dependency but unused |

---

## Architecture

Rhythma currently consists of two independently runnable pieces that are **partly connected**:

```
┌──────────────────────────────────────────────┐
│                 Flutter App                   │
│                                                │
│  Login/Register ──► /auth (real, gates entry) │
│                                                │
│  Home · Cycle · Assistant · Insights · Profile│
│  Home screen ──► GET /dashboard (real scores) │
│                                                │
│  ┌──────────────────────────────────────┐     │
│  │  Hive (local, on-device)              │     │
│  │  → profile, settings, contacts        │     │
│  │  → cycle log storage exists,          │     │
│  │    but no screen writes to it yet     │     │
│  └──────────────────────────────────────┘     │
│                                                │
│  Cycle screen ──X no persistence (mock state) │
│  Gemini API ◄── called directly for AI chat   │
└──────────────────────────────────────────────┘

┌──────────────────────────────────────────────┐          ┌────────────────────────────────┐
│               FastAPI Backend                 │◄─────────  Website (web/, React)          
│                                                │          │  Login/Register ──► /auth (real)│
│  /auth      → real JWT auth, Firestore users  │          │  No other pages yet             │
│  /assistant → real Gemini call (unused by     │          └────────────────────────────────┘
│               either front end)               │
│  /cycle     → POST /log persists to Firestore;│
│               GET history reads real logs     │
│  /dashboard → real CVI/MHS/risk, computed      │
│               live from persisted cycle logs  │
│  /insights  → older stub, superseded by        │
│               /dashboard, not yet removed      │
│  /sms       → real Twilio integration         │
│  /health    → basic health check              │
└──────────────────────────────────────────────┘
```

The Flutter app's Home screen and both front ends' login/registration are the only points where a client currently talks to the backend — everything else in Flutter still runs off local Hive storage and a direct Gemini connection. In practice this means `/dashboard` almost always reports "not enough data yet," because the one endpoint that would give it real data to score (`POST /cycle/log`) isn't called by anything yet — closing that gap is the single highest-leverage next step (see [Project Status](#project-status)).

There is no WhatsApp, first-period, or Ayurvedic-content layer in this architecture yet — they would each attach to the backend (`/assistant` for WhatsApp; new endpoints/content sources for first-period and Ayurvedic content).

---

## Folder Structure

```
Rhythma/
├── .github/workflows/              GitHub Actions CI
│   ├── flutter.yml                 Analyze, format, test (on rhythma_flutter/ changes)
│   └── backend.yml                 pytest (on backend/ changes)
│
├── backend/                       FastAPI backend
│   ├── api/
│   │   ├── assistant.py           Gemini chat endpoint (not yet used by either front end)
│   │   ├── cycle.py                Cycle log endpoints — POST /log and GET history are real,
│   │   │                           persist to and read from Firestore
│   │   ├── dashboard.py            GET /dashboard — real CVI/MHS/risk computed live from a
│   │   │                           user's persisted cycle logs; called by the Flutter Home screen
│   │   ├── health.py               Health check
│   │   ├── insights.py             Older GET /{user_id}/scores stub, superseded by /dashboard
│   │   └── sms.py                  Twilio SMS endpoint (real, rate-limited)
│   ├── core/
│   │   ├── auth.py                 JWT + password hashing
│   │   └── auth_router.py          Register/login routes
│   ├── models/
│   │   ├── cvi_model.py            Cycle Variability Index scoring (heuristic fallback)
│   │   ├── mhs_model.py            Menstrual Health Score scoring
│   │   └── user.py                 Pydantic user schemas
│   ├── services/
│   │   └── firestore_service.py    Firestore user CRUD + CycleService (real cycle log CRUD)
│   ├── tests/
│   │   └── test_auth.py            Backend test suite (9 tests)
│   ├── utils/logger.py
│   ├── main.py                     App entrypoint, router registration
│   └── .env.example
│
├── rhythma_flutter/                Flutter application
│   ├── lib/
│   │   ├── main.dart                Checks session on start; routes to LoginScreen or the app
│   │   ├── config/theme.dart
│   │   ├── components/             bottom_nav, charts, shared widgets
│   │   ├── providers/              theme_provider, locale_provider, cycle_provider (mock state)
│   │   ├── services/               api_client, auth_service, assistant_service,
│   │   │                           local_storage_service, gemini_service,
│   │   │                           firestore_service (stub), notification_service
│   │   ├── screens/
│   │   │   ├── auth/               login_screen, register_screen (real, calls backend)
│   │   │   ├── home/               calls GET /dashboard for real cycle/insight data
│   │   │   ├── cycle/, assistant/, insights/, profile/
│   │   │   ├── settings/           settings, language, theme
│   │   │   └── sms/                built but not yet linked into navigation
│   │   └── l10n/                   en, hi, mr, ta, te translations
│   ├── test/                       widget_test, onboarding_test, widgets/calendar_grid_test
│   ├── env.example
│   └── pubspec.yaml
│   *(Note: `android/` and `ios/` platform folders are not committed; run
│   `flutter create .` before building for a device.)*
│
├── web/                            React + Vite + TypeScript web app (early scaffold)
│   ├── src/
│   │   ├── auth/                   AuthContext, ProtectedRoute (real, calls backend)
│   │   ├── api/client.ts           Axios client mirroring api_client.dart's token/401 handling
│   │   ├── i18n/locales/           en, hi, mr, ta, te
│   │   └── pages/                  LoginPage, RegisterPage (real), HomePage (placeholder only)
│   └── .env.example
│
├── landing-page/                   Standalone Next.js marketing site (Vercel) —
│                                    NOT the planned product website; see "Platforms"
├── docs/architecture.md            System design notes (describes target architecture)
├── design-concepts/                UI demo videos
├── screenshots/
├── requirements.txt                Backend Python dependencies
├── CONTRIBUTING.md
├── LICENSE
└── README.md
```

---

## Installation

### Prerequisites

- Flutter SDK 3.x
- Python 3.10+
- Node.js 18+ (only if you're working on `web/`)
- Git
- A Firebase project (for backend user storage)
- A Gemini API key ([get one here](https://ai.google.dev))
- A Twilio account (optional — only needed for SMS)

```
git clone https://github.com/ishita2740/Rhythma.git
cd Rhythma
```

### Running Flutter

```
cd rhythma_flutter

# Platform folders are not committed — generate them first
flutter create .

flutter pub get

cp env.example .env
# Add GEMINI_API_KEY to .env to enable real AI responses
# (without it, the assistant falls back to a canned demo response)

flutter run
```

### Running Backend

```
cd backend

python -m venv venv
source venv/bin/activate        # Windows: venv\Scripts\activate

pip install -r ../requirements.txt

cp .env.example .env
# Fill in JWT_SECRET, Firebase credentials, and (optionally) GEMINI_API_KEY / Twilio credentials

uvicorn main:app --reload
```

The API will be available at `http://127.0.0.1:8000`, with interactive docs at `http://127.0.0.1:8000/docs`.

To run backend tests:

```
cd backend
pytest
```

### Running the Web App

```
cd web
cp .env.example .env.local
# VITE_API_BASE_URL defaults to http://localhost:8000/api/v1, adjust if needed

npm install
npm run dev
```

This gets you a working registration/login flow and a placeholder home page — there's no cycle tracking, AI Assistant, or Insights page here yet (see [Platforms](#platforms)).

> **Note:** Both the Flutter app and the web app now require a real account. Register through either front end's Register screen against a running backend before you'll see anything past the login screen.

---

## Configuration

### Environment Variables

**Backend (`backend/.env`)**

| Variable | Required | Purpose |
| --- | --- | --- |
| `JWT_SECRET` | Yes | Signs and verifies auth tokens. App will not start without it. |
| `FIREBASE_SERVICE_ACCOUNT_JSON` or `FIREBASE_SERVICE_ACCOUNT_PATH` | Yes (one of the two) | Firebase Admin SDK credentials for Firestore access |
| `GEMINI_API_KEY` | Optional | Enables the backend's `/assistant/chat` endpoint |
| `TWILIO_ACCOUNT_SID` / `TWILIO_AUTH_TOKEN` / `TWILIO_PHONE_NUMBER` | Optional | Enables the `/sms/send-summary` endpoint |

**Flutter (`rhythma_flutter/.env`)**

| Variable | Required | Purpose |
| --- | --- | --- |
| `GEMINI_API_KEY` | Optional | Enables real AI responses in the Assistant tab; without it, a demo fallback response is shown |

**Web (`web/.env.local`)**

| Variable | Required | Purpose |
| --- | --- | --- |
| `VITE_API_BASE_URL` | No — defaults to `http://localhost:8000/api/v1` | Backend base URL the web app calls for `/auth`, etc. Vite only exposes `VITE_`-prefixed vars to client code. |

The backend's CORS config already whitelists the Vite dev server (`http://localhost:5173`) alongside `localhost:8000`/`localhost:3000`, so a default local setup works without touching `main.py`.

### Firebase Setup

The backend currently uses Firebase **only for user accounts** (via the Admin SDK). To set it up:

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com).
2. Generate a service account key: **Project Settings → Service Accounts → Generate new private key**.
3. Either paste the resulting JSON into `FIREBASE_SERVICE_ACCOUNT_JSON`, or save the file and point `FIREBASE_SERVICE_ACCOUNT_PATH` at it.
4. Ensure Firestore is enabled in the project (Native mode).

> **Note:** The Flutter app does not currently initialize Firebase or connect to Firestore on the client side — `firebase_core`, `cloud_firestore`, and `firebase_auth` are listed as dependencies for planned client-side sync but are not yet wired up. No `google-services.json` / `GoogleService-Info.plist` setup is required today.

---

## Project Status

| Area | Status |
| --- | --- |
| Flutter UI (screens, theming, localization) | ✅ Largely complete |
| In-app authentication (Flutter + web + backend) | ✅ Complete |
| Local storage (profile, settings, contacts) | ✅ Complete |
| Local notifications | ✅ Complete |
| Backend authentication (JWT/bcrypt) | ✅ Complete |
| Backend Firestore (user accounts) | ✅ Complete |
| Backend cycle log persistence (Firestore) | ✅ Complete |
| Backend `/dashboard` (live CVI/MHS/risk from real logs) | ✅ Complete |
| Home screen ↔ backend integration | ✅ Functional — but see cycle logging row below for why it's usually empty |
| AI Assistant (client → Gemini directly) | ✅ Functional |
| AI Assistant (backend endpoint) | ⚠️ Built, unused by either front end |
| Cycle tracking (persistence) | ❌ Logging UI built, but writes to neither Hive nor the backend — **the current top-priority gap** |
| Cycle/insights backend endpoints | ⚠️ `/cycle` is real; older `/insights/{user_id}/scores` is a stub superseded by `/dashboard` |
| CVI / MHS scoring | ⚠️ Heuristic logic live via `/dashboard`; no trained model yet; not yet surfaced on the Insights screen |
| SMS (Twilio) | ⚠️ Backend done; app UI built but unlinked |
| Cloud sync (Flutter ↔ Firestore) | ❌ Stubbed only |
| Encryption at rest | ❌ Not implemented |
| Connectivity detection | ❌ Not implemented |
| Website (`web/`) | ⚠️ Scaffolded — auth, routing, and i18n work; no cycle/insights/assistant pages yet |
| First Period Guidance | ❌ Not implemented — no design, content, or code yet |
| Ayurvedic Correlation Layer | ❌ Not implemented — no content or code yet |
| WhatsApp Bot Integration | ❌ Not implemented — depends on backend assistant endpoint going live first |
| Testing | ⚠️ 9 backend tests passing; Flutter suite covers onboarding + calendar grid but not yet the new auth screens; web app has no tests |
| CI/CD | ✅ GitHub Actions run Flutter analyze/format/test and backend pytest on every PR |
| Deployment | ⚠️ Landing page only (Vercel) |

**In short:** the Flutter UI, the FastAPI backend, and now a real auth-and-dashboard connection between them are each further along than before, but cycle logging — the one action that would make the rest of the pipeline meaningful — still doesn't persist anywhere. Wiring the daily-logging bottom sheet to Hive and/or `POST /cycle/log` is the single highest-leverage next task; everything downstream of it (`/dashboard`, CVI/MHS, the Insights screen) is already built and waiting for real data. First Period Guidance, the Ayurvedic layer, the WhatsApp bot, and the website's product pages are all clean-slate or near-clean-slate feature areas — good candidates for contributors who want to own something end-to-end, but each needs a scoping discussion first (see [CONTRIBUTING.md](./CONTRIBUTING.md)).

---

## Roadmap

### Phase 1 — Make it functional end-to-end

- Generate missing Flutter platform folders (`android/`, `ios/`)
- **Wire the Cycle screen's daily-logging bottom sheet to Hive and/or `POST /cycle/log`** — the top remaining item in this phase; everything downstream (`/dashboard`, CVI/MHS, Insights) is already built and waiting on this
- Reconcile the Flutter test suite with the new auth screens and daily-logging UI
- Link the built `SmsScreen` into app navigation

### Phase 2 — Connect frontend and backend

- ~~Build in-app login/registration against the existing backend auth~~ ✅ Done (Flutter and web)
- ~~Persist cycle logs through the backend `/cycle` endpoints~~ ✅ Backend side done — Flutter still needs to call it (see Phase 1)
- Decide on a single Gemini integration path (client-direct vs. backend-proxied) and remove the other
- Connect the dedicated Insights screen to `/dashboard` (Home screen already does this)
- Retire or redirect the older `/insights/{user_id}/scores` stub now that `/dashboard` exists

### Phase 3 — Offline-first & privacy

- Implement Hive encryption at rest
- Add connectivity detection and complete the stubbed Firestore sync logic
- Initialize Firebase on the client and add a sync-status indicator

### Phase 4 — Real ML scoring

- Collect/curate training data and ship trained CVI/MHS model artifacts
- Replace the current heuristic fallback with model-backed predictions

### Phase 5 — Expanded health content

- **First Period Guidance**: design and build a dedicated onboarding/education flow for ages 12–17
- **Ayurvedic Correlation Layer**: source and review educational content, then build the rules layer to surface it contextually
- Both require content/product decisions before implementation — see [Future Features](#future-features)

### Phase 6 — Platform expansion

- **Website with feature parity**: build cycle tracking, AI Assistant, Insights, and Profile pages on top of the existing `web/` auth scaffold — see [Platforms](#platforms)
- **WhatsApp-based assistant access**, built on top of the existing (but currently unused) `/assistant/chat` backend endpoint
- Automated releases and healthcare-provider partnerships

---

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](https://github.com/ishita2740/Rhythma/blob/main/CONTRIBUTING.md) before opening a pull request. Since large parts of the app are still being wired together (see [Project Status](#project-status)), issues that clarify or fix the frontend/backend integration gaps above are especially useful right now. First Period Guidance, the Ayurvedic Correlation Layer, WhatsApp Bot Integration, and the planned website are open, clean-slate feature areas — see [CONTRIBUTING.md](./CONTRIBUTING.md#feature-areas-open-for-contribution) for how to propose an approach.

---

## License

This project is licensed under the MIT License. See [LICENSE](https://github.com/ishita2740/Rhythma/blob/main/LICENSE) for details.

---

## Acknowledgements

- Built by [Ishita Rathi](https://github.com/ishita2740)
- AI assistance powered by [Google Gemini](https://ai.google.dev)
- Backend framework by [FastAPI](https://fastapi.tiangolo.com)
- Mobile framework by [Flutter](https://flutter.dev)
- Read the origin story: [*Building Rhythma: An AI health companion for the women India's apps forgot*](https://medium.com/@rathiishita1005729/building-rhythma-an-ai-health-companion-for-the-women-indias-forgot-e249ac1cdc9a)

---

## Disclaimer

Rhythma is intended for **educational and general wellness purposes only**. It is not a certified medical device and does not provide medical diagnoses, prescriptions, or treatment recommendations. The Cycle Variability Index (CVI) and Menstrual Health Score (MHS) are experimental, non-clinical metrics currently under development. Any future Ayurvedic content will be educational and non-prescriptive, not a substitute for medical advice. Always consult a qualified healthcare professional for medical advice.

---

*Built with 💜 for the women India's apps forgot.*
