# Session Log

## 2026-08-22 — Native mobile repository split

### User request

> "shouldnt this go to its own github repo?"

The requested native iOS and Android client implementation was initially committed with the ReadyPackets Portal because the supplied mobile master prompt described a monorepo-style layout. The user then instructed the work to be separated into its own repository and created `https://github.com/readypackets/readypackets-native-mobile` for that purpose.

### Implementation response

The standalone repository contains the native client source and client-owned release materials: the SwiftUI iOS project, Kotlin/Jetpack Compose Android project, shared ReadyPackets design tokens and brand asset, OpenAPI contract copy, mobile threat model, accessibility and data-disclosure plans, API compatibility documentation, store-release runbook, and independent native CI.

The companion `readypackets/ReadyPackets` portal repository retains the self-hosted integration boundary: `/api/mobile/v1`, OAuth authorization-code and PKCE handling, rotating refresh-token families, device/session persistence, server-side authorization, migration `005_mobile_identity.sql`, audit events, CSRF scoping, browser login continuation, and the portal-side mobile contract tests.

### Source and dependency boundary

The mobile applications do not include Manus runtime code, Manus services, React Native, Flutter, Capacitor, WebViews, a PWA shell, a client-side customer database, client secrets, server signing keys, payment checkout, or privileged portal administration. Production endpoints, App/Universal Links, native signing identities, APNs/FCM provider credentials, release keys, and privacy/review metadata remain protected release-system configuration.

### Validation plan

The Android project has a Gradle wrapper and its API 36 compile/unit-test workflow. The iOS project has an unsigned simulator build workflow on macOS. Client source was transferred from the previously validated implementation; the final repository-split validation records both native and portal repository commit identifiers once the split is published.

## 2026-08-25 — Order placement and parity update

The native application now includes a customer order-placement journey on both platforms. Android Jetpack Compose and iOS SwiftUI load the same listed packet catalog, constrain selection to one packet tier per group, submit only public packet SKUs and an optional project name, and display the Portal’s server-authoritative next action. The clients do not calculate an authoritative price, submit payment data, control workflow activation, or set an order status.

The Portal mobile API now defines `GET /catalog` and idempotent `POST /orders`. Submission requires `mobile:write`, resolves public SKUs to active listed products on the server, delegates to the Portal order service, and returns either a secure Portal payment instruction or an awaiting-quote instruction. The shared OpenAPI contract is retained in both the Portal API directory and this native repository.

Android validation passed with `testDebugUnitTest` on Java 17 and Android API 36. iOS requires the documented macOS/Xcode, signing, Universal Link, Keychain, physical-device biometric, and TestFlight validation path before release.

## 2026-08-25 — Permanent mobile-experience website handoff

The source for the permanent self-hosted ReadyPackets mobile-experience preview has been added at `website/mobile-experience-preview/`. It includes the interactive local-data browser demonstration, the self-hosted static asset set, Nginx configuration, deployment guide, project README, and the website-specific session log. The nested site has no Portal API, authentication, customer data, hosted analytics, or runtime dependency; its bundled assets are retained so it can be built and hosted without an external asset service.

## 2026-08-26 — GitHub synchronization completed

The dedicated native repository, including the SwiftUI client, Kotlin/Jetpack Compose client, shared API contract, design tokens, local self-hosted website source and assets, release documentation, and all available session logs, was published to `readypackets/readypackets-native-mobile`. The first published commit is `54c8890` (`feat: add native order placement and permanent mobile preview`). A subsequent documentation commit records the successful synchronization outcome.

---

*This file is the mobile-repository portion of the required session record. The companion portal repository retains the preceding API implementation session log and server-side validation history.*

## 2026-08-26 — Release documentation and redacted transcript

The user requested a release-summary report, versioned release notes, GitHub Actions automation guidance, App Store and Google Play listing copy, privacy disclosure material, and a repository-safe record of prompts and responses. The native repository now includes `docs/MOBILE_RELEASE_SUMMARY.md`, `docs/releases/1.0.0-RELEASE_NOTES.md`, `docs/STORE_LISTING_AND_PRIVACY_WORKSHEET.md`, `docs/MOBILE_CICD_GUIDE.md`, the protected release-candidate workflow, and `docs/session/SESSION_TRANSCRIPT_2026-08-26.md`.

The transcript preserves the actionable current-session requests and implementation responses while redacting credentials and sensitive tokens. It records that a GitHub credential was used temporarily for requested source synchronization and must be revoked/replaced because it was shared through chat.

## 2026-08-26 — Release package publication

The complete release-documentation package was published to `readypackets/readypackets-native-mobile` commit `c88efb4` (`docs: add mobile release and store submission package`). It includes the protected release-candidate workflow, non-secret staging endpoint configuration, signing-file exclusion, release notes, store listing and privacy worksheet, CI/CD guide, and redacted prompt/response transcript. No signing key, access token, or production environment secret was committed.

