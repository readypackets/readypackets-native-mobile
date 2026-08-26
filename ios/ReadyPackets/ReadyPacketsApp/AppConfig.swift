import Foundation

enum AppConfig {
    /// Build settings, not secrets. Protected release workflows override these values for staging or production.
    private static func httpsURL(_ key: String, fallback: String) -> URL {
        let rawValue = Bundle.main.object(forInfoDictionaryKey: key) as? String ?? fallback
        guard let value = URL(string: rawValue), value.scheme == "https", value.host != nil else {
            fatalError("\(key) must be a valid HTTPS URL in the active build configuration.")
        }
        return value
    }
    static let portalBaseURL = httpsURL("RPPortalBaseURL", fallback: "https://portal.example.com")
    static let redirectURI = httpsURL("RPOAuthRedirectURI", fallback: "https://mobile.example.com/auth/callback")
    static let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
}
