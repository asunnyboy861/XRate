import StoreKit
import Observation

enum ProductID {
    static let monthly = "com.zzoutuo.XRate.pro.monthly"
    static let yearly = "com.zzoutuo.XRate.pro.yearly"
    static let lifetime = "com.zzoutuo.XRate.pro.lifetime"
    static let all = [monthly, yearly, lifetime]
}

@MainActor
@Observable
final class PurchaseManager {
    var products: [Product] = []
    var purchasedProductIDs: Set<String> = []
    var isPro: Bool = false
    var isLoading: Bool = false
    var errorMessage: String?

    var monthlyProduct: Product? {
        products.first { $0.id == ProductID.monthly }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == ProductID.yearly }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == ProductID.lifetime }
    }

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await updatePurchaseStatus()
        }
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: ProductID.all)
            products = storeProducts.sorted { $0.price < $1.price }
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
        }
    }

    func purchase(_ product: Product) async -> Bool {
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchaseStatus()
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            errorMessage = "Purchase failed: \(error.localizedDescription)"
            return false
        }
    }

    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
        } catch {
            errorMessage = "Restore failed: \(error.localizedDescription)"
        }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                let transaction: Transaction
                switch result {
                case .verified(let safe):
                    transaction = safe
                case .unverified:
                    continue
                }
                await self.updatePurchaseStatus()
                await transaction.finish()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    private func updatePurchaseStatus() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchasedIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedIDs
        isPro = purchasedProductIDs.contains(ProductID.monthly)
            || purchasedProductIDs.contains(ProductID.yearly)
            || purchasedProductIDs.contains(ProductID.lifetime)
    }
}

enum StoreError: Error {
    case failedVerification
}
