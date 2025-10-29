# Tailboard Deployment Guide

This guide covers deployment for the Tailboard feature's backend and frontend integration, focusing on Firebase services and CI/CD automation. Assumes Firebase project setup is complete (as per Sections 1-12).

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project configured with Hosting, Firestore, and Functions enabled.
- GitHub repository with secrets set:
  - `FIREBASE_SERVICE_ACCOUNT_JOURNEYMAN_JOBS`: Service account JSON key from Firebase Console > Project Settings > Service Accounts.
- Flutter SDK and dependencies installed.
- User must enable publish rules and add indexes in Firebase Console (Firestore > Rules/Indexes).

## Manual Deployment

### 1. Build the Flutter Web App
```
flutter pub get
flutter build web --web-renderer canvaskit --release
```

### 2. Deploy to Firebase Hosting (Web)
```
firebase login
firebase deploy --only hosting
```
- Deploys `build/web` to Firebase Hosting.
- Configured in `firebase.json` with rewrites for SPA routing.

### 3. Full Firebase Deploy (Functions, Firestore Indexes, Hosting)
```
firebase deploy
```
- Deploys Cloud Functions (if any backend logic).
- Deploys Firestore indexes from `firestore.indexes.json`.
- Deploys Hosting.
- Use `--only functions` or `--only firestore:indexes` for targeted deploys.

### 4. Verify Deployment
- Hosting URL: Check Firebase Console > Hosting.
- Firestore: Verify data/rules in Console.
- Functions: Test endpoints in Functions tab.

## CI/CD Setup (GitHub Actions)

Automated workflows are in `.github/workflows/`:

### Production Deploy (Merge to Main)
- File: `firebase-hosting-merge.yml`
- Triggers: Push to `main`.
- Steps: Checkout, setup Node/Flutter, install deps, run tests, build web, deploy to live channel.
- Preview: Actions tab shows logs; deploys to production URL.

### PR Previews
- File: `firebase-hosting-pull-request.yml`
- Triggers: PR open/synchronize against `main`.
- Steps: Same as production but deploys to preview channel.
- Preview: Unique URL in PR comments/Actions tab for review.

### Setup Instructions
1. Add secret `FIREBASE_SERVICE_ACCOUNT_JOURNEYMAN_JOBS` in GitHub > Settings > Secrets > Actions.
2. Push to `main` or open PR to trigger.
3. Monitor in GitHub Actions tab; failures show logs for debugging.
4. No `FIREBASE_TOKEN` needed; service account handles auth.

### Customization
- Edit workflows for additional steps (e.g., linting, e2e tests).
- For mobile builds (APK/IPA), add Flutter build steps if needed (not included for web focus).

## Monitoring and Analytics

### Firebase Console Dashboards
- **Performance Monitoring**: 
  - Enabled in `main.dart`.
  - Tracks network requests, screen renders, custom traces.
  - View: Firebase Console > Performance > Overview.
  - Key metrics: App start time, HTTP/S network requests, custom traces (e.g., Firestore queries).

- **Crashlytics**:
  - Initialized in `main.dart` for Flutter errors.
  - Records fatal/non-fatal errors via `recordError` in `lib/utils/error_handling.dart`.
  - Integrates with services (e.g., DatabaseService catches and logs exceptions).
  - View: Firebase Console > Crashlytics > Crashes/Issues.
  - Setup: Enable in Console > Crashlytics; no additional config needed.

- **Analytics**:
  - Logs events (e.g., `post_created`, `job_shared`) in `analytics_service.dart`.
  - Tracks screen views, user properties.
  - View: Firebase Console > Analytics > Events/DebugView.
  - Key events for Tailboard: Post creation, job sharing, crew joins.

### Additional Monitoring
- **Firestore Usage**: Console > Firestore > Usage for reads/writes/indexes.
- **Security Rules**: Test in Rules Playground; monitor violations in logs.
- **Performance Optimizations**: Review traces for bottlenecks (e.g., query times >500ms).
- **Alerts**: Set up email/Slack notifications in Console for crashes > threshold.

## Production Readiness Checklist

- [ ] Firebase Console: Publish rules, add indexes (user must complete).
- [ ] Secrets: GitHub service account configured.
- [ ] Tests: Run `flutter test` before push.
- [ ] Build: Verify web build succeeds locally.
- [ ] Monitoring: Enable Performance/Crashlytics in Console.
- [ ] Offline: Test persistence; cache size limited to 100MB.
- [ ] Security: Review rules for production (e.g., authenticated access).

## Troubleshooting

- **Deploy Fails**: Check CLI version, auth (`firebase login`), project ID.
- **Workflow Errors**: Verify secrets, Flutter version in YAML.
- **No Preview URL**: Ensure PR against `main`; check Actions logs.
- **Monitoring Data Delay**: Analytics/Performance data populates within 24h.
- **Quota Exceeded**: Monitor billing; optimize queries/indexes.

For issues, check Firebase logs or GitHub Actions. Contact support for Firebase-specific problems.

---

*Aligned with implementation guide: Automated deploys via CI/CD, error monitoring via Crashlytics, production-ready with performance tracking.*