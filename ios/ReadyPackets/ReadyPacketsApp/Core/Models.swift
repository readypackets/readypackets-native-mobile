import Foundation

struct TokenSet: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String
    enum CodingKeys: String, CodingKey { case accessToken = "access_token", tokenType = "token_type", expiresIn = "expires_in", refreshToken = "refresh_token" }
}

struct APIProblem: Decodable, LocalizedError {
    let title: String
    let code: String
    let detail: String?
    var errorDescription: String? { detail ?? title }
}

struct Profile: Decodable {
    let id: String
    let displayName: String
    let email: String
    let role: String
    let capabilities: [String]
    let mfaEnabled: Bool
    let emailVerified: Bool
}

struct Dashboard: Decodable {
    let orderCount: Int
    let attentionCount: Int
    let currentOrders: [DashboardOrder]
}

struct DashboardOrder: Decodable, Identifiable {
    let publicOrderId: String
    let projectName: String?
    let status: String
    let completionPercent: Int
    let currentStage: String?
    let attention: String
    var id: String { publicOrderId }
}

struct OrderSummary: Decodable, Identifiable, Hashable {
    let publicOrderId: String
    let projectName: String?
    let status: String
    let paymentStatus: String
    let completionPercent: Int
    let currentStage: String?
    let attention: String
    let dueAt: Date?
    let deliveredAt: Date?
    let createdAt: Date?
    var id: String { publicOrderId }
}

struct OrdersPage: Decodable { let items: [OrderSummary]; let nextCursor: String? }
struct OrderDetail: Decodable { let publicOrderId: String; let projectName: String?; let status: String; let paymentStatus: String; let completionPercent: Int; let currentStage: String? }
struct DeviceRecord: Decodable, Identifiable { let id: String; let platform: String; let appVersion: String; let deviceName: String?; let status: String; let lastSeenAt: Date?; let current: Bool }
struct DevicesPage: Decodable { let items: [DeviceRecord] }
struct CatalogPacket: Decodable, Identifiable { let sku: String; let name: String; let tier: String; let priceCents: Int?; let customPricing: Bool; let deliveryEstimate: String; let outcome: String?; let description: String?; var id: String { sku } }
struct CatalogGroup: Decodable, Identifiable { let slug: String; let number: Int; let name: String; let category: String; let summary: String?; let packets: [CatalogPacket]; var id: String { slug } }
struct CatalogPage: Decodable { let items: [CatalogGroup] }
struct OrderSelection: Encodable { let sku: String; let quantity: Int }
struct CreateOrderRequest: Encodable { let selections: [OrderSelection]; let projectName: String? }
struct CreatedMobileOrder: Decodable { let publicOrderId: String; let projectName: String?; let status: String; let paymentStatus: String; let totalCents: Int; let requiresCustomQuote: Bool }
struct CreateOrderReply: Decodable { let order: CreatedMobileOrder; let nextAction: String; let message: String }

