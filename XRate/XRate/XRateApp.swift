import SwiftUI
import SwiftData

@main
struct XRateApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Currency.self, CachedExchangeRate.self])
    }
}
