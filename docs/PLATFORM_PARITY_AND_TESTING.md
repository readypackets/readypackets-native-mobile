# iOS and Android Parity and Pre-Publication Testing

The ReadyPackets native clients share one **mobile API contract** and support the same customer business flows: browser-based sign-in, device-bound credential storage, biometric re-entry, dashboard review, order review, packet selection, order submission, Portal-managed payment handoff, device review, and deletion request. The clients are not intended to be pixel-identical; each uses its platform’s expected navigation, secure-storage, and biometric affordances.

| Customer capability | iOS | Android | Shared authority |
|---|---|---|---|
| Sign-in and MFA | `ASWebAuthenticationSession` returns through a verified Universal Link | Custom Tabs returns through a verified Android App Link | ReadyPackets OAuth 2.1 + PKCE authorization server |
| Credential protection | Keychain with `WhenUnlockedThisDeviceOnly` and LocalAuthentication | Keystore-backed encrypted preferences and BiometricPrompt | Short-lived access token; rotated refresh-token family |
| Current work and order detail | SwiftUI Home and Orders views | Jetpack Compose Home and Orders views | `GET /dashboard`, `GET /orders`, and `GET /orders/{publicOrderId}` |
| Select packet and create an order | SwiftUI order composer | Jetpack Compose order composer | `GET /catalog` and idempotent `POST /orders` |
| Price, payment, and activation | Displays Portal result only | Displays Portal result only | Portal resolves product availability, pricing, workflow, payment status, audit event, and activation; the app never receives card data |
| Account and devices | Profile, device list, deletion-request guard | Profile, device list, deletion-request guard | Mobile device and account endpoints |

## Order placement boundary

The client submits only a **listed packet SKU**, quantity, optional project name, a bearer token, and an idempotency key. It does not submit a price, total, internal product ID, payment status, order status, or workflow state. The Portal validates the selected SKUs, restricts one tier per packet group, resolves the quote, records the order and audit event, and responds with the allowed next action.

> Card data must never be collected by either native client. Where payment is required, the order is recorded and the customer completes payment through the secure ReadyPackets Portal. Where custom pricing is required, the Portal records the request as awaiting a quote.

## Android test path

The Android project is currently validated with Java 17 and Android API 36. Use a non-production Portal hostname and a real device or Android emulator with the verified App Link installed.

```bash
cd android
JAVA_HOME=/path/to/jdk-17 ANDROID_HOME=/path/to/android-sdk ./gradlew testDebugUnitTest assembleDebug --no-daemon --max-workers=1
adb install -r app/build/outputs/apk/debug/app-debug.apk
```

After installation, test secure sign-in, a listed packet selection, an idempotent order retry, the custom-quote response, the payment-required response, an order-list refresh, device registration, sign-out, and biometric re-entry. Use a staging account and non-production catalog data only.

## iOS test path

Build iOS on a macOS host with a current Xcode release, an Apple development team, and a staging-only ReadyPackets Portal hostname. Configure the associated-domain entitlement and the registered Universal Link redirect URI before testing.

1. Open `ios/ReadyPackets/ReadyPackets.xcodeproj` in Xcode and select a development signing team.
2. Set the staging `PORTAL_BASE_URL`, matching OAuth redirect URI, and associated domain according to `AppConfig.swift` and your Xcode build settings.
3. Run on both a simulator for layout/accessibility work and a physical device for Universal Link, Keychain, and biometric validation.
4. Archive a signed staging build, distribute it to internal testers through TestFlight, and test sign-in, ordering, Portal payment handoff, device revocation, logout, and restoration from a cold launch.

Apple’s TestFlight workflow and Android’s device-testing guidance are maintained in their official documentation. [1] [2]

## Equality statement

The implementations are **feature-equivalent for the supported customer workflows listed above** and use the same API schema. They are deliberately not code-identical or visually identical: SwiftUI/UIKit platform behavior, Keychain/LocalAuthentication, Universal Links, Jetpack Compose, Android Keystore, BiometricPrompt, and App Links are different native platform mechanisms. Checkout remains a Portal-controlled browser handoff on both platforms.

## References

[1]: https://developer.apple.com/testflight/ "Apple TestFlight"
[2]: https://developer.android.com/studio/run/device "Run apps on a hardware device — Android Developers"