struct CustomerFile: Decodable, Identifiable { let mobileFileRef: String; let originalName: String; let extension: String?; let sizeBytes: Int; let durationSeconds: Double?; let category: String?; let phase: String?; let version: Int; let createdAt: Date?; let uploadedByStaff: Bool?; let audio: Bool; var id: String { mobileFileRef } }
struct CustomerFilesPage: Decodable { let items: [CustomerFile] }
struct CustomerWorkflow: Decodable { let name: String?; let description: String?; let customerPresentation: String?; let stages: [WorkflowStage]? }
struct WorkflowStage: Decodable, Identifiable { let key: String; let label: String?; let description: String?; let advanceMode: String?; let capabilities: [String]?; var id: String { key } }
struct CustomerOrderCore: Decodable { let publicOrderId: String; let projectName: String?; let status: String; let statusLabel: String?; let paymentStatus: String; let totalCents: Int; let completionPercent: Int; let dueAt: Date?; let deliveredAt: Date?; let createdAt: Date? }
struct CustomerOrderDetail: Decodable { let order: CustomerOrderCore; let workflow: CustomerWorkflow?; let deliverables: [CustomerFile]; let messages: [CustomerMessage]; let workflowProgress: WorkflowProgress? }
struct WorkflowProgress: Decodable { let currentPhaseLabel: String?; let completionPercent: Int? }
struct CustomerMessage: Decodable, Identifiable { let mobileMessageRef: String; let publicOrderId: String?; let projectName: String?; let authorRole: String?; let body: String; let createdAt: Date?; let unread: Bool?; var id: String { mobileMessageRef } }
struct MessagesPage: Decodable { let unreadCount: Int; let items: [CustomerMessage] }
struct NotificationItem: Decodable, Identifiable { let kind: String; let publicOrderId: String?; let createdAt: Date?; let title: String; let body: String; var id: String { "\(kind)-\(publicOrderId ?? "general")-\(createdAt?.timeIntervalSince1970 ?? 0)" } }
struct NotificationsPage: Decodable { let items: [NotificationItem]; let unreadCount: Int; let generatedAt: Date }
struct Invoice: Decodable { let invoiceNumber: String; let orderNumber: String; let issuedAt: Date; let paidAt: Date?; let subtotalCents: Int; let discountCents: Int; let totalCents: Int; let actualCustomerPaidCents: Int; let paymentEvidenceLabel: String; let customerVisible: Bool }
struct CheckoutHandoff: Decodable { let checkoutUrl: URL; let provider: String; let message: String }
struct SupportTicket: Decodable, Identifiable { let ticketNumber: String; let subject: String; let category: String; let status: String; let priority: String; let lastReplyAt: Date?; let createdAt: Date?; var id: String { ticketNumber } }
struct TicketsPage: Decodable { let items: [SupportTicket] }
struct TicketReply: Decodable, Identifiable { let body: String; let author: String; let isStaffReply: Bool; let createdAt: Date?; var id: String { "\(author)-\(createdAt?.timeIntervalSince1970 ?? 0)" } }
struct TicketDetail: Decodable { let ticket: SupportTicket; let replies: [TicketReply] }
struct ForumCategory: Decodable, Identifiable { let slug: String; let name: String; let description: String?; var id: String { slug } }
struct ForumCategoriesPage: Decodable { let items: [ForumCategory] }
struct ForumTopic: Decodable, Identifiable { let slug: String; let title: String; let excerpt: String?; let pinned: Bool; let locked: Bool; let replyCount: Int; let author: String; let lastPostAt: Date?; let createdAt: Date?; var id: String { slug } }
struct ForumTopicsPage: Decodable { let items: [ForumTopic] }
struct Workspace: Decodable, Identifiable { let mobileWorkspaceRef: String; let name: String; let slug: String; let role: String; let youOwnThisWorkspace: Bool; var id: String { mobileWorkspaceRef } }
struct WorkspacesPage: Decodable { let items: [Workspace] }
struct WorkspaceCreated: Decodable { let mobileWorkspaceRef: String; let slug: String }
struct ReferralStats: Decodable { let total: Int; let pending: Int; let approved: Int; let paid: Int; let totalRewardCents: Int; let paidRewardCents: Int }
struct ReferralSummary: Decodable { let code: String; let stats: ReferralStats }
struct PolicyItem: Decodable, Identifiable { let id: Int; let title: String; let version: String?; let slug: String? }
struct PoliciesPage: Decodable { let pending: [PolicyItem] }
struct KnowledgeArticle: Decodable, Identifiable { let slug: String; let title: String; let excerpt: String?; let category: String?; let updatedAt: Date?; var id: String { slug } }
struct KnowledgePage: Decodable { let items: [KnowledgeArticle] }
struct FAQ: Decodable, Identifiable { let question: String; let answerMarkdown: String; let category: String?; let updatedAt: Date?; var id: String { question } }
struct FAQsPage: Decodable { let items: [FAQ] }
struct BrowserEntrypoints: Decodable { let registrationUrl: URL; let emailVerificationUrl: URL; let passwordRecoveryUrl: URL; let customerSecurityUrl: URL; let legalUrl: URL; let contactUrl: URL }
struct EmptyReply: Decodable { let ok: Bool? }
struct DeviceRegistration: Encodable { let deviceId: String; let platform: String; let appVersion: String; let deviceName: String; let pushPlatform: String?; let pushToken: String? }
struct DeviceRegistrationReply: Decodable { let registered: Bool }
