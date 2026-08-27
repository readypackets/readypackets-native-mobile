# ReadyPackets Customer App — Technical Review

**Review date:** 2026-08-27

**Scope:** Native iOS and Android customer workflows, mobile API endpoint boundary, Android offline document workspace, checkout handoff, device-push registration, and order audio handling.

## Tested Android result

The Android customer application successfully completed `testDebugUnitTest` and `assembleDebug` with Java 17, Android API 36, and a constrained single-worker Gradle configuration. The release artifact is a **debug-only customer preview** and must not be used for store distribution.

The new `DocumentCacheTest` confirms that cached offline-document references are stable 64-character SHA-256 keys, rather than plaintext server references. The app stores encrypted bytes in app-private storage through AndroidX `EncryptedFile`; cache index metadata is held in encrypted shared preferences. Sign-out clears the document-cache directory and its encrypted index.

> Offline documents are available only after a customer explicitly chooses **Keep offline** while connected. The app does not silently download order content. On a later offline open, the file is decrypted only into a temporary app-cache file, opened through a scoped `FileProvider` read grant, and is never placed in shared storage. An active device should still be revoked server-side if it is lost or compromised.

## Secure checkout and invoices

The native app never receives or handles payment-card data. It retrieves customer invoice information and asks the Portal to mint a verified checkout handoff. The resulting URL is opened using the system browser.

| Purpose | Method and path beneath `/api/mobile/v1` | Control |
|---|---|---|
| List an order’s invoices | `GET /customer/orders/{publicOrderId}/invoices` | Customer bearer token; opaque order reference. |
| Retrieve a customer invoice PDF | `GET /customer/invoices/{publicInvoiceId}/content` | Customer bearer token; Portal PDF rendering. |
| Begin payment handoff | `POST /customer/invoices/{publicInvoiceId}/checkout` | `mobile:write` scope and idempotency key; Portal/Stripe hosted checkout only. |

## Device push registration

Both native applications register only the authenticated installation that was bound during OAuth. Provider tokens are encrypted on the Portal and are not included in source control.

| Platform | Native source | Endpoint | Provider configuration required |
|---|---|---|---|
| Android | `PushRegistrar.kt`, `ReadyPacketsMessagingService.kt` | `POST /devices` | Firebase Cloud Messaging project configuration outside Git. |
| iOS | `ReadyPacketsApp.swift`, `DeviceInstallation.swift` | `POST /devices` | APNs entitlement, signing profile, and server-side APNs credentials. |

The request accepts `deviceId`, `platform`, `appVersion`, `deviceName`, `pushPlatform`, and an optional provider `pushToken`. The Portal rejects a device ID that does not match the bearer token’s installation, hashes the token for duplicate detection, and encrypts the provider token at rest. Apply Portal migration `006_mobile_push_token_encryption.sql` before enabling provider delivery.

## Native order audio capture

| Detail | iOS | Android |
|---|---|---|
| API | `AVAudioRecorder` | `MediaRecorder` |
| Container | MPEG-4 `.m4a` | MPEG-4 `.m4a` |
| Codec | `kAudioFormatMPEG4AAC` (AAC-LC) | `MediaRecorder.AudioEncoder.AAC` (AAC-LC) |
| Sample rate | 44.1 kHz | 44.1 kHz |
| Channels | Mono | Mono |
| Encoder quality / rate | High encoder quality | 96 kbps |
| Local staging | Temporary directory until upload | App-private cache directory until upload |

The Portal accepts a native recording only through the authorized current workflow-stage file route:

| Purpose | Method and path beneath `/api/mobile/v1` | Control |
|---|---|---|
| Upload document or recording | `POST /customer/orders/{publicOrderId}/files` | Bearer token, `mobile:write`, stage capability, multipart MIME/extension validation, payload limits, idempotency. |
| Read protected file/audio bytes | `GET /customer/files/{mobileFileRef}/content` | Bearer token and opaque, customer-bound file reference. |
| Review audio metadata | `GET /customer/files/{mobileFileRef}` | Customer-only file metadata; detected MIME and probe-derived duration. |

The client marks a native capture as `recordedAudio`. The Portal requires `.m4a` or `.webm` for that category, probes duration server-side, records the activity, and preserves order-level authorization. A device cannot select an arbitrary file reference or bypass a closed workflow stage.

## Release-owner checklist

The customer application source and preview package are ready for further device review. Before staging customer data or enabling production traffic, a release owner must apply the Portal migration, configure APNs and FCM credentials outside Git, publish verified Universal/App Links, conduct iOS device validation on macOS/Xcode, and verify the staging Portal’s per-workflow upload permissions and retention rules.
