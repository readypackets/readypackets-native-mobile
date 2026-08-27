# Android Customer App — Physical-Device Test Guide

## Purpose

The ReadyPackets Android artifact is a **debug build for authorized testing**. It supports the native customer workflows, including microphone capture, encrypted offline document caching, Portal-hosted payment handoff, and authenticated customer permissions. It is not signed for Google Play distribution and must not be shared outside the approved test group.

## Install the current debug build

Download the artifact only from the link supplied with the release message. On the test device, permit the browser or file manager to install apps from that source for this one installation, then open **ReadyPackets Debug**. You may revoke that Android setting immediately after installation.

For USB installation from a trusted computer, verify the supplied SHA-256 file and use:

```bash
adb install -r ReadyPackets-Customer-Staging-Android-debug.apk
```

The current downloadable artifact uses non-production placeholder endpoints. It is suitable for verifying the installed native shell, native permission prompts, and local runtime behavior; it will not authenticate against a real Portal until a staging-configured build is produced.

## Build for the staging Portal

After the staging hostname and verified Android App Link are available, create a fresh debug artifact from the native repository. Substitute only the staging values you control; do not use production URLs or secrets.

```bash
cd android
ANDROID_HOME=/path/to/android-sdk \
JAVA_HOME=/path/to/java-17 \
./gradlew clean assembleDebug \
  -PPORTAL_BASE_URL=https://staging.portal.example.com \
  -POAUTH_REDIRECT_URI=https://staging.mobile.example.com/auth/callback
```

Install the resulting `app/build/outputs/apk/debug/app-debug.apk` only on approved test devices. Ensure the same callback is listed in the Portal staging environment and its Android App Link association file is published before sign-in testing.

## Customer acceptance sequence

Use a dedicated staging customer—never a production account—for each permission state described in `deploy/staging/STAGING_RUNBOOK.md` in the Portal repository. Confirm that a closed-stage customer cannot upload, that a permitted stage accepts an authorized response, and that each customer sees only their own order, invoice, file, message, ticket, workspace, and referral data.

### Audio test

Allow the microphone only when Android asks during a workflow stage that permits recording. Record a short response, stop it, review its local title, and upload it through the active workflow. The app produces mono AAC-LC audio in an MPEG-4 `.m4a` container at 44.1 kHz and 96 kbps. Verify the uploaded file’s detected metadata, duration, and customer access from the Portal; then decline microphone permission and confirm the app remains usable for non-audio work.

### Offline document test

While connected, open an authorized customer document and select **Keep offline**. Disconnect the device, open the same document, and confirm it remains available. The test confirms that the encrypted app-private cache works only for a previously authorized document. Sign out, reopen the application, and confirm the offline copy can no longer be opened. Do not use screenshots or shared-storage exports as evidence of secure deletion.

### Payment and notifications

Initiate a test-mode invoice payment and confirm that the app opens the system browser’s verified staging checkout URL. Enter payment information only in the provider’s test-mode hosted page; a return to the app is not payment confirmation. Verify the Portal webhook, order status, and invoice before marking the case passed.

With staging APNs/FCM provider configuration active, sign in, allow notifications, and confirm one non-sensitive staging notification arrives only on the registered device. Revoke notification permission and verify updates continue through the in-app inbox.

## Evidence and cleanup

Record device model, Android version, build SHA-256, customer role, workflow stage, test result, and any Portal audit event identifier in the staging test record. At the end, sign out, uninstall the debug app, revoke any temporary unknown-app installation permission, and retire the staging customer/session according to the Portal retention policy.
