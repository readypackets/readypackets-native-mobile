/**
 * Secure Editorial Console — the device is the working surface, not decoration.
 * This page is a safe local-data demonstration; it has no Portal/API integration.
 */
import { useState, type ReactNode } from "react";
import {
  Bell,
  CheckCircle2,
  ChevronRight,
  CircleHelp,
  FileAudio,
  FileDown,
  FileText,
  FolderOpen,
  Home as HomeIcon,
  LockKeyhole,
  MessageSquareText,
  PackageCheck,
  Play,
  Plus,
  Search,
  ShieldCheck,
  Smartphone,
  UserRound,
  UsersRound,
  WalletCards,
  X,
} from "lucide-react";

type Screen = "welcome" | "signin" | "home" | "orders" | "detail" | "inbox" | "services" | "profile";
type Order = { id: string; title: string; stage: string; progress: number; due: string; attention?: boolean };
type DemoFile = { name: string; meta: string; audio?: boolean; downloaded?: boolean; delivery?: boolean };

const assetRoot = import.meta.env.VITE_SELF_HOSTED_ASSETS === "true" ? "/assets" : "/preview-assets";
const assets = {
  logo: `${assetRoot}/readypackets-packet-mark.png`,
  hero: `${assetRoot}/readypackets-mobile-hero-environment.jpg`,
  packet: `${assetRoot}/readypackets-packet-detail.jpg`,
  secure: `${assetRoot}/readypackets-secure-link-art.jpg`,
};

const orders: Order[] = [
  { id: "RP-2026-0147", title: "Leadership Strategy Packet", stage: "Materials requested", progress: 64, due: "Due Aug 29", attention: true },
  { id: "RP-2026-0129", title: "Operational Readiness Packet", stage: "Final presentation review", progress: 88, due: "Due Aug 25" },
  { id: "RP-2026-0096", title: "Executive Brand Packet", stage: "Delivered", progress: 100, due: "Delivered Aug 11" },
];

const starterFiles: DemoFile[] = [
  { name: "Leadership source brief.pdf", meta: "PDF · 1.8 MB · permitted in this stage", downloaded: true },
  { name: "Executive interview.m4a", meta: "AAC-LC · 02:14 · secure playback", audio: true },
  { name: "Presentation outline.pdf", meta: "PDF · delivered Aug 11", delivery: true },
];

