import SwiftUI

/// Secure Editorial Console: customer service hub; operational controls remain web-only.
struct MessagesView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var page: MessagesPage?
    @State private var error: String?
    var body: some View { NavigationStack { Group { if let page { List(page.items) { message in VStack(alignment: .leading, spacing: 6) { HStack { Text(message.projectName ?? message.publicOrderId ?? "ReadyPackets").font(.headline); if message.unread == true { Text("NEW").font(.caption2.bold()).foregroundStyle(Brand.teal) } }; Text(message.body).lineLimit(4); Text(message.createdAt?.formatted(date: .abbreviated, time: .shortened) ?? "").font(.caption).foregroundStyle(.secondary) }.task { await markRead(message) } } } else if let error { ContentUnavailableView("Messages unavailable", systemImage: "exclamationmark.bubble", description: Text(error)) } else { ProgressView() } }.navigationTitle("Messages").task { await load() }.refreshable { await load() } } }
    private func load() async { do { page = try await container.api.get("/customer/messages", as: MessagesPage.self); error = nil } catch { self.error = error.localizedDescription } }
    private func markRead(_ message: CustomerMessage) async { guard message.unread == true else { return }; _ = try? await container.api.post("/customer/messages/\(message.mobileMessageRef)/read", body: [String: String](), as: EmptyReply.self) }
}

struct NotificationsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var page: NotificationsPage?
    @State private var error: String?
    var body: some View { NavigationStack { Group { if let page { List(page.items) { item in Label { VStack(alignment: .leading, spacing: 4) { Text(item.title).font(.headline); Text(item.body); if let createdAt = item.createdAt { Text(createdAt.formatted(date: .abbreviated, time: .shortened)).font(.caption).foregroundStyle(.secondary) } } } icon: { Image(systemName: item.kind == "workflow" ? "checklist" : item.kind == "support" ? "lifepreserver" : "bubble.left") } } } else if let error { ContentUnavailableView("Updates unavailable", systemImage: "bell.slash", description: Text(error)) } else { ProgressView() } }.navigationTitle("Updates").task { await load() }.refreshable { await load() } } }
    private func load() async { do { page = try await container.api.get("/customer/notifications", as: NotificationsPage.self); error = nil } catch { self.error = error.localizedDescription } }
}

struct CustomerServicesView: View {
    var body: some View { NavigationStack { List { Section("Customer workspace") { NavigationLink("Profile and devices") { ProfileView() }; NavigationLink("Support tickets") { TicketsView() }; NavigationLink("Packet Collective") { WorkspacesView() }; NavigationLink("Referrals") { ReferralsView() } }; Section("Resources") { NavigationLink("Community") { CommunityView() }; NavigationLink("Knowledge base") { KnowledgeView() }; NavigationLink("Frequently asked questions") { FAQsView() }; NavigationLink("Account and security") { BrowserEntrypointsView() } } }.navigationTitle("Customer services") } }
}

struct TicketsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var page: TicketsPage?
    @State private var error: String?
    @State private var showingComposer = false
    var body: some View { Group { if let page { List(page.items) { ticket in VStack(alignment: .leading) { Text(ticket.subject).font(.headline); Text("\(ticket.ticketNumber) · \(ticket.status.capitalized)").font(.caption).foregroundStyle(.secondary) } } } else if let error { ContentUnavailableView("Support unavailable", systemImage: "lifepreserver", description: Text(error)) } else { ProgressView() } }.navigationTitle("Support").toolbar { Button("New ticket") { showingComposer = true } }.task { await load() }.sheet(isPresented: $showingComposer) { TicketComposer { await load() }.environmentObject(container) } }
    private func load() async { do { page = try await container.api.get("/customer/tickets", as: TicketsPage.self); error = nil } catch { self.error = error.localizedDescription } }
}

private struct TicketComposer: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss
    let completed: () async -> Void
    @State private var subject = ""; @State private var body = ""; @State private var error: String?
    var body: some View { NavigationStack { Form { TextField("Subject", text: $subject); TextEditor(text: $body).frame(minHeight: 160); if let error { Text(error).foregroundStyle(Brand.danger) } }.navigationTitle("New support ticket").toolbar { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }; ToolbarItem(placement: .confirmationAction) { Button("Send") { Task { await send() } }.disabled(subject.count < 5 || body.count < 20) } } } }
    private func send() async { do { struct Request: Encodable { let subject: String; let body: String; let category = "general"; let priority = "normal" }; _ = try await container.api.post("/customer/tickets", body: Request(subject: subject, body: body), as: EmptyReply.self); await completed(); dismiss() } catch { self.error = error.localizedDescription } }
}

