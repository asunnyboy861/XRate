import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType?

    enum PlanType: String, CaseIterable {
        case monthly, yearly, lifetime
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    featuresSection
                    plansSection
                    subscribeButton
                    legalSection
                }
                .padding(20)
                .iPadMaxWidth()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("XRate Pro")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "crown.fill")
                .font(.system(size: 48))
                .foregroundStyle(.yellow)
            Text("Unlock XRate Pro")
                .font(.system(size: 24, weight: .bold))
            Text("Get the full currency conversion experience")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow("Unlimited currencies", icon: "globe")
            featureRow("Desktop Widget", icon: "square.grid.2x2")
            featureRow("Apple Watch App", icon: "applewatch")
            featureRow("Historical rates (1 year+)", icon: "calendar")
            featureRow("Batch conversion", icon: "list.bullet")
            featureRow("Travel mode", icon: "location.fill")
            featureRow("Custom decimal places", icon: "number")
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func featureRow(_ text: String, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text)
                .font(.system(size: 15))
        }
    }

    private var plansSection: some View {
        VStack(spacing: 12) {
            planCard(.monthly, title: "Monthly", price: "$2.99/mo", subtitle: nil)
            planCard(.yearly, title: "Yearly", price: "$14.99/yr", subtitle: "Save 58%")
            planCard(.lifetime, title: "Lifetime", price: "$29.99", subtitle: "One-time purchase")
        }
    }

    @ViewBuilder
    private func planCard(_ plan: PlanType, title: String, price: String, subtitle: String?) -> some View {
        Button {
            selectedPlan = plan
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                    }
                }
                Spacer()
                Text(price)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
            }
            .padding(16)
            .background(
                selectedPlan == plan ? Color.accentColor.opacity(0.15) : Color(uiColor: .secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .foregroundStyle(.primary)
    }

    private var subscribeButton: some View {
        Button {
        } label: {
            Text("Subscribe")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedPlan == nil ? Color.gray : Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedPlan == nil)
    }

    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/XRate-privacy/")!)
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/XRate-terms/")!)
            }
            .font(.system(size: 12))

            Button("Restore Purchases") {}
                .font(.system(size: 12))
                .foregroundStyle(Color.accentColor)
        }
        .padding(.top, 8)
    }
}
