import Foundation
import Observation

@Observable
final class SettingsViewModel {
    var decimalPlaces: Int {
        get { UserDefaults.standard.integer(forKey: "decimalPlaces") }
        set { UserDefaults.standard.set(newValue, forKey: "decimalPlaces") }
    }

    var isPro: Bool {
        get { UserDefaults.standard.bool(forKey: "isPro") }
        set { UserDefaults.standard.set(newValue, forKey: "isPro") }
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    init() {
        if UserDefaults.standard.object(forKey: "decimalPlaces") == nil {
            UserDefaults.standard.set(2, forKey: "decimalPlaces")
        }
    }
}
