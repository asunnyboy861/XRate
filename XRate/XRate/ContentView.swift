import SwiftUI

struct ContentView: View {
    var body: some View {
        ConversionView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Currency.self, CachedExchangeRate.self])
}
