import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        List {
            Section("Pro") {
                NavigationLink {
                    PaywallView()
                } label: {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(.yellow)
                        Text("Upgrade to Pro")
                    }
                }
            }

            Section("Preferences") {
                Stepper(
                    "Decimal Places: \(viewModel.decimalPlaces)",
                    value: $viewModel.decimalPlaces,
                    in: 2...6
                )
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(viewModel.appVersion)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                NavigationLink {
                    ContactSupportView()
                } label: {
                    Label("Contact Support", systemImage: "envelope")
                }

                Link(destination: URL(string: "https://asunnyboy861.github.io/XRate-privacy/")!) {
                    Label("Privacy Policy", systemImage: "hand.shield")
                }

                Link(destination: URL(string: "https://asunnyboy861.github.io/XRate-terms/")!) {
                    Label("Terms of Use", systemImage: "doc.text")
                }

                Link(destination: URL(string: "https://asunnyboy861.github.io/XRate-support/")!) {
                    Label("Support", systemImage: "questionmark.circle")
                }
            }
        }
        .navigationTitle("Settings")
    }
}