struct WorkspacesView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var page: WorkspacesPage?; @State private var name = ""; @State private var error: String?
    var body: some View { List { if let page { ForEach(page.items) { workspace in VStack(alignment: .leading) { Text(workspace.name).font(.headline); Text("\(workspace.role.capitalized) · \(workspace.slug)").font(.caption).foregroundStyle(.secondary) } } }; Section("Create a Packet Collective") { TextField("Workspace name", text: $name); Button("Create workspace") { Task { await create() } }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).count < 2) }; if let error { Text(error).foregroundStyle(Brand.danger) } }.navigationTitle("Packet Collective").task { await load() }.refreshable { await load() } }
    private func load() async { do { page = try await container.api.get("/customer/workspaces", as: WorkspacesPage.self); error = nil } catch { self.error = error.localizedDescription } }
    private func create() async { struct Request: Encodable { let name: String }; do { _ = try await container.api.post("/customer/workspaces", body: Request(name: name), as: WorkspaceCreated.self); name = ""; await load() } catch { self.error = error.localizedDescription } }
}

struct ReferralsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var referral: ReferralSummary?; @State private var error: String?
    var body: some View { Group { if let referral { Form { Section("Your referral code") { Text(referral.code).font(.title2.monospaced().bold()); ShareLink(item: referral.code, subject: Text("ReadyPackets referral"), message: Text("Use my ReadyPackets referral code: \(referral.code)")) { Label("Share code", systemImage: "square.and.arrow.up") } }; Section("Referral progress") { LabeledContent("Total", value: "\(referral.stats.total)"); LabeledContent("Pending", value: "\(referral.stats.pending)"); LabeledContent("Approved", value: "\(referral.stats.approved)"); LabeledContent("Paid", value: "\(referral.stats.paid)") } } } else if let error { ContentUnavailableView("Referrals unavailable", systemImage: "gift", description: Text(error)) } else { ProgressView() } }.navigationTitle("Referrals").task { await load() } }
    private func load() async { do { referral = try await container.api.get("/customer/referrals", as: ReferralSummary.self) } catch { self.error = error.localizedDescription } }
}

struct CommunityView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var topics: ForumTopicsPage?; @State private var error: String?
    var body: some View { Group { if let topics { List(topics.items) { topic in VStack(alignment: .leading, spacing: 5) { Text(topic.title).font(.headline); Text(topic.excerpt ?? "").lineLimit(2); Text("\(topic.replyCount) replies · \(topic.author)").font(.caption).foregroundStyle(.secondary) } } } else if let error { ContentUnavailableView("Community unavailable", systemImage: "person.3", description: Text(error)) } else { ProgressView() } }.navigationTitle("Community").task { await load() }.refreshable { await load() } }
    private func load() async { do { topics = try await container.api.get("/customer/community/topics", as: ForumTopicsPage.self) } catch { self.error = error.localizedDescription } }
}

struct KnowledgeView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var page: KnowledgePage?; @State private var error: String?
    var body: some View { Group { if let page { List(page.items) { item in VStack(alignment: .leading) { Text(item.title).font(.headline); Text(item.excerpt ?? "").lineLimit(3).foregroundStyle(.secondary) } } } else if let error { ContentUnavailableView("Knowledge base unavailable", systemImage: "book.closed", description: Text(error)) } else { ProgressView() } }.navigationTitle("Knowledge base").task { await load() } }
    private func load() async { do { page = try await container.api.get("/customer/knowledge", as: KnowledgePage.self) } catch { self.error = error.localizedDescription } }
}

struct FAQsView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var page: FAQsPage?; @State private var error: String?
    var body: some View { Group { if let page { List(page.items) { faq in DisclosureGroup(faq.question) { Text(faq.answerMarkdown) } } } else if let error { ContentUnavailableView("FAQs unavailable", systemImage: "questionmark.circle", description: Text(error)) } else { ProgressView() } }.navigationTitle("FAQs").task { await load() } }
    private func load() async { do { page = try await container.api.get("/public/faqs", as: FAQsPage.self) } catch { self.error = error.localizedDescription } }
}

struct BrowserEntrypointsView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.openURL) private var openURL
    @State private var links: BrowserEntrypoints?; @State private var error: String?
    var body: some View { Form { if let links { Section("Account") { Button("Register a customer account") { openURL(links.registrationUrl) }; Button("Verify email") { openURL(links.emailVerificationUrl) }; Button("Reset password") { openURL(links.passwordRecoveryUrl) }; Button("Password, MFA, and sessions") { openURL(links.customerSecurityUrl) } }; Section("ReadyPackets Portal") { Button("Public packets") { openURL(links.legalUrl.deletingLastPathComponent().appending(path: "packets")) }; Button("Legal and privacy") { openURL(links.legalUrl) }; Button("Contact ReadyPackets") { openURL(links.contactUrl) } }; Text("These sensitive actions open the verified ReadyPackets Portal in your system browser. Your password, MFA values, and payment data are never entered into this app.").font(.footnote).foregroundStyle(.secondary) } else if let error { Text(error).foregroundStyle(Brand.danger) } else { ProgressView() } }.navigationTitle("Account and security").task { await load() } }
    private func load() async { do { links = try await container.api.get("/public/browser-entrypoints", as: BrowserEntrypoints.self) } catch { self.error = error.localizedDescription } }
}
