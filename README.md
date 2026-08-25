# ReadyPackets Native Mobile Workspace

This repository contains **two independent native applications** and their shared, non-runtime assets: iOS uses SwiftUI and Swift Concurrency; Android uses Kotlin and Jetpack Compose. It intentionally does not use React Native, Flutter, Capacitor, a WebView shell, a PWA service worker, Manus code, Manus services, or a second customer database.

The companion [ReadyPackets Portal repository](https://github.com/readypackets/ReadyPackets) owns the self-hosted mobile API implementation, OAuth authorization server, device and token-family records, migrations, server audit trail, and production deployment. This repository owns the native clients, client-side tests, design tokens, store artifacts, and native release automation.

The clients connect only to the self-hosted ReadyPackets mobile boundary at `/api/mobile/v1`. Configure the production HTTPS host, verified app-link domain, OAuth redirect URI, signing identifiers, APNs/FCM provider credentials, and release secrets outside version control.

| Directory | Contents |
|---|---|
| `api-contract/` | Reviewed OpenAPI contract and fixtures. |
| `design-tokens/` | Versioned ReadyPackets colors, semantic values, spacing, and wording. |
| `ios/ReadyPackets/` | Swift 6 / SwiftUI application sources and Xcode project definition. |
| `android/` | Kotlin / Jetpack Compose Gradle project. |
| `docs/` | API, threat-model, accessibility, data disclosure, and release artifacts. |
| `website/mobile-experience-preview/` | Permanent self-hosted interactive mobile-experience preview, static assets, deployment configuration, and website session log. |

> The reference application supports customer work first. Customers can select listed packets and record an order request from either native app; the Portal verifies availability, pricing, payment, workflow activation, and the order record. High-impact administration, bulk data export, backup/restore, key management, refunds, payment collection, configuration, and platform control remain web-only.

The complete shared order contract and iOS/Android test procedures are documented in [`docs/PLATFORM_PARITY_AND_TESTING.md`](docs/PLATFORM_PARITY_AND_TESTING.md).