## 2026-08-27 — Full customer mobile-parity expansion

**User request:** The user requested that customers choose either native app or web Portal for customer use, with administration remaining web-only, and requested GitHub-synchronized context/session records.

**Completed:** The iOS SwiftUI and Android Jetpack Compose customer apps now expose matching customer work surfaces: documents, deliverables, AAC-LC/M4A recordings, protected media upload/download/playback, workflow actions, intake submission, Portal-hosted invoice/payment handoff, messages, updates, support, community, Packet Collective workspaces, referrals, knowledge, FAQ, public packet/legal/contact entry, and system-browser account-security/recovery actions. Sensitive identity and payment flows remain in the verified Portal system-browser session by design.

**Push and privacy:** iOS registers APNs tokens through the application delegate after authorization; Android registers FCM tokens after authenticated startup and token rotation. Provider credentials and Android `google-services.json` stay untracked. Customer audio/documents are staged privately and only transmitted over authenticated HTTPS to Portal-controlled authorization, retention, and encryption services.

**Validation:** Android `testDebugUnitTest` passed on Java 17/Android API 36 after the customer expansion. iOS source requires macOS/Xcode compilation, entitlement, APNs, microphone/audio, biometric, Universal Link, and TestFlight validation. The detailed safe deployment and parity conditions are in `docs/MOBILE_CUSTOMER_PARITY_STATUS.md`; this session record is preserved in `docs/session/SESSION_TRANSCRIPT_2026-08-27_CUSTOMER_PARITY.md`.

**GitHub synchronization:** The complete native customer-parity implementation was published to `readypackets/readypackets-native-mobile` commit `8106c30` on 2026-08-27. The matching self-hosted Portal customer API, encrypted push-token migration, OpenAPI contract, and enforcement tests were published to `readypackets/ReadyPackets` commit `e735f89`. No provider credential, signing material, or payment-card data was committed.

## 2026-08-27 — Customer preview, offline workspace, and technical review

**User request:** The user requested a new testable view of the customer application, Android build and offline-workspace verification, exact checkout/push endpoint details, and a code review of AAC-LC/M4A audio handling.

**Completed:** The nested self-hosted website source now demonstrates the full customer journey with representative local data. The Android customer app has an opt-in encrypted offline document cache keyed by non-enumerable SHA-256 references, temporary scoped viewer access, and clear-on-sign-out behavior. `testDebugUnitTest` and `assembleDebug` both passed after the change. `docs/CUSTOMER_APP_TECHNICAL_REVIEW.md` records the tested behavior, implementation settings, endpoint paths, and release-owner prerequisites.

**Boundary:** The browser preview cannot record audio, contact a Portal, register a real device, cache a real document, or perform payment. The native Android APK can exercise those device paths only after it is configured against a non-production Portal environment. No Portal records, credentials, card data, provider credential, or signing material is included in the preview source or test artifact.

**GitHub synchronization:** The completed preview, encrypted offline-document source, scoped FileProvider configuration, debug-cache unit test, bundled self-hosted assets, technical review, and redacted transcript were published to `readypackets/readypackets-native-mobile` in commit `f47df07` on 2026-08-27. The repository was fetched and rebased before publication; the published `main` head was verified clean afterward.

## 2026-08-27 — Customer preview visual refinement

The local-data customer-app preview was refined after mobile visual verification. It now leads with the interactive device on small screens, uses full-width operational evidence rows instead of a compressed sidebar treatment, carries the Packet Gold identity through the wordmark and briefing, and replaces generic infrastructure imagery with an explicit customer-device-to-Portal route diagram. The preview type check and static build passed. The source, website log, and testing checklist are synchronized into the native repository as the final preview update.

## 2026-08-27 — Staging Android artifact and customer checkout handoff

**User request:** The user requested a staging Portal environment, an Android debug APK direct download, and refinement of the Portal invoice and payment experience without moving card data into ReadyPackets.

**Native deliverable:** `docs/ANDROID_PHYSICAL_DEVICE_TESTING.md` defines the approved device sequence for a debug artifact: staged OAuth/App Link configuration, microphone recording, opt-in encrypted offline document cache, hosted test-mode checkout, in-app updates, and sign-out cleanup. The current APK was assembled from the validated customer application and its SHA-256 digest was checked before release. It has non-production placeholder endpoints; a release owner must make a separate staging-configured debug build before it can authenticate a real staging customer.

**Security boundary:** The Android app opens the verified system-browser checkout URL and never handles card data. Staging credentials, Firebase configuration, provider credentials, signed release keys, customer data, and private device identifiers are not in Git. The staging server runbook remains Portal-owned because its data, encryption, payment-webhook, and customer-role controls must stay independent of a test-device build.
