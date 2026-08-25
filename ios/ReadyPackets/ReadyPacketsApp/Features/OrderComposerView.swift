import SwiftUI

struct OrderComposerView: View {
    @EnvironmentObject private var container: AppContainer
    @Environment(\.dismiss) private var dismiss
    @State private var catalog: CatalogPage?
    @State private var selectedSkus: [String: String] = [:]
    @State private var projectName = ""
    @State private var reply: CreateOrderReply?
    @State private var error: String?
    @State private var submitting = false
    let onCreated: () async -> Void

    var body: some View {
        NavigationStack {
            Group {
                if let reply {
                    confirmation(reply)
                } else {
                    Form {
                        Section("Order request") {
                            Text("Choose listed packets. The ReadyPackets Portal verifies pricing, payment, workflow, and the final order record.")
                            TextField("Project name (optional)", text: $projectName)
                                .textInputAutocapitalization(.words)
                                .accessibilityHint("Maximum 160 characters")
                        }
                        if let error {
                            Section { Text(error).foregroundStyle(Brand.danger) }
                        }
                        if let catalog {
                            ForEach(catalog.items) { group in
                                Section("\(group.number). \(group.name)") {
                                    if let summary = group.summary { Text(summary).font(.subheadline).foregroundStyle(.secondary) }
                                    ForEach(group.packets) { packet in
                                        Button { selectedSkus[group.slug] = packet.sku } label: {
                                            HStack(alignment: .top, spacing: 12) {
                                                Image(systemName: selectedSkus[group.slug] == packet.sku ? "largecircle.fill.circle" : "circle")
                                                    .foregroundStyle(selectedSkus[group.slug] == packet.sku ? Brand.teal : .secondary)
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(packet.name).foregroundStyle(.primary)
                                                    Text(packet.description ?? packet.outcome ?? packet.deliveryEstimate).font(.caption).foregroundStyle(.secondary)
                                                    Text(packet.priceCents.map(currency) ?? "Custom quote").font(.caption.weight(.semibold)).foregroundStyle(Brand.teal)
                                                }
                                                Spacer(minLength: 0)
                                            }
                                        }.buttonStyle(.plain).accessibilityLabel("Select \(packet.name) in \(group.name)")
                                    }
                                }
                            }
                            Section {
                                Button { submit() } label: { submitting ? AnyView(ProgressView()) : AnyView(Text("Record selected packets").frame(maxWidth: .infinity)) }
                                    .disabled(selectedSkus.isEmpty || submitting)
                                Text("Prices and the payment action are confirmed by the Portal after submission. Do not submit payment data in this app.").font(.caption).foregroundStyle(.secondary)
                            }
                        } else if error == nil {
                            Section { HStack { ProgressView(); Text("Loading listed packets…") } }
                        }
                    }
                }
            }
            .navigationTitle(reply == nil ? "Place an order" : "Order recorded")
            .toolbar { if reply == nil { ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } } } }
            .task { await load() }
        }
    }

    @ViewBuilder private func confirmation(_ reply: CreateOrderReply) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Image(systemName: "checkmark.seal.fill").font(.largeTitle).foregroundStyle(Brand.teal)
            Text(reply.order.publicOrderId).font(.title2.monospaced().weight(.bold))
            Text(reply.message)
            BrandCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text(reply.order.requiresCustomQuote ? "Quote required" : "Payment required").font(.headline).foregroundStyle(.white)
                    Text(reply.order.requiresCustomQuote ? "ReadyPackets will prepare your quote in the Portal. Work begins only after the server confirms the next step." : "Complete payment through the secure ReadyPackets Portal to activate work. The mobile client never collects card data.").font(.subheadline).foregroundStyle(.white.opacity(0.84))
                }
            }
            Button("Return to orders") { Task { await onCreated(); dismiss() } }.buttonStyle(.borderedProminent).tint(Brand.teal).frame(maxWidth: .infinity)
            Spacer()
        }.padding()
    }

    private func load() async {
        do { catalog = try await container.api.get("/catalog", as: CatalogPage.self); error = nil }
        catch { self.error = error.localizedDescription }
    }

    private func submit() {
        submitting = true; error = nil
        Task {
            do {
                let request = CreateOrderRequest(selections: selectedSkus.values.map { OrderSelection(sku: $0, quantity: 1) }, projectName: projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : projectName)
                reply = try await container.api.post("/orders", body: request, as: CreateOrderReply.self)
            } catch { self.error = error.localizedDescription }
            submitting = false
        }
    }
}

private func currency(_ cents: Int) -> String {
    let formatter = NumberFormatter(); formatter.numberStyle = .currency; formatter.currencyCode = "USD"
    return formatter.string(from: NSNumber(value: Double(cents) / 100)) ?? "$0.00"
}
