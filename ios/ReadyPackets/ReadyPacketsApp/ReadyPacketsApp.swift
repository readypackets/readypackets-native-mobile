import SwiftUI
import UIKit
import UserNotifications

@main
struct ReadyPacketsApp: App {
    @StateObject private var container = AppContainer()
    @UIApplicationDelegateAdaptor(PushAppDelegate.self) private var pushDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(container)
                .tint(Brand.teal)
                .onOpenURL { url in
                    Task { await container.handleCallback(url) }
                }
                .task { await container.restore() }
                .onReceive(NotificationCenter.default.publisher(for: .readyPacketsPushToken)) { notification in
                    if let token = notification.object as? Data { Task { await container.registerAPNSToken(token) } }
                }
        }
    }
}

@MainActor
final class AppContainer: ObservableObject {
    enum State { case loading, signedOut, locked, signedIn }
    @Published private(set) var state: State = .loading
    @Published var toast: String?
    let tokenStore = TokenStore()
    lazy var api = MobileAPIClient(tokenStore: tokenStore)
    lazy var auth = AuthCoordinator(api: api, tokenStore: tokenStore)

    func restore() async {
        guard await tokenStore.refreshToken != nil else { state = .signedOut; return }
        state = .locked
    }

    func signIn() async {
        do { try await auth.begin(); toast = "Continue securely in your browser." }
        catch { toast = error.localizedDescription }
    }

    func unlock() async {
        do { try await BiometricGate.authenticate(); state = .signedIn }
        catch { toast = error.localizedDescription }
    }

    func handleCallback(_ url: URL) async {
        do { try await auth.complete(with: url); state = .signedIn; await requestPushAuthorization() }
        catch { state = .signedOut; toast = error.localizedDescription }
    }

    func signOut() async {
        await api.revoke()
        await tokenStore.wipe()
        state = .signedOut
    }

    func requestPushAuthorization() async {
        guard await tokenStore.refreshToken != nil else { return }
        let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
        guard granted else { return }
        UIApplication.shared.registerForRemoteNotifications()
    }

    func registerAPNSToken(_ token: Data) async {
        guard await tokenStore.refreshToken != nil else { return }
        let value = token.map { String(format: "%02x", $0) }.joined()
        _ = try? await api.post("/devices", body: DeviceRegistration(deviceId: DeviceInstallation.id, platform: "ios", appVersion: AppConfig.appVersion, deviceName: DeviceInstallation.name, pushPlatform: "apns", pushToken: value), as: DeviceRegistrationReply.self)
    }
}

final class PushAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        NotificationCenter.default.post(name: .readyPacketsPushToken, object: deviceToken)
    }
}

extension Notification.Name { static let readyPacketsPushToken = Notification.Name("ReadyPacketsPushToken") }
