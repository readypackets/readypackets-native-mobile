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
