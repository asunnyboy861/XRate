import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPlan: PlanType?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    @State private var purchaseManager = PurchaseManager()

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
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
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
            if let product = purchaseManager.monthlyProduct {
                planCard(.monthly, title: "Monthly", product: product, subtitle: nil)
            }
            if let product = purchaseManager.yearlyProduct {
                planCard(.yearly, title: "Yearly", product: product, subtitle: "Save 58%")
            }
            if let product = purchaseManager.lifetimeProduct {
                planCard(.lifetime, title: "Lifetime", product: product, subtitle: "One-time purchase")
            }
        }
    }

    @ViewBuilder
    private func planCard(_ plan: PlanType, title: String, product: Product, subtitle: String?) -> some View {
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
                Text(product.displayPrice)
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
            Task {
                await purchaseSelectedPlan()
            }
        } label: {
            if isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            } else {
                Text("Subscribe")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(selectedPlan == nil ? Color.gray : Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .disabled(selectedPlan == nil || isLoading)
    }

    private var legalSection: some View {
        VStack(spacing: 8) {
            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription.")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/XRate-privacy/")!)
                Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/XRate-terms/")!)
            }
            .font(.system(size: 12))

            Button("Restore Purchases") {
                Task {
                    await restorePurchases()
                }
            }
            .font(.system(size: 12))
            .foregroundStyle(Color.accentColor)
        }
        .padding(.top, 8)
    }
    
    private func purchaseSelectedPlan() async {
        guard let plan = selectedPlan else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        let product: Product?
        switch plan {
        case .monthly:
            product = purchaseManager.monthlyProduct
        case .yearly:
            product = purchaseManager.yearlyProduct
        case .lifetime:
            product = purchaseManager.lifetimeProduct
        }
        
        guard let productToPurchase = product else { return }
        
        let success = await purchaseManager.purchase(productToPurchase)
        if success {
            dismiss()
        } else if let error = purchaseManager.errorMessage {
            errorMessage = error
            showError = true
        }
    }
    
    private func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        await purchaseManager.restorePurchases()
        
        if purchaseManager.isPro {
            dismiss()
        } else if let error = purchaseManager.errorMessage {
            errorMessage = error
            showError = true
        }
    }
}
