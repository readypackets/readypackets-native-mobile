# ReadyPackets Mobile Customer-Parity Contract

The authoritative contract lives in the Portal repository at `docs/mobile-native/MOBILE_CUSTOMER_PARITY_CONTRACT.md`. The native projects consume the same versioned `/api/mobile/v1` customer-only contract and may not introduce independent authorization, pricing, workflow, storage, payment, moderation, or administrative logic.

The native implementation follows three rules: customer-facing journeys are usable in the app; high-friction security and payment activity opens the verified Portal in the system browser; all administration remains web-only.
