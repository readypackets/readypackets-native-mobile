/**
 * Secure Editorial Console — the device is the working surface, not decoration.
 * This page is a safe local-data demonstration; it has no Portal/API integration.
 */
import { useState, type ReactNode } from "react";
import {
  Bell,
  ChevronRight,
  CircleHelp,
  FileText,
  Home as HomeIcon,
  LockKeyhole,
  MessageSquareText,
  PackageCheck,
  Search,
  ShieldCheck,
  Smartphone,
  UserRound,
  X,
} from "lucide-react";

type Screen = "welcome" | "signin" | "home" | "orders" | "detail" | "messages" | "alerts" | "profile";
type Order = { id: string; title: string; stage: string; progress: number; due: string; attention?: boolean };

const assetRoot = import.meta.env.VITE_SELF_HOSTED_ASSETS === "true" ? "/assets" : "/preview-assets";
const assets = {
  logo: `${assetRoot}/readypackets-packet-mark.png`,
  hero: `${assetRoot}/readypackets-mobile-hero-environment.jpg`,
  packet: `${assetRoot}/readypackets-packet-detail.jpg`,
  secure: `${assetRoot}/readypackets-secure-link-art.jpg`,
};

const orders: Order[] = [
  { id: "RP-2026-0147", title: "Leadership Strategy Packet", stage: "Reviewing your source materials", progress: 64, due: "Due Aug 29", attention: true },
  { id: "RP-2026-0129", title: "Operational Readiness Packet", stage: "Final presentation review", progress: 88, due: "Due Aug 25" },
  { id: "RP-2026-0096", title: "Executive Brand Packet", stage: "Delivered", progress: 100, due: "Delivered Aug 11" },
];

function Mark({ compact = false }: { compact?: boolean }) {
  return <img className={compact ? "brand-mark brand-mark--compact" : "brand-mark"} src={assets.logo} alt="ReadyPackets packet mark" />;
}

function Progress({ value }: { value: number }) {
  return <span className="progress-track"><i style={{ width: `${value}%` }} /></span>;
}

function OrderCard({ order, onOpen }: { order: Order; onOpen: () => void }) {
  return (
    <button className="order-card" onClick={onOpen} aria-label={`Open ${order.title}`}>
      <span className="order-card__head">
        <span><strong>{order.title}</strong><small>{order.stage}</small></span>
        <em className={order.attention ? "badge badge--amber" : "badge"}>{order.progress === 100 ? "Complete" : "In progress"}</em>
      </span>
      <Progress value={order.progress} />
      <span className="order-card__footer"><small>{order.progress}% complete</small><small>{order.due}</small></span>
      {order.attention && <span className="attention">Action needed</span>}
    </button>
  );
}

