# ReadyPackets Mobile Store Listing and Privacy Worksheet

**Purpose:** This is a release-owner worksheet, not a legal conclusion. It is grounded in `DATA_DISCLOSURE_MAP.md` and the current native source. Reconcile every row against the exact signed release, production Portal configuration, third-party SDK inventory, jurisdictions, public privacy policy, and legal review before App Store Connect or Play Console submission.

Apple requires developers to declare applicable data practices, including those of third-party code, and to keep disclosures current. [1] Google Play requires a Data Safety declaration and privacy policy for published applications, including relevant data handled by third-party libraries or SDKs. [2]

## App Store listing copy — working draft

| Field | Proposed copy |
|---|---|
| App name | ReadyPackets |
| Subtitle | Authorized business packets, securely managed |
| Promotional text | Review authorized work, place packet requests, and follow the next secure step with ReadyPackets. |
| Description | ReadyPackets helps authorized customers manage professional business-packet requests through the secure ReadyPackets Portal. Sign in through your organization’s approved browser flow, review the work and actions assigned to you, select currently listed packet options, and record an order request. The Portal confirms availability, quote, payment status, workflow, and delivery steps.\n\nYour account remains protected with device-bound credentials and native biometric re-entry where available. ReadyPackets does not collect payment-card information in the app. When payment or a custom quote is required, you complete the next step through the secure ReadyPackets Portal.\n\nKey capabilities:\n• Secure browser sign-in with multi-factor support\n• Authorized order, workflow, and device review\n• Listed packet selection and idempotent request submission\n• Portal-managed payment and quote handoff\n• Account deletion request and signed-device controls |
| Keywords | business packets, client portal, order workflow, secure documents, professional services |
| Support URL | Confirm a monitored ReadyPackets support URL before submission. |
| Marketing URL | Confirm the public ReadyPackets website URL before submission. |
| Privacy policy URL | Confirm the public, production privacy-policy URL before submission. |
| App Review notes | Provide a time-limited staging review account, test packet(s), exact browser sign-in/MFA steps, Universal Link behavior, and an explanation that payment is completed in the Portal rather than in the app. |

## Google Play listing copy — working draft

| Field | Proposed copy |
|---|---|
| App name | ReadyPackets |
| Short description | Securely manage authorized ReadyPackets orders, workflows, and packet requests. |
| Full description | ReadyPackets is the secure mobile companion for authorized customers of the ReadyPackets Portal.\n\nUse your approved account to review assigned work, see order progress, select currently listed packet options, and record a packet request. The ReadyPackets Portal remains in control of availability, pricing, payment, custom quotes, workflow activation, documents, and delivery status.\n\nReadyPackets uses native device security features, including protected credentials and biometric re-entry where supported. The app does not ask for or store payment-card details. If payment is required, the next step is completed through the secure ReadyPackets Portal.\n\nUse ReadyPackets to:\n• Sign in through the approved browser flow\n• Review authorized orders and current actions\n• Select listed packet options and submit a protected request\n• Follow secure Portal payment or custom-quote instructions\n• Review signed-in devices and request account deletion |
| Contact email | Use a monitored ReadyPackets support mailbox. |
| Contact website | Confirm the public ReadyPackets website URL before submission. |
| Privacy policy | Use the public, production privacy-policy URL after legal review. |
| Test instructions | Provide tester email/group access, the Play internal-test opt-in link, a staging account, and feedback contact details. Google Play notes that internal or closed testers need a shared link or opt-in route; they do not find these builds by searching. [3] |

Google Play metadata must be honest, relevant, and suitable for the intended audience. [4] The release owner must remove any capability from the above copy if it is not enabled in the submitted build or deployed staging environment.

## Privacy disclosures — release-owner worksheet

### Apple App Privacy

| Candidate data category | Linked to the user? | Purpose | Tracking? | Evidence and decision rule |
|---|---|---|---|---|
| Name, email, phone, other contact data | Usually yes | App functionality, account management, customer support | No | Declare only fields actually transmitted or retained by the release. |
| User/account identifier | Yes | App functionality, security, fraud prevention | No | Customer/account reference is returned by the Portal and tied to authorization. |
| Device identifier / installation ID | Yes | App functionality, security, device-session revocation | No | Use the release’s actual installation identifier behavior; do not characterize it as advertising ID. |
| Purchases or order information | Yes | App functionality | No | Declare order/request history if retained by the Portal; do **not** declare payment-card data when card entry happens outside the app and the developer does not access it. [1] |
| Emails, messages, documents, other user content | Usually yes | App functionality, customer support | No | Declare applicable content types when messages/uploads are enabled. For generic free-form content, use the relevant user-content classification rather than inferring every possible subject matter. [1] |
| Audio data | Usually yes | App functionality | No | Declare only if audio-recording/upload functionality ships enabled. |
| Diagnostics | Depends on the configured service | App functionality | No | Declare only if diagnostics are enabled and retained; sanitize content and identifiers as defined by the release policy. |

**Proposed Apple answers subject to verification:** data is not used for tracking; the application has no advertising SDK or hosted analytics service; payment-card data is not collected by the native application; data in transit must be encrypted; and users can request account deletion through the supported application/Portal route. Apple defines tracking as linking app data with third-party data for targeted advertising or sharing with a data broker; the described ReadyPackets release does neither. [1]

### Google Play Data Safety

| Play Console question | Proposed response subject to release verification | Release-owner evidence |
|---|---|---|
| Does the app collect or share required user data? | **Yes**, if authenticated account data, device installation data, orders, messages, documents, uploads, or diagnostics are transmitted and retained. | `DATA_DISCLOSURE_MAP.md`, API inventory, enabled SDK inventory, and server retention rules. |
| Is data encrypted in transit? | **Yes**, only when the production API is served over verified HTTPS/TLS and all configured data paths enforce it. | Production endpoint and proxy/TLS verification. |
| Is there a deletion request mechanism? | **Yes**, when the Portal’s account-deletion request route and public policy are enabled. | Test the in-app request and the public deletion/support route before submission. |
| Is data shared with third parties? | **No** for advertising/analytics under the current design. **Reassess** APNs/FCM, payment, SSO, email, crash reporting, storage, or any new SDK against Google’s definition before submission. | Release dependency inventory and production configuration. |
| Does the app collect payment-card information? | **No** under the current mobile design: card entry is not performed in the app. | Confirm the final navigation never embeds or receives a card-entry form. |

All Google Play developers are responsible for accurate Data Safety declarations; Google instructs developers to include applicable third-party libraries and SDKs in that assessment. [2]

## Store-submission evidence package

| Evidence | Owner | Required before submission |
|---|---|---|
| Signed build hash and source tag | Release owner | Yes |
| Dependency / SDK inventory | Engineering | Yes |
| Current privacy policy and deletion URL | Legal / privacy owner | Yes |
| App Privacy and Data Safety screenshots/export | Release owner | Yes |
| Staging review account and packet workflow | Product / support | Yes |
| TestFlight and Play internal-test results | QA owner | Yes |
| Native accessibility and deep-link test record | QA owner | Yes |

## References

[1]: https://developer.apple.com/app-store/app-privacy-details/ "Apple Developer — App privacy details on the App Store"
[2]: https://support.google.com/googleplay/android-developer/answer/10787469?hl=en "Google Play Console Help — Provide information for Google Play’s Data safety section"
[3]: https://support.google.com/googleplay/android-developer/answer/9845334?hl=en "Google Play Console Help — Set up an open, closed, or internal test"
[4]: https://support.google.com/googleplay/android-developer/answer/9898842?hl=en "Google Play Console Help — Metadata"
