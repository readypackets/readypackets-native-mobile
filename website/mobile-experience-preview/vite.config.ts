import { createReadStream, existsSync } from "node:fs";
import { extname, join } from "node:path";
import { fileURLToPath, URL } from "node:url";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const root = fileURLToPath(new URL("./client", import.meta.url));
const output = fileURLToPath(new URL("./dist/public", import.meta.url));
const previewAssets = "/home/ubuntu/webdev-static-assets";
const contentTypes: Record<string, string> = { ".jpg": "image/jpeg", ".png": "image/png", ".webp": "image/webp" };

const localPreviewAssets = {
  name: "local-preview-assets",
  configureServer(server: { middlewares: { use: (route: string, handler: (request: { url?: string }, response: { statusCode: number; setHeader: (name: string, value: string) => void; end: (value?: string) => void }) => void) => void } }) {
    server.middlewares.use("/preview-assets", (request, response) => {
      const name = (request.url ?? "").replace(/^\//, "");
      const asset = join(previewAssets, name);
      if (!name || name.includes("..") || !existsSync(asset)) { response.statusCode = 404; response.end("Asset not found"); return; }
      response.setHeader("Content-Type", contentTypes[extname(asset)] ?? "application/octet-stream");
      createReadStream(asset).pipe(response as never);
    });
  },
};

export default defineConfig({
  plugins: [react(), localPreviewAssets],
  root,
  resolve: { alias: { "@": fileURLToPath(new URL("./client/src", import.meta.url)) } },
  build: { outDir: output, emptyOutDir: true },
  server: { host: "0.0.0.0", port: 3000 },
});