function Phone() {
  const [screen, setScreen] = useState<Screen>("welcome");
  const [selected, setSelected] = useState<Order>(orders[0]);
  const [query, setQuery] = useState("");
  const [showDelete, setShowDelete] = useState(false);
  const [phrase, setPhrase] = useState("");
  const filtered = orders.filter((order) => `${order.title} ${order.id}`.toLowerCase().includes(query.toLowerCase()));
  const activeLabel = screen === "welcome" || screen === "signin" ? "Secure entry" : screen === "detail" ? "Order detail" : screen[0].toUpperCase() + screen.slice(1);
  const openOrder = (order: Order) => { setSelected(order); setScreen("detail"); };
  const go = (next: Screen) => { setShowDelete(false); setScreen(next); };

  const nav = [
    ["home", "Home", HomeIcon],
    ["orders", "Orders", PackageCheck],
    ["messages", "Messages", MessageSquareText],
    ["alerts", "Alerts", Bell],
    ["profile", "Profile", UserRound],
  ] as const;

  return (
    <div className="phone-wrap">
      <div className={`phone-frame ${screen === "welcome" || screen === "signin" ? "phone-frame--dark" : ""}`}>
        <div className="phone-island" />
        <div className="phone-screen">
          <div className="phone-status"><span>9:41</span><span>●●● &nbsp; ▰▰▰</span></div>
          {screen === "welcome" && (
            <section className="auth-screen">
              <Mark /><p className="eyebrow">Interactive experience preview</p><h2>ReadyPackets</h2><p className="auth-tagline">Your Business, Professionally Packeted</p>
              <p>Securely manage authorized orders, workflow activity, documents, and support.</p>
              <button className="button button--primary" onClick={() => go("signin")}>Sign in securely <ChevronRight size={16} /></button>
              <small>ReadyPackets never asks you to enter your password in this application.</small>
            </section>
          )}
          {screen === "signin" && (
            <section className="auth-screen">
              <Mark /><p className="eyebrow">System browser return</p><h2>Secure sign-in</h2><p>Your Portal sign-in would continue in the secure system browser. This demonstration returns a representative signed-in workspace.</p>
              <button className="button button--primary" onClick={() => go("home")}>Continue to demo workspace <ChevronRight size={16} /></button>
              <small>No credentials are requested or stored in this demo.</small>
            </section>
          )}
          {!(["welcome", "signin"] as Screen[]).includes(screen) && (
            <>
              <header className="phone-header"><span className="phone-wordmark"><span className="micro-mark" />ReadyPackets</span><span className="avatar">AR</span></header>
              <main className="phone-content">
                {screen === "home" && <>
                  <p className="phone-overline">Private client workspace</p><h2>Welcome, Alex</h2><p className="muted">Your ReadyPackets work at a glance.</p>
                  <div className="metrics"><div><b>3</b><span>Orders</span></div><div><b>1</b><span>Needs attention</span></div></div>
                  <h3>Current work</h3>{orders.slice(0, 2).map((order) => <OrderCard key={order.id} order={order} onOpen={() => openOrder(order)} />)}
                </>}
                {screen === "orders" && <>
                  <p className="phone-overline">Client workspace</p><h2>Orders</h2>
                  <label className="search-box"><Search size={15} /><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Filter by order or packet" /></label>
                  {filtered.length ? filtered.map((order) => <OrderCard key={order.id} order={order} onOpen={() => openOrder(order)} />) : <p className="empty-text">No orders match that search.</p>}
                </>}
                {screen === "detail" && <>
                  <button className="back-link" onClick={() => go("orders")}>← Back to orders</button>
                  <section className="detail-card"><h2>{selected.title}</h2><p>{selected.id} · {selected.progress === 100 ? "Complete" : "In progress"}</p><Progress value={selected.progress} /><small>{selected.progress}% complete · {selected.due}</small></section>
                  <h3>Workflow status</h3>
                  {["Order confirmed", "Materials received", selected.stage, "Final delivery"].map((step, index) => <div className={`timeline-row ${index === 3 ? "timeline-row--muted" : ""}`} key={step}><i /><span><b>{step}</b><small>{index === 0 ? "Your scope and packet selection are recorded." : index === 1 ? "Authorized source materials are available to the ReadyPackets team." : index === 2 ? "Current server-authorized workflow stage." : "Approved completed deliverables will appear here."}</small></span></div>)}
                  <h3>Files and audio</h3><p className="muted">Files or recordings are accepted only when a server-authorized workflow step requests them.</p>
                  {selected.attention && <aside className="callout"><b>Confirmation needed.</b>Your team has a decision waiting in the secure Portal workflow.</aside>}
                </>}
                {screen === "messages" && <EmptyState icon={<MessageSquareText />} title="Messages" body="Your secure message inbox will appear here when its server contract is released." />}
                {screen === "alerts" && <EmptyState icon={<Bell />} title="Notifications" body="Your notification inbox will appear here when device registration is enabled." />}
                {screen === "profile" && <>
                  <p className="phone-overline">Client settings</p><h2>Profile</h2><section className="profile-card"><b>Alex Rivera</b><small>alex.rivera@example.com</small><em>Two-factor authentication enabled</em></section>
                  <h3>Your devices</h3><section className="device-list"><div><span><b>Current Android device</b><small>Android · v1.0.0 · Active</small></span><em>This device</em></div><div><span><b>iPhone</b><small>iOS · v1.0.0 · Active</small></span><em>Active</em></div></section>
                  <button className="danger-button" onClick={() => setShowDelete(true)}>Request account deletion</button><button className="signout-button" onClick={() => go("welcome")}>Sign out</button>
                </>}
              </main>
              <nav className="phone-nav" aria-label="Demo application navigation">{nav.map(([id, label, Icon]) => <button key={id} className={(screen === id || screen === "detail" && id === "orders") ? "is-active" : ""} onClick={() => go(id)}><Icon size={16} /><span>{label}</span></button>)}</nav>
            </>
          )}
          {showDelete && <section className="delete-sheet" role="dialog" aria-modal="true" aria-labelledby="delete-title"><button className="sheet-close" onClick={() => setShowDelete(false)} aria-label="Close deletion confirmation"><X size={17} /></button><p className="eyebrow">Account control</p><h3 id="delete-title">Request account deletion</h3><p>This immediately deactivates your account. Completed engagement records may be retained where the Privacy Policy requires it.</p><input value={phrase} onChange={(event) => setPhrase(event.target.value)} placeholder="Type DELETE MY ACCOUNT" aria-label="Deletion confirmation phrase" /><div><button onClick={() => setShowDelete(false)}>Cancel</button><button className="delete-confirm" disabled={phrase !== "DELETE MY ACCOUNT"} onClick={() => setShowDelete(false)}>Request deletion</button></div></section>}
        </div>
      </div>
      <p className="screen-label"><span /> {activeLabel}</p>
    </div>
  );
}

function EmptyState({ icon, title, body }: { icon: ReactNode; title: string; body: string }) {
  return <section className="empty-state"><span>{icon}</span><h2>{title}</h2><p>{body}</p></section>;
}

