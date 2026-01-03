# Tech Stack - Journeyman Jobs

## Frontend
- **Framework:** Flutter (v3.6.0+)
- **State Management:** Riverpod (using `flutter_riverpod`, `riverpod_annotation`, and `riverpod_generator` for type-safe state)
- **Navigation:** go_router (Type-safe routing)
- **Design System:** Custom electrical-themed design using `shadcn_ui` components and `flutter_animate`.

## Backend & Infrastructure
- **Platform:** Firebase
    - **Authentication:** Secure user sign-in (Email, Google, Apple).
    - **Database:** Cloud Firestore (Real-time job and storm data).
    - **Storage:** Firebase Storage (Certifications and profile images).
    - **Messaging:** Firebase Cloud Messaging (FCM) for urgent storm notifications.
    - **Performance:** Firebase Performance Monitoring & Crashlytics.
- **Cloud Functions:** Node.js (for backend logic and third-party integrations).

## External Integrations & APIs
- **Weather:** NOAA/National Weather Service APIs (Radar imagery, alerts, and storm tracking).
- **Maps:** `flutter_map` with OpenStreetMap.
- **Location:** `geolocator` for proximity-based job matching.

## Development & Tooling
- **CI/CD:** GitHub Actions (Automated Firebase Hosting deployment and testing).
- **Environment Management:** `.env` files for configuration.
- **AI Integration:** Google Generative AI (Gemini) for advanced data processing/parsing.
