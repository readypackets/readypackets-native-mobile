# Mobile CI/CD Setup Guide

ReadyPackets uses two complementary workflows. `native-mobile.yml` validates Android debug tests and an unsigned iOS simulator build on changes to `main` and pull requests. `mobile-release-candidate.yml` creates signed staging artifacts only when a release owner starts it with `signed=true` and the protected `mobile-staging` environment approves the job.

GitHub environments can require approval and restrict when environment secrets become available to a workflow job. [1] The proposed design therefore keeps signing material and staging endpoint values out of source control and out of normal pull-request validation. Workflow artifacts are retained for a bounded period and can be downloaded from the run for handoff to TestFlight or Play Console. [2]

## Workflow model

| Workflow | Trigger | Output | Store action |
|---|---|---|---|
| `native-mobile.yml` | Push to `main`, pull request, or manual run | Android debug test result; unsigned iOS simulator build result | None |
| `mobile-release-candidate.yml` | Manual dispatch with `signed=true` after environment approval | Signed Android `.aab`; signed iOS `.xcarchive` and `.ipa` | None; artifact upload only |
| Release owner procedure | Human review of artifacts and test evidence | TestFlight upload or Play Internal Testing upload | Manual, accountable, and reversible |

> The workflow intentionally does **not** publish to TestFlight, Google Play, or production automatically. Store submission, privacy declarations, review access, rollout percentage, and rollback decisions require an accountable release owner.

## One-time GitHub configuration

Create a **`mobile-staging`** environment in `readypackets/readypackets-native-mobile`. Restrict deployments to protected `main` or version-tag references, require one or more release-owner approvals, and prevent self-approval where your GitHub plan supports it. [1]

| Environment variable | Purpose | Example format |
|---|---|---|
| `STAGING_PORTAL_BASE_URL` | Non-secret HTTPS Portal base URL used in candidate builds | `https://staging.readypackets.example` |
| `ANDROID_STAGING_REDIRECT_URI` | Registered Android App Link OAuth redirect | `https://mobile-staging.readypackets.example/auth/callback` |
| `IOS_STAGING_REDIRECT_URI` | Registered iOS Universal Link OAuth redirect | `https://mobile-staging.readypackets.example/auth/callback` |

| Environment secret | Purpose | Handling requirement |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded Android release keystore | Generate and retain the source keystore under controlled, offline backup; never commit it. |
| `ANDROID_KEYSTORE_PASSWORD` | Android keystore password | Use a unique high-entropy value. |
| `ANDROID_KEY_ALIAS` | Android signing key alias | Treat as sensitive operational metadata. |
| `ANDROID_KEY_PASSWORD` | Android signing key password | Use a unique high-entropy value. |
| `APPLE_TEAM_ID` | Apple Developer Team identifier | Release configuration value. |
| `APPLE_CERTIFICATE_BASE64` | Base64-encoded distribution certificate `.p12` | Keep the original certificate and password in controlled backup. |
| `APPLE_CERTIFICATE_PASSWORD` | Certificate import password | Do not store in the repository or workflow text. |
| `APPLE_PROVISIONING_PROFILE_BASE64` | Matching App Store provisioning profile | Regenerate when certificate, bundle ID, or capability changes. |
| `KEYCHAIN_PASSWORD` | Ephemeral CI keychain password | Unique random value; use only in the protected environment. |

GitHub recommends placing secrets in the `secrets` context and avoiding command-line propagation where possible; a missing secret resolves to an empty string, so the workflow fails fast before materializing signing files. [3]

## Android release-candidate procedure

The Android project targets API 36 and uses Gradle properties for non-secret Portal and OAuth endpoint values. Configure the Android App Link asset statement on the staging domain, then run **Actions → Native mobile release candidate → signed=true**. The job validates debug unit tests, writes the decoded signing key only to the ephemeral runner directory, builds `bundleRelease`, and uploads a 14-day App Bundle artifact.

Download the `.aab`, verify the source commit and artifact digest, then upload it manually to **Google Play Internal Testing**. Google Play recommends internal testing before wider release and supports internal cohorts up to 100 testers. [4] Keep the internal tester list, opt-in URL, staging test account, test-packet checklist, support contact, Data Safety worksheet, and rollback decision in the release ticket.

## iOS release-candidate procedure

Configure the Apple App ID `com.readypackets.mobile`, associated-domain entitlement, registered Universal Link redirect URI, distribution certificate, and provisioning profile for the staging host. Run the same protected workflow with `signed=true`. The macOS runner creates an ephemeral keychain, imports the protected signing material, archives a Release build, exports an IPA, and uploads the archive and IPA as short-retention artifacts.

After verifying the artifact hash and staging configuration, upload the IPA/archive through the owner-approved TestFlight procedure. Apple describes TestFlight as the beta-distribution path for managing testers and feedback; builds are available to testers for up to 90 days. [5] Test on a physical device before inviting external testers: sign-in/MFA, Universal Link return, Keychain restoration, biometrics, order submission, custom quote, Portal payment handoff, logout, deletion request, VoiceOver, Dynamic Type, and network interruption must all be recorded.

## Release controls and rollback

| Control | Required practice |
|---|---|
| Source | Create a signed/tagged release from a reviewed, passing commit; record the commit SHA in the release ticket. |
| Secrets | Use environment secrets with approval gates; rotate compromised credentials immediately. Never place signing material in code, Git history, artifacts intended for public release, or chat. |
| Artifacts | Download only from the protected workflow run; validate the artifact digest and keep retention short. [2] |
| Portal compatibility | Deploy the matching Portal mobile API and confirmed OIDC/App Link configuration to staging before distributing a mobile candidate. |
| Privacy | Reconcile `STORE_LISTING_AND_PRIVACY_WORKSHEET.md` against the actual binary, enabled SDKs, public policy, and server behavior before each store submission. |
| Rollback | Pause the Play track or expire/remove the TestFlight build if a security, auth, payment-handoff, privacy, or crash threshold fails. Revoke affected device/session credentials in the Portal where appropriate. |

## References

[1]: https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment "GitHub Docs — Managing environments for deployment"
[2]: https://docs.github.com/en/actions/tutorials/store-and-share-data "GitHub Docs — Store and share data with workflow artifacts"
[3]: https://docs.github.com/actions/security-guides/using-secrets-in-github-actions "GitHub Docs — Using secrets in GitHub Actions"
[4]: https://support.google.com/googleplay/android-developer/answer/9845334?hl=en "Google Play Console Help — Set up an open, closed, or internal test"
[5]: https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/ "Apple Developer — TestFlight overview"
