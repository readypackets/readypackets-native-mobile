import Foundation
import UIKit

enum DeviceInstallation {
    static var id: String {
        UserDefaults.standard.string(forKey: "rp.installation.id") ?? UUID().uuidString.lowercased().also { UserDefaults.standard.set($0, forKey: "rp.installation.id") }
    }
    static var name: String { UIDevice.current.name.prefix(128).description }
}

private extension String { func also(_ body: (String) -> Void) -> String { body(self); return self } }