const customerServices = [
  { title: "Support", body: "Create or reply to a ticket", icon: CircleHelp },
  { title: "Community", body: "Browse, post, reply, react", icon: UsersRound },
  { title: "Packet Collective", body: "Workspaces and collaboration", icon: FolderOpen },
  { title: "Referrals", body: "View code and progress", icon: PackageCheck },
  { title: "Knowledge", body: "Packets, FAQs and legal", icon: FileText },
  { title: "Account security", body: "Browser-protected account actions", icon: ShieldCheck },
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

function Notice({ children }: { children: ReactNode }) {
  return <aside className="notice" role="status"><CheckCircle2 size={14} />{children}</aside>;
}

function Phone() {
  const [screen, setScreen] = useState<Screen>("welcome");
  const [selected, setSelected] = useState<Order>(orders[0]);
  const [query, setQuery] = useState("");
  const [showDelete, setShowDelete] = useState(false);
  const [phrase, setPhrase] = useState("");
  const [files, setFiles] = useState<DemoFile[]>(starterFiles);
  const [recording, setRecording] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const [messages, setMessages] = useState(["Your source brief has been reviewed. The current workflow task is ready for your response.", "We have reserved your requested review window."]);
  const [draft, setDraft] = useState("");
  const [inboxTab, setInboxTab] = useState<"messages" | "updates">("messages");
  const [pushEnabled, setPushEnabled] = useState(false);
  const filtered = orders.filter((order) => `${order.title} ${order.id}`.toLowerCase().includes(query.toLowerCase()));
  const activeLabel = screen === "welcome" || screen === "signin" ? "Secure entry" : screen === "detail" ? "Order workspace" : screen[0].toUpperCase() + screen.slice(1);
  const openOrder = (order: Order) => { setSelected(order); setNotice(null); setScreen("detail"); };
  const go = (next: Screen) => { setNotice(null); setShowDelete(false); setScreen(next); };
  const show = (message: string) => setNotice(message);
  const sendMessage = () => {
    if (!draft.trim()) return;
    setMessages((current) => [draft.trim(), ...current]);
    setDraft("");
    show("Representative message sent. The live app submits it through the customer-only mobile API.");
  };
  const toggleRecord = () => {
    if (recording) {
      setRecording(false);
      setFiles((current) => [{ name: "Leadership response.m4a", meta: "AAC-LC · 00:18 · ready for secure upload", audio: true }, ...current]);
      show("Recording saved in this preview. Native apps record AAC-LC/M4A and upload only when the Portal authorizes the workflow stage.");
    } else {
      setRecording(true);
      show("Recording simulation started. This browser preview does not activate your microphone.");
    }
  };

  const nav = [
    ["home", "Home", HomeIcon],
    ["orders", "Orders", PackageCheck],
    ["inbox", "Inbox", MessageSquareText],
    ["services", "Explore", FolderOpen],
    ["profile", "Profile", UserRound],
  ] as const;

  return (
    <div className="phone-wrap">
      <div className="mobile-device-brief"><span className="micro-mark" /><span><b>ReadyPackets customer application</b><small>Interactive local-data preview</small></span></div>
      <div className={`phone-frame ${screen === "welcome" || screen === "signin" ? "phone-frame--dark" : ""}`}>
        <div className="phone-island" />
        <div className="phone-screen">
          <div className="phone-status"><span>9:41</span><span>●●● &nbsp; ▰▰▰</span></div>
          {screen === "welcome" && (
            <section className="auth-screen">
              <Mark /><p className="eyebrow">Interactive experience preview</p><h2>ReadyPackets</h2><p className="auth-tagline">Your Business, Professionally Packeted</p>
              <p>Explore documents, audio, workflow, invoices, support, community, and account controls in a safe representative workspace.</p>
              <button className="button button--primary" onClick={() => go("signin")}>Sign in securely <ChevronRight size={16} /></button>
              <small>ReadyPackets never asks for a Portal password inside this application.</small>
            </section>
          )}
          {screen === "signin" && (
            <section className="auth-screen">
              <Mark /><p className="eyebrow">System browser return</p><h2>Secure sign-in</h2><p>Your Portal sign-in and MFA would continue in the device browser. This safe demonstration then opens a representative customer workspace.</p>
              <button className="button button--primary" onClick={() => go("home")}>Continue to customer workspace <ChevronRight size={16} /></button>
              <small>No credentials are requested, retained, or transmitted by this preview.</small>
            </section>
          )}
          {!( ["welcome", "signin"] as Screen[]).includes(screen) && (
            <>
              <header className="phone-header"><span className="phone-wordmark"><span className="micro-mark" />ReadyPackets</span><span className="avatar">AR</span></header>
              <main className="phone-content">
                {screen === "home" && <>
                  <p className="phone-overline">Private client workspace</p><h2>Welcome, Alex</h2><p className="muted">Your authorized work at a glance.</p>
                  <div className="metrics"><div><b>3</b><span>Orders</span></div><div><b>1</b><span>Action needed</span></div></div>
                  <section className="home-action"><span><FolderOpen size={16} /><b>Document workspace</b><small>2 approved files are available for this device.</small></span><button onClick={() => go("detail")}>Open</button></section>
                  <section className="home-action"><span><Bell size={16} /><b>Customer updates</b><small>{pushEnabled ? "Device notifications enabled" : "Enable updates from Inbox"}</small></span><button onClick={() => go("inbox")}>Review</button></section>
                  <h3>Current work</h3>{orders.slice(0, 2).map((order) => <OrderCard key={order.id} order={order} onOpen={() => openOrder(order)} />)}
                </>}
                {screen === "orders" && <>
                  <p className="phone-overline">Client workspace</p><span className="title-row"><h2>Orders</h2><button className="icon-action" onClick={() => show("Order placement is represented in the native app by a server-authoritative catalog and idempotent submission.")} aria-label="Explain order placement"><Plus size={16} /></button></span>
                  <label className="search-box"><Search size={15} /><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="Filter by order or packet" /></label>
                  {filtered.length ? filtered.map((order) => <OrderCard key={order.id} order={order} onOpen={() => openOrder(order)} />) : <p className="empty-text">No orders match that search.</p>}
                </>}
                {screen === "detail" && <>
                  <button className="back-link" onClick={() => go("orders")}>← Back to orders</button>
                  <section className="detail-card"><h2>{selected.title}</h2><p>{selected.id} · {selected.progress === 100 ? "Complete" : "In progress"}</p><Progress value={selected.progress} /><small>{selected.progress}% complete · {selected.due}</small></section>
                  {notice && <Notice>{notice}</Notice>}
                  <h3>Current workflow</h3>
                  {[["Order confirmed", "Complete"], ["Materials requested", "Current customer action"], ["Review in progress", "ReadyPackets team"], ["Final delivery", "Released after approval"]].map(([step, note], index) => <div className={`timeline-row ${index > 1 ? "timeline-row--muted" : ""}`} key={step}><i /><span><b>{step}</b><small>{note}</small></span></div>)}
                  <section className="task-card"><p className="phone-overline">Action requested</p><b>Confirm the intake and attach supporting material.</b><p>Each action is available only when the Portal unlocks the current workflow stage.</p><div className="inline-actions"><button onClick={() => show("Document picker opened in the native app. This preview shows the safe workflow state only.")}>Add document</button><button className={recording ? "is-recording" : ""} onClick={toggleRecord}>{recording ? "Stop recording" : "Record audio"}</button><button onClick={() => show("Representative intake saved. Live entries are validated and submitted through the Portal.")}>Save intake</button></div></section>
                  <h3>Documents and recordings</h3><p className="muted">The app exposes only customer-authorized files. Downloads are private to the device and never copied to a shared web cache.</p>
                  {files.map((file) => <section className="file-card" key={file.name}><span className={`file-icon ${file.audio ? "file-icon--audio" : ""}`}>{file.audio ? <FileAudio size={16} /> : file.delivery ? <FileDown size={16} /> : <FileText size={16} />}</span><span><b>{file.name}</b><small>{file.meta}</small>{file.downloaded && <em>Representative offline workspace state</em>}</span><button onClick={() => show(file.audio ? "Audio playback opens from a protected, range-enabled Portal stream in the native app." : "Representative download saved for review. The live app applies device-private file controls.")}>{file.audio ? <Play size={13} /> : <FileDown size={13} />}</button></section>)}
                  <h3>Invoice and payment</h3><section className="payment-banner"><WalletCards size={16} /><span><b>Invoice RP-2026-0147</b><small>Payment information remains in the verified Portal checkout.</small></span><button onClick={() => show("The native app would open verified Portal-hosted checkout in the device browser. No card data reaches the app.")}>Pay in Portal</button></section>
                  <h3>Secure message</h3><label className="message-compose"><textarea value={draft} onChange={(event) => setDraft(event.target.value)} placeholder="Write a message to ReadyPackets" /><button onClick={sendMessage} disabled={!draft.trim()}>Send</button></label>
                </>}
                {screen === "inbox" && <>
                  <p className="phone-overline">Customer communications</p><h2>Inbox</h2><div className="work-tabs"><button className={inboxTab === "messages" ? "is-selected" : ""} onClick={() => setInboxTab("messages")}>Messages</button><button className={inboxTab === "updates" ? "is-selected" : ""} onClick={() => setInboxTab("updates")}>Updates</button></div>
                  {inboxTab === "messages" ? <><p className="muted">Secure, order-aware customer communication.</p>{messages.map((item, index) => <section className="message-card" key={`${item}-${index}`}><span className="avatar">RP</span><span><b>{index === 0 ? "ReadyPackets team" : "Customer workspace"}</b><small>{item}</small><em>Order RP-2026-0147 · now</em></span></section>)}</> : <><section className="notification-card"><Bell size={17} /><span><b>Device updates</b><small>{pushEnabled ? "This representative device is registered for eligible workflow and support updates." : "Device registration is off in this preview."}</small></span><button onClick={() => { setPushEnabled((value) => !value); show(!pushEnabled ? "Representative push registration enabled. Production uses APNs or FCM without embedding provider credentials." : "Representative push registration disabled for this device."); }}>{pushEnabled ? "Disable" : "Enable"}</button></section><section className="notification-card"><PackageCheck size={17} /><span><b>Workflow action</b><small>Source material is requested for Leadership Strategy Packet.</small></span></section><section className="notification-card"><CircleHelp size={17} /><span><b>Support update</b><small>Your support reply is ready to review.</small></span></section></>}
                </>}
                {screen === "services" && <>
                  <p className="phone-overline">Customer services</p><h2>Explore</h2><p className="muted">Customer capabilities from the Portal, designed for native use.</p>
                  <div className="service-grid">
                    {customerServices.map(({ title, body, icon: Icon }) => <button className="service-card" key={title} onClick={() => show(`${title} is available through the customer-only mobile API. This preview demonstrates the entry point without connecting a Portal account.`)}><Icon size={17} /><span><b>{title}</b><small>{body}</small></span><ChevronRight size={14} /></button>)}
                  </div>
                </>}
                {screen === "profile" && <>
                  <p className="phone-overline">Client settings</p><h2>Profile</h2><section className="profile-card"><b>Alex Rivera</b><small>alex.rivera@example.com</small><em>Two-factor authentication enabled</em></section>
                  <section className="security-card"><ShieldCheck size={16} /><span><b>Secure account controls</b><small>Password change, MFA enrollment, verification, recovery, and legal acceptance open in the verified Portal browser flow.</small></span><button onClick={() => show("The live app opens a verified Portal browser handoff for account-security actions.")}>Open</button></section>
                  <h3>Your devices</h3><section className="device-list"><div><span><b>Current device</b><small>Android or iOS · v1.0.0 · Active</small></span><em>This device</em></div><div><span><b>Registered mobile device</b><small>Protected browser sign-in · Active</small></span><em>Active</em></div></section>
                  <button className="danger-button" onClick={() => setShowDelete(true)}>Request account deletion</button><button className="signout-button" onClick={() => go("welcome")}>Sign out</button>
                </>}
              </main>
              <nav className="phone-nav" aria-label="Demo application navigation">{nav.map(([id, label, Icon]) => <button key={id} className={(screen === id || screen === "detail" && id === "orders") ? "is-active" : ""} onClick={() => go(id)}><Icon size={16} /><span>{label}</span></button>)}</nav>
            </>
          )}
          {showDelete && <section className="delete-sheet" role="dialog" aria-modal="true" aria-labelledby="delete-title"><button className="sheet-close" onClick={() => setShowDelete(false)} aria-label="Close deletion confirmation"><X size={17} /></button><p className="eyebrow">Account control</p><h3 id="delete-title">Request account deletion</h3><p>This immediately deactivates your account. Completed engagement records may be retained where the Privacy Policy requires it.</p><input value={phrase} onChange={(event) => setPhrase(event.target.value)} placeholder="Type DELETE MY ACCOUNT" aria-label="Deletion confirmation phrase" /><div><button onClick={() => setShowDelete(false)}>Cancel</button><button className="delete-confirm" disabled={phrase !== "DELETE MY ACCOUNT"} onClick={() => { setShowDelete(false); show("Representative deletion request confirmed. The live app submits the request through the protected Portal account flow."); }}>Request deletion</button></div></section>}
        </div>
      </div>
      <p className="screen-label"><span /> {activeLabel}</p>
    </div>
  );
}

export default function Home() {
  return (
    <div className="site-shell">
      <header className="site-header"><a href="#top" className="site-brand"><Mark compact /><span>ReadyPackets</span></a><nav><a href="#experience">Experience</a><a href="#testing">Testing routes</a><a href="#handoff">Self-hosting</a></nav><span className="header-status"><span /> Local data only</span></header>
      <main id="top">
        <section className="stage" id="experience" style={{ backgroundImage: `linear-gradient(90deg, rgba(5,17,29,.96), rgba(5,17,29,.75) 50%, rgba(5,17,29,.92)), url(${assets.hero})` }}>
          <div className="stage-grid">
            <article className="stage-brief"><p className="eyebrow">Customer application preview</p><h1>ReadyPackets,<br />wherever work happens.</h1><p className="stage-lede">Walk through the completed customer workspace: authorized documents, recorded responses, workflow actions, payment handoff, messages, updates, support, community, and account controls. This permanent preview uses representative local data only.</p><div className="trust-list"><p><span /> <b>Customer-complete, administration separate.</b> Customers can use the native app or Portal; staff work remains web-only.</p><p><span /> <b>Secure device boundaries.</b> The real app uses Portal-issued permissions, protected files, system-browser identity, and hosted checkout.</p><p><span /> <b>Safe to explore.</b> Interact with files, audio state, customer updates, and account controls without contacting production systems.</p></div><span className="data-stamp">Representative local data · not a production account</span></article>
            <Phone />
            <aside className="stage-controls"><p className="eyebrow">Demo controls</p><h2>Test the full customer journey before connecting a Portal.</h2><p>Use the device view to explore the native application’s customer paths. Every button is clearly labelled as a local demonstration when it would normally call an authenticated service or device capability.</p><ol><li><b>01 — Work with an order</b><span>Open an active order, inspect the workflow, add a document state, or simulate an AAC/M4A recording.</span></li><li><b>02 — Review secure handoffs</b><span>Try the invoice, Portal payment, browser-protected account controls, messages, and notification registration states.</span></li><li><b>03 — Explore customer services</b><span>Visit Support, Community, Packet Collective, Referrals, Knowledge, and Account Security entry points.</span></li></ol><a className="text-link" href="#testing">Compare test routes <ChevronRight size={15} /></a></aside>
          </div>
        </section>
        <section className="proof-strip"><p><ShieldCheck /> Customer-only boundary</p><span /> <p><LockKeyhole /> No Portal account connection</p><span /> <p><CircleHelp /> Representative local data</p></section>
        <section className="testing-section" id="testing"><div className="section-heading"><p className="eyebrow">Choose the right review path</p><h2>One customer experience, three levels of validation.</h2><p>Use the website for a safe functional walkthrough, the Android test build for touch and device review, and Portal-integrated native builds for authenticated customer services and provider-enabled testing.</p></div><div className="route-grid"><article><span className="route-label">Review surface</span><span className="route-number">01</span><Smartphone /><h3>Interactive website</h3><p>Explore customer order, file, audio, workflow, inbox, service, and account paths with only representative data.</p><b>Validation coverage</b><ul><li>Information hierarchy</li><li>Customer journey navigation</li><li>Representative safety states</li></ul></article><article><span className="route-label">Device surface</span><span className="route-number">02</span><PackageCheck /><h3>Android customer build</h3><p>Use a native debug build for touch, recorder, private cache, download, browser-handoff, and permission testing.</p><b>Validation coverage</b><ul><li>Physical-device workflow</li><li>AAC/M4A recorder path</li><li>Device-private files</li></ul></article><article><span className="route-label">Integration surface</span><span className="route-number">03</span><LockKeyhole /><h3>Portal-integrated clients</h3><p>Run signed iOS and Android against staging to validate actual data, workflow rights, payment, and notifications.</p><b>Validation coverage</b><ul><li>OAuth and app links</li><li>Customer permissions</li><li>APNs / FCM registration</li></ul></article></div></section>
        <section className="feature-section"><div className="feature-image"><img src={assets.packet} alt="A precisely aligned stack of unbranded document folders" /></div><article><p className="eyebrow">Customer work, protected by design</p><h2>Everything a customer needs, without bringing administration into the device.</h2><p>Native customer features are delivered through an isolated bearer-token API that retains the Portal as the authority for access, files, workflow transitions, payment state, policies, and audit records. Administration remains exclusively in the web Portal.</p><ul className="check-list"><li><CheckIcon /> Documents, deliverables, invoices, messages, support, community, workspaces, and referrals</li><li><CheckIcon /> AAC-LC/M4A recording through native APIs and protected Portal upload capability</li><li><CheckIcon /> System-browser identity and checkout handoffs for credentials and payment-card isolation</li></ul></article></section>
        <section className="handoff-section" id="handoff"><div><p className="eyebrow">Self-hosting handoff</p><h2>Deploy the preview wherever you control the site.</h2><p>This is a static React site with representative local data. It needs no database, authentication provider, API key, customer account, or hosted service to render the demonstration.</p><a className="button button--dark" href="#deployment-note">Read deployment notes <FileText size={16} /></a></div><div className="handoff-art"><span>Static delivery path</span><div className="packet-diagram" aria-label="A local browser, encrypted client workspace, and self-hosted ReadyPackets Portal connected by a controlled route"><div className="diagram-node diagram-node--client"><Smartphone size={20} /><b>Customer device</b><small>Native or browser</small></div><i /><div className="diagram-node diagram-node--portal"><LockKeyhole size={20} /><b>ReadyPackets Portal</b><small>Customer authority</small></div><em>HTTPS · verified handoff · no public cache</em></div></div></section>
        <section className="deployment-note" id="deployment-note"><p className="eyebrow">Deployment note</p><h2>Publish the built static files behind your own HTTPS domain.</h2><p>Run the project build, deploy the generated static output to your chosen self-hosted web server or static host, and configure your own domain. The site has no runtime API dependency. Replace the generated asset URLs with files served from your own static asset path before external hosting if you require complete asset isolation.</p></section>
      </main>
      <footer><a href="#top" className="site-brand"><Mark compact /><span>ReadyPackets</span></a><p>Permanent interactive customer application preview · local representative data only</p></footer>
    </div>
  );
}

function CheckIcon() { return <span className="check-icon">✓</span>; }
