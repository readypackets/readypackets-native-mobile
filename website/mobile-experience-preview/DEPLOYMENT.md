# Self-Hosting ReadyPackets Mobile Experience Preview

This project is a **static React website** that demonstrates the ReadyPackets mobile customer experience with representative local data. It has no database, authentication flow, customer account, API request, analytics SDK, or backend service requirement.

> The website is a visual and navigation demonstration only. It is not the ReadyPackets Portal, and it must not be presented as a live account workspace.

## Build the isolated production package

Copy the four visual assets delivered with this project into `client/public/assets/` before the production build. The expected filenames are listed below.

| Local destination | Required source asset |
|---|---|
| `client/public/assets/readypackets-packet-mark.png` | ReadyPackets packet mark |
| `client/public/assets/readypackets-mobile-hero-environment.jpg` | Dark product-stage background |
| `client/public/assets/readypackets-packet-detail.jpg` | Document-material image |
| `client/public/assets/readypackets-secure-link-art.jpg` | Static delivery-path image |

Run the following commands from the repository root after the assets are in place:

```bash
pnpm install --frozen-lockfile
VITE_SELF_HOSTED_ASSETS=true pnpm build
```

The deployable files are written to `dist/public/`. The `VITE_SELF_HOSTED_ASSETS=true` flag makes all website images resolve from `/assets/` on the host you control rather than from a development-preview asset URL.

## Serve through HTTPS

Publish the contents of `dist/public/` behind an HTTPS domain you control. An Nginx baseline is provided at [`deploy/nginx.conf`](deploy/nginx.conf). Replace the sample server name and TLS certificate paths before activation.

The configuration includes a single-page-application fallback, immutable caching for versioned bundle assets, basic response hardening, and a Content Security Policy that permits only same-origin assets plus the inline SVG favicon. Review and adapt it to your organization’s security standard before production use. Nginx documents the `try_files` behavior and response-header controls in its official reference. [1]

## Operational boundaries

| Item | Included in this website | Not included in this website |
|---|---|---|
| User data | Local representative names, orders, and workflow states embedded in the browser bundle | Portal records, customer files, payment data, user tokens, authentication state |
| Networking | Static HTML, CSS, JavaScript, and self-hosted image requests | APIs, analytics, telemetry, cookies, forms, OAuth, webhooks |
| Security purpose | Clear demo boundary labels and a non-functional deletion-confirmation interaction | Account deletion, sign-in, access control, authorization decisions |
| Hosting | Static assets behind your own HTTPS server | Manus hosting, runtime APIs, storage, analytics, or authentication services |

## Release verification

Before making the site public, complete the following checks.

1. Build with `VITE_SELF_HOSTED_ASSETS=true` and verify that the browser network panel has no requests to `/manus-storage/`, third-party fonts, analytics services, or APIs.
2. Test the secure-entry simulation, Orders search, order detail, tab navigation, sign-out, and typed deletion-confirmation guard on desktop and mobile widths.
3. Confirm the site copy still says **local representative data** and does not imply an active Portal login.
4. Validate the final response headers and HTTPS certificate on the deployed hostname.
5. Preserve the source, asset package, `SHA256SUMS.txt`, and release date with your normal change-control record.

## References

[1]: https://nginx.org/en/docs/http/ngx_http_core_module.html#try_files "Nginx `try_files` directive"
[2]: https://vite.dev/guide/build.html "Vite production build guide"
