# ReadyPackets Mobile Experience Preview

This repository contains the **permanent, self-hostable static website** for the ReadyPackets mobile experience preview. It is an interactive browser demonstration of the mobile customer flows, using local representative data only.

The website does **not** implement Portal login, customer data, authentication, payments, API calls, analytics, cookies, form submissions, or deletion requests. The device screens are intentionally non-production demonstrations of the native iOS and Android customer experience.

## Local development

```bash
pnpm install
pnpm dev
```

The normal development mode references the project-preview copies of the visual assets. It is suitable for local design review and does not call the ReadyPackets Portal.

## Isolated self-hosted build

Follow [`DEPLOYMENT.md`](DEPLOYMENT.md) to copy the supplied image assets into `client/public/assets/` and build with `VITE_SELF_HOSTED_ASSETS=true`. The generated `dist/public/` folder can then be hosted on any HTTPS static web server you control.

```bash
VITE_SELF_HOSTED_ASSETS=true pnpm build
```

The project includes an Nginx baseline at [`deploy/nginx.conf`](deploy/nginx.conf). It is a starting point only; replace the hostname and TLS paths before deployment.

## Site boundaries

| Item | Status |
|---|---|
| Visual mobile navigation demo | Included |
| Local representative order data | Included |
| ReadyPackets Portal API | Not included |
| Customer authentication and OAuth | Not included |
| Account deletion operation | Not included; the typed interaction is visual only |
| Manus runtime dependency | Removed from the handoff source |

## Assets

The self-hosting asset package contains the ReadyPackets packet mark, hero environment, document-material image, and static delivery-path image. See `DEPLOYMENT.md` for required filenames and asset placement.
