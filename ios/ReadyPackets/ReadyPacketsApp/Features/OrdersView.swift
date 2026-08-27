import AVFoundation
import SwiftUI
import UniformTypeIdentifiers
import UIKit

/// Secure Editorial Console: Orders is the customer work surface; Portal rules remain authoritative.
struct OrdersView: View {
    @EnvironmentObject private var container: AppContainer
    @State private var orders: [OrderSummary] = []
    @State private var error: String?
    @State private var showingComposer = false
    var body: some View { NavigationStack { Group { if orders.isEmpty && error == nil { ContentUnavailableView("No orders", systemImage: "tray", description: Text("Your permitted ReadyPackets orders will appear here.")) } else { List { if let error { Text(error).foregroundStyle(Brand.danger) }; Section { Text("Create a request from listed packets. ReadyPackets confirms pricing, payment, and activation.").font(.subheadline).foregroundStyle(.secondary) }; ForEach(orders) { order in NavigationLink(value: order) { OrderRow(order: order) } } }.navigationDestination(for: OrderSummary.self) { CustomerOrderDetailView(order: $0) } } }.navigationTitle("Orders").toolbar { ToolbarItem(placement: .primaryAction) { Button("Place order") { showingComposer = true } } }.task { await load() }.refreshable { await load() }.sheet(isPresented: $showingComposer) { OrderComposerView { await load() }.environmentObject(container) } } }
    private func load() async { do { orders = try await container.api.get("/orders?limit=50", as: OrdersPage.self).items; error = nil } catch { error = error.localizedDescription } }
}

private struct OrderRow: View { let order: OrderSummary; var body: some View { VStack(alignment: .leading, spacing: 6) { Text(order.projectName ?? order.publicOrderId).font(.headline); Text(order.currentStage ?? order.status).font(.subheadline).foregroundStyle(.secondary); HStack { ProgressView(value: Double(order.completionPercent), total: 100).tint(Brand.teal); Text("\(order.completionPercent)%").font(.caption.monospacedDigit()) }; if order.attention != "none" { Label("Action needed", systemImage: "exclamationmark.circle.fill").font(.caption).foregroundStyle(Brand.warning) } }.padding(.vertical, 4).accessibilityElement(children: .combine) } }