export default function Home() {
  return (
    <div className="site-shell">
      <header className="site-header"><a href="#top" className="site-brand"><Mark compact /><span>ReadyPackets</span></a><nav><a href="#experience">Experience</a><a href="#testing">Testing routes</a><a href="#handoff">Self-hosting</a></nav><span className="header-status"><span /> Local data only</span></header>
      <main id="top">
        <section className="stage" id="experience" style={{ backgroundImage: `linear-gradient(90deg, rgba(5,17,29,.96), rgba(5,17,29,.75) 50%, rgba(5,17,29,.92)), url(${assets.hero})` }}>
          <div className="stage-grid">
            <article className="stage-brief"><p className="eyebrow">Interactive product preview</p><h1>ReadyPackets,<br />in your hands.</h1><p className="stage-lede">Review the mobile workspace before connecting live services. This permanent demonstration uses representative local data; it does not sign into the Portal or store personal information.</p><div className="trust-list"><p><span /> <b>Native-aligned navigation.</b> Orders, messages, alerts, and Profile match the delivered client structure.</p><p><span /> <b>Server authority preserved.</b> Work status, payments, files, and access remain Portal-controlled in production.</p><p><span /> <b>Safe to explore.</b> Use the simulated sign-in, workflow detail, devices, and guarded deletion flow.</p></div><span className="data-stamp">Local representative data · not a production account</span></article>
            <Phone />
            <aside className="stage-controls"><p className="eyebrow">Demo controls</p><h2>Explore before connecting production services.</h2><p>The visual demonstration is safe to use immediately. It represents native mobile flows without calling ReadyPackets, storing a browser session, or collecting customer data.</p><ol><li><b>01 — Secure entry</b><span>Simulate a verified system-browser return, never a password field.</span></li><li><b>02 — Workflow clarity</b><span>Open an order to inspect its task-oriented status timeline.</span></li><li><b>03 — Safety guard</b><span>Visit Profile to see the typed confirmation required for account deletion.</span></li></ol><a className="text-link" href="#testing">Compare test routes <ChevronRight size={15} /></a></aside>
          </div>
        </section>
        <section className="proof-strip"><p><ShieldCheck /> Offline by design</p><span /> <p><LockKeyhole /> No Portal account connection</p><span /> <p><CircleHelp /> Clearly labeled representative data</p></section>
        <section className="testing-section" id="testing"><div className="section-heading"><p className="eyebrow">Choose the right review path</p><h2>One experience, three levels of validation.</h2><p>Use the website for a visual walkthrough, the offline APK for touch-based Android review, and the native client with a test Portal when authentication and server-authorized workflows are ready.</p></div><div className="route-grid"><article><span className="route-label">Review surface</span><span className="route-number">01</span><Smartphone /><h3>Interactive website</h3><p>Explore the permanent local-data preview directly in a browser.</p><b>Validation coverage</b><ul><li>Information hierarchy</li><li>Representative navigation</li><li>Deletion confirmation UX</li></ul></article><article><span className="route-label">Device surface</span><span className="route-number">02</span><PackageCheck /><h3>Offline Android demo</h3><p>Use the separately packaged debug APK for a native-touch UI review on Android.</p><b>Validation coverage</b><ul><li>Physical-device layout</li><li>Touch navigation</li><li>Offline screen behavior</li></ul></article><article><span className="route-label">Integration surface</span><span className="route-number">03</span><LockKeyhole /><h3>Portal-integrated native client</h3><p>Run signed iOS and Android builds against a non-production ReadyPackets test environment.</p><b>Validation coverage</b><ul><li>OAuth and app links</li><li>Token rotation & device revocation</li><li>Authorized customer data</li></ul></article></div></section>
        <section className="feature-section"><div className="feature-image"><img src={assets.packet} alt="A precisely aligned stack of unbranded document folders" /></div><article><p className="eyebrow">Mobile work, carefully bounded</p><h2>Each screen communicates what the customer can review—and what remains server-controlled.</h2><p>The mobile client is designed to expose clear task status and safe account controls without making the device the system of record. The permanent website makes those boundaries visible before a test environment is connected.</p><ul className="check-list"><li><CheckIcon /> Task-oriented order detail instead of raw portal records</li><li><CheckIcon /> System-browser sign-in pattern, not an embedded password form</li><li><CheckIcon /> A typed confirmation before a destructive account request</li></ul></article></section>
        <section className="handoff-section" id="handoff"><div><p className="eyebrow">Self-hosting handoff</p><h2>Deploy the preview wherever you control the site.</h2><p>This is a static React site with representative local data. It needs no database, authentication provider, API key, customer account, or hosted service to render the demonstration.</p><a className="button button--dark" href="#deployment-note">Read deployment notes <FileText size={16} /></a></div><div className="handoff-art"><span>Static delivery path</span><img src={assets.secure} alt="Abstract gold route line reaching a teal confirmation point" /></div></section>
        <section className="deployment-note" id="deployment-note"><p className="eyebrow">Deployment note</p><h2>Publish the built static files behind your own HTTPS domain.</h2><p>Run the project build, deploy the generated static output to your chosen self-hosted web server or static host, and configure your own domain. The site has no runtime API dependency. Replace the generated asset URLs with files served from your own static asset path before external hosting if you require complete asset isolation.</p></section>
      </main>
      <footer><a href="#top" className="site-brand"><Mark compact /><span>ReadyPackets</span></a><p>Permanent interactive mobile experience preview · local representative data only</p></footer>
    </div>
  );
}

function CheckIcon() { return <span className="check-icon">✓</span>; }
