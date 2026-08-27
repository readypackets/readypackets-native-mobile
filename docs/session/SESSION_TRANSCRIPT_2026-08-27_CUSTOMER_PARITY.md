# ReadyPackets Customer-Parity Mobile Session Record

**Date:** 2026-08-27

## User request

The user requested that the customer be able to choose either the native application or the ReadyPackets web Portal for full customer use, while retaining all administration in the web Portal. The requested customer capability families were document/deliverable management, audio recording/upload/playback, workflow and legal acknowledgements, invoices with browser-hosted payment, secure messages, updates and push registration, support, community, Packet Collective workspaces, referrals, customer account/security controls, registration/recovery, public packet browsing, FAQ, contact, and legal information. The user further requested that the context and session records be updated and synchronized to GitHub.

## Assistant implementation response

The Portal now exposes a narrowly allowlisted mobile customer API in addition to its existing OAuth/PKCE and order endpoints. The API reuses Portal customer services and does not grant staff or administrator procedures. It uses bearer mobile tokens, opaque resource references, scope enforcement, idempotency on mutations, server-controlled workflow/file checks, hosted payment handoff, published-only public information, and a system-browser boundary for sensitive identity actions.

The iOS SwiftUI and Android Kotlin/Jetpack Compose clients now provide matching customer capability families. They use platform-native document selection, temporary private staging, AAC-LC audio in MPEG-4/M4A containers, secure upload/download, audio playback, workspaces, support, messages, updates, referrals, community/help surfaces, and secure browser handoffs. Push-registration adapters target APNs and FCM after Portal authentication, without embedding provider credentials in client source.

## Validation and limitations

Portal TypeScript validation passed. The focused mobile contract suite passed 6/6. Android `testDebugUnitTest` passed on Java 17 with Android API 36. A macOS/Xcode host is still required for iOS compilation, signing, APNs verification, Universal Links, biometric checks, recording/playback, and TestFlight validation.

The release owner must apply migration `006_mobile_push_token_encryption.sql`, configure APNs and FCM credentials in the self-hosted controlled environment, add Android `google-services.json` outside Git, configure verified App/Universal Link association files, and conduct staging device validation before external distribution. No credential, signing key, provider configuration, payment-card data, or administrative control was committed.