struct CustomerOrderDetailView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.openURL) private var openURL
    let order: OrderSummary
    @State private var detail: CustomerOrderDetail?
    @State private var files: [CustomerFile] = []
    @State private var invoice: Invoice?
    @State private var error: String?
    @State private var message = ""
    @State private var showingImporter = false
    @State private var sharedFile: SharedFile?
    @StateObject private var recorder = AudioCapture()
    @State private var player: AVAudioPlayer?
    private var encodedOrder: String { order.publicOrderId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? order.publicOrderId }
    var body: some View { ScrollView { VStack(alignment: .leading, spacing: 18) {
        BrandCard { VStack(alignment: .leading, spacing: 10) { Text(detail?.order.projectName ?? order.projectName ?? order.publicOrderId).font(.title3.bold()).foregroundStyle(.white); Text(detail?.workflowProgress?.currentPhaseLabel ?? detail?.order.statusLabel ?? order.currentStage ?? order.status).foregroundStyle(.white.opacity(0.8)); ProgressView(value: Double(detail?.order.completionPercent ?? order.completionPercent), total: 100).tint(Brand.teal); Text("Payment status: \(detail?.order.paymentStatus ?? order.paymentStatus)").font(.caption).foregroundStyle(.white.opacity(0.75)) } }
        workflowPanel
        mediaPanel
        invoicePanel
        messagePanel
        if let error { Text(error).foregroundStyle(Brand.danger) }
    }.padding() }.navigationTitle("Order").navigationBarTitleDisplayMode(.inline).task { await load() }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.pdf, .text, .image, .audio, .data], allowsMultipleSelection: true) { result in if case .success(let urls) = result { Task { await upload(urls, recorded: false) } } else if case .failure(let error) = result { self.error = error.localizedDescription } }
        .sheet(item: $sharedFile) { item in ShareSheet(items: [item.url]) }
    }
    private var workflowPanel: some View { GroupBox("Workflow") { VStack(alignment: .leading, spacing: 10) { Text(detail?.workflow?.customerPresentation ?? "ReadyPackets shows only the work your current authorised stage allows.").font(.subheadline); if let stages = detail?.workflow?.stages { ForEach(stages) { stage in HStack(alignment: .top) { Image(systemName: "circle.inset.filled").foregroundStyle(Brand.teal); VStack(alignment: .leading) { Text(stage.label ?? stage.key).font(.headline); if let description = stage.description { Text(description).font(.caption).foregroundStyle(.secondary) } } } } }; HStack { Button("Save intake") { Task { await saveIntake() } }.buttonStyle(.bordered); Button("Submit current stage") { Task { await submitStage() } }.buttonStyle(.borderedProminent).tint(Brand.teal) } } }
    private var mediaPanel: some View { GroupBox("Files and audio") { VStack(alignment: .leading, spacing: 12) { Text("Files are checked and stored by the Portal. Audio is recorded as AAC in an M4A file and can be uploaded only when the current workflow permits it.").font(.caption).foregroundStyle(.secondary); HStack { Button("Choose files") { showingImporter = true }.buttonStyle(.bordered); Button(recorder.isRecording ? "Stop recording" : "Record audio") { Task { if recorder.isRecording { if let url = recorder.stop() { await upload([url], recorded: true) } } else { await recorder.start() } } }.buttonStyle(.borderedProminent).tint(recorder.isRecording ? Brand.danger : Brand.teal) }; if recorder.isRecording { Text("Recording \(Int(recorder.duration))s").font(.caption.monospacedDigit()).foregroundStyle(Brand.danger) }; if let recordingError = recorder.error { Text(recordingError).font(.caption).foregroundStyle(Brand.danger) }; ForEach(files) { file in HStack { Image(systemName: file.audio ? "waveform" : "doc"); VStack(alignment: .leading) { Text(file.originalName).lineLimit(1); Text("\(file.sizeBytes / 1024) KB\(file.durationSeconds.map { " · \(Int($0)) sec" } ?? "")").font(.caption).foregroundStyle(.secondary) }; Spacer(); if file.audio { Button("Play") { Task { await play(file) } }.font(.caption) }; Button("Save") { Task { await download(file) } }.font(.caption) } } } }
    private var invoicePanel: some View { GroupBox("Invoice and payment") { VStack(alignment: .leading, spacing: 8) { if let invoice { Text(invoice.invoiceNumber).font(.headline); Text(invoice.paymentEvidenceLabel).font(.caption).foregroundStyle(.secondary); HStack { Button("Save invoice") { Task { await downloadInvoice() } }.buttonStyle(.bordered); if detail?.order.paymentStatus != "paid" { Button("Pay in Portal") { Task { await checkout() } }.buttonStyle(.borderedProminent).tint(Brand.gold) } } } else { Text("An invoice appears after the Portal publishes a paid-order invoice. Card details are never entered in this app.").font(.subheadline).foregroundStyle(.secondary) } } }
    private var messagePanel: some View { GroupBox("Message ReadyPackets") { VStack(alignment: .leading, spacing: 8) { TextEditor(text: $message).frame(minHeight: 90).overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.25))); Button("Send secure message") { Task { await sendMessage() } }.buttonStyle(.borderedProminent).tint(Brand.teal).disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) } }
    private func load() async { do { async let detailRequest: CustomerOrderDetail = container.api.get("/customer/orders/\(encodedOrder)/detail", as: CustomerOrderDetail.self); async let fileRequest: CustomerFilesPage = container.api.get("/customer/orders/\(encodedOrder)/files", as: CustomerFilesPage.self); detail = try await detailRequest; files = try await fileRequest.items; invoice = try? await container.api.get("/customer/orders/\(encodedOrder)/invoice", as: Invoice.self); error = nil } catch { self.error = error.localizedDescription } }
    private func upload(_ urls: [URL], recorded: Bool) async { do { let scoped = urls.filter { $0.startAccessingSecurityScopedResource() }; defer { scoped.forEach { $0.stopAccessingSecurityScopedResource() } }; let fields = ["phase": detail?.workflow?.stages?.first?.key ?? "phase_1_intake", "recordedAudio": recorded ? "true" : "false", "prerecordedAudio": (!recorded && urls.contains { ["m4a", "mp3", "wav", "webm", "ogg"].contains($0.pathExtension.lowercased()) }) ? "true" : "false"]; let reply = try await container.api.upload("/customer/orders/\(encodedOrder)/uploads", files: urls, fields: fields); files.append(contentsOf: reply.items); error = nil } catch { self.error = error.localizedDescription } }
    private func play(_ file: CustomerFile) async { do { let data = try await container.api.getData("/customer/files/\(file.mobileFileRef)/content?disposition=inline"); player = try AVAudioPlayer(data: data); player?.prepareToPlay(); player?.play() } catch { self.error = error.localizedDescription } }
    private func download(_ file: CustomerFile) async { do { let data = try await container.api.getData("/customer/files/\(file.mobileFileRef)/content"); let url = FileManager.default.temporaryDirectory.appending(path: file.originalName); try data.write(to: url, options: .atomic); sharedFile = SharedFile(url: url) } catch { self.error = error.localizedDescription } }
    private func downloadInvoice() async { do { let data = try await container.api.getData("/customer/orders/\(encodedOrder)/invoice/content"); let url = FileManager.default.temporaryDirectory.appending(path: "\(invoice?.invoiceNumber ?? "ReadyPackets-invoice").pdf"); try data.write(to: url, options: .atomic); sharedFile = SharedFile(url: url) } catch { self.error = error.localizedDescription } }
    private func checkout() async { struct Request: Encodable {}; do { let handoff = try await container.api.post("/customer/orders/\(encodedOrder)/checkout-handoff", body: Request(), as: CheckoutHandoff.self); openURL(handoff.checkoutUrl) } catch { self.error = error.localizedDescription } }
    private func saveIntake() async { struct Request: Encodable { let projectName: String? }; do { _ = try await container.api.put("/customer/orders/\(encodedOrder)/intake", body: Request(projectName: detail?.order.projectName), as: EmptyReply.self); error = nil } catch { self.error = error.localizedDescription } }
    private func submitStage() async { struct Request: Encodable { let acknowledged: Bool; let acknowledgementText: String }; let stage = detail?.workflow?.stages?.first?.key ?? "phase_1"; do { _ = try await container.api.post("/customer/orders/\(encodedOrder)/workflow/\(stage)/submit", body: Request(acknowledged: true, acknowledgementText: "I confirm this customer workflow submission is accurate."), as: EmptyReply.self); await load() } catch { self.error = error.localizedDescription } }
    private func sendMessage() async { struct Request: Encodable { let body: String }; do { _ = try await container.api.post("/customer/orders/\(encodedOrder)/messages", body: Request(body: message), as: EmptyReply.self); message = ""; error = nil } catch { self.error = error.localizedDescription } }
}

private struct SharedFile: Identifiable { let url: URL; var id: URL { url } }
private struct ShareSheet: UIViewControllerRepresentable { let items: [Any]; func makeUIViewController(context: Context) -> UIActivityViewController { UIActivityViewController(activityItems: items, applicationActivities: nil) }; func updateUIViewController(_ controller: UIActivityViewController, context: Context) {} }
