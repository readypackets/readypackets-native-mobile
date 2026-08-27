# ReadyPackets Mobile Customer Parity Status

**Scope:** This release gives a signed-in customer a mobile route for each customer journey available in the Portal. Staff configuration, catalog administration, finance operations, moderation, CMS, identity-policy administration, audit/replay, system settings, integrations, and other operational tasks remain deliberately web-only.

| Customer capability | Native implementation | Portal authority and release condition |
|---|---|---|
| Files, documents, deliverables | iOS/Android select, upload, list, download, and consume released deliverables. | The Portal checks ownership, sharing scope, stage capability, size/type limits, and stores authoritative records. |
| Audio | iOS and Android record mono AAC-LC in `.m4a`, upload it as workflow media, and play authorized audio. | The Portal checks the permitted stage; neither app assumes a recording is accepted. |
| Workflow, intake, MNDA/NDAs | Both apps present authorised stages and submit customer actions. | The Portal resolves stage eligibility, acknowledgements, locks, and legal records. |
| Invoices and payment | Both apps retrieve customer invoices and open hosted Portal checkout in the system browser. | Payment cards never enter the app; the Portal/Stripe flow remains authoritative. |
| Messages, updates, support | Both apps show messages and derived notification inbox items; support ticket creation is available. | Portal permissions, staff notes, audit retention, and delivery policy remain server controlled. |
| Community, Packet Collective, referrals | Both apps browse community/workspaces, create workspaces, view referrals, and use customer-safe sharing routes. | Published-only/moderated content and owner/member controls are checked by Portal procedures. |
| Profile, policies, recovery, MFA | Both apps route sensitive identity tasks through the secure system browser; profile/policy APIs are customer only. | Registration, verification, recovery, passwords, MFA, SSO, and legal acknowledgement stay inside the Portal’s existing identity controls. |
| Public content | Packet browsing, FAQs, policy content, contact, and status are exposed from a public mobile route. | Only already-published Portal content is returned; no staff, customer, or draft data crosses the boundary. |

## Required release-owner configuration

Apply Portal migration `006_mobile_push_token_encryption.sql` before enabling device push tokens. The server stores a token hash for duplicate detection and an encrypted token only for the self-hosted dispatcher. Configure APNs credentials and Firebase Cloud Messaging in the controlled server environment; do not add either credential to the native repositories. Until a dispatcher is configured, the in-app notification inbox remains functional but remote delivery is intentionally disabled.

For Android, add the Firebase project configuration as an untracked `android/app/google-services.json` file and configure the matching FCM sender identity only in the deployment environment. For iOS, upload the APNs credential to the self-hosted dispatcher and ensure the app’s production bundle identifier and environment match that credential. Both apps register a push token only after successful Portal authentication and send it exclusively to the authenticated `/api/mobile/v1/devices` endpoint.

Configure the verified `https` Universal Link/App Link host, the staging/production Portal base URL, OAuth redirect URI, and platform signing identities. Perform iOS physical-device tests for microphone permission, APNs registration, audio playback, document import/export, Universal Links, and biometric re-entry. Perform corresponding Android device tests for microphone, FCM, media selection, App Links, and biometric re-entry.

## Media and privacy controls

Audio and document staging occurs in platform-private temporary storage. The application sends file bytes only through authenticated HTTPS requests to the Portal, which applies per-stage permission, file policy, audit, retention, encryption, and delivery controls. Audio samples must be documented as user-provided content in the final App Store and Google Play disclosure answers; update the existing release worksheet after confirming the final production retention and optional push provider configuration.

## Accessibility acceptance checks

Every customer function requires an explicit label, readable status/error state, keyboard/switch reachability where applicable, support for Dynamic Type or Android font scaling, and no color-only workflow or payment status. Test the file selector, microphone denial state, recording state, audio playback, web handoff return, support-ticket form, community actions, policy confirmation, and destructive account deletion with VoiceOver and TalkBack before external distribution.
