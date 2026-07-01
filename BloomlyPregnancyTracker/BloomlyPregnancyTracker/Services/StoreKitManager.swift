import Foundation
import StoreKit

@MainActor
@Observable
final class StoreKitManager {
    static let shared = StoreKitManager()

    static let monthlyID = "com.office.bloomly.plus.monthly"
    static let yearlyID = "com.office.bloomly.plus.yearly"
    static let lifetimeID = "com.office.bloomly.plus.lifetime"

    var products: [Product] = []
    var isPremium = false
    var isLoading = false

    nonisolated(unsafe) private var updateTask: Task<Void, Never>?

    init() {
        updateTask = Task { await listenForTransactions() }
    }

    deinit {
        updateTask?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: [Self.monthlyID, Self.yearlyID, Self.lifetimeID])
                .sorted { $0.price < $1.price }
        } catch {
            products = []
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await refreshPremiumStatus()
            return true
        case .userCancelled, .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        try? await AppStore.sync()
        await refreshPremiumStatus()
    }

    func refreshPremiumStatus() async {
        var premium = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               [Self.monthlyID, Self.yearlyID, Self.lifetimeID].contains(transaction.productID) {
                premium = true
            }
        }
        isPremium = premium
    }

    private func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result) {
                await transaction.finish()
                await refreshPremiumStatus()
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw StoreError.failedVerification
        case .verified(let safe): return safe
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
