# Redacted Session Transcript — Staging, Device Artifact, and Payment Experience

**Date:** 2026-08-27

**Redaction standard:** This audit record excludes access tokens, passwords, encryption keys, signing material, customer data, private device identifiers, and provider credentials.

## User request

> “Please configure the staging portal environment so I can thoroughly test the real customer permissions and workflow stages.”

> “Provide the direct download link for the Android debug APK so I can test the audio recorder and offline documents on my physical device.”

> “Let’s refine the web portal’s invoice view and checkout process to ensure a smoother user experience without handling credit card data.”

## Implementation response

An isolated, self-hosted Portal staging package was added with a separate Docker Compose project, loopback port, database volume, file-storage volume, hostname, OAuth callback, encryption keys, email destination, and test-mode payment credentials. The operator runbook defines the customer-role and workflow-state verification steps. A live staging deployment was intentionally not performed because no staging server, DNS record, TLS material, protected environment file, or test-mode provider configuration was supplied in the task.

The Portal invoice and checkout customer screens were refined to make confirmed payment evidence, secure Stripe-hosted card entry, return-to-Portal behavior, and webhook-authoritative payment activation explicit. The Android debug artifact was rebuilt/verified from the customer app source and accompanied by physical-device instructions for microphone, encrypted offline-document, hosted checkout, and notification testing.

## Validation record

The Portal static type check, focused six-case mobile-boundary regression suite, and production build passed. The Android debug APK checksum passed. The self-hosted staging Compose runtime must be validated on the actual host because the sandbox has no Docker runtime. No card data, test customer data, secret, or provider credential was handled or committed.
