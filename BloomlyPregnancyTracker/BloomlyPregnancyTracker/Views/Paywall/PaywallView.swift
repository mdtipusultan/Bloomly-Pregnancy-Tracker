import SwiftUI
import _SwiftData_SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @Query private var profiles: [UserProfile]
    @State private var store = StoreKitManager.shared
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    var onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundStyle(BloomlyTheme.blushDark)
                        Text(L10n.paywallTitle)
                            .font(.title.bold())
                        Text(L10n.paywallSubtitle)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    .padding(.top)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow(L10n.paywallFeatureSymptoms)
                        featureRow(L10n.paywallFeatureTools)
                        featureRow(L10n.paywallFeatureAppointments)
                        featureRow(L10n.paywallFeatureStatistics)
                        featureRow(L10n.paywallFeatureNutrition)
                    }
                    .bloomlyCard()

                    if store.isLoading {
                        ProgressView()
                    } else if store.products.isEmpty {
                        Text(L10n.paywallSubscriptionsPlaceholder)
                            .font(.caption)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                            .multilineTextAlignment(.center)
                    } else {
                        ForEach(store.products, id: \.id) { product in
                            Button {
                                purchase(product)
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(product.displayName)
                                            .font(.headline)
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(BloomlyTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text(product.displayPrice)
                                        .font(.headline)
                                }
                                .padding()
                                .background(BloomlyTheme.creamDark)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(isPurchasing)
                        }
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }

                    Button(L10n.paywallRestore) {
                        Task { await store.restorePurchases(); syncPremium() }
                    }
                    .font(.subheadline)

                    Button(L10n.paywallStartFree) {
                        finish()
                    }
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.sageDark)
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .bloomlyThemedNavigation()
        }
        .bloomlyLanguageAware()
        .id(languageManager.selectedLanguageID)
        .task {
            await store.loadProducts()
            await store.refreshPremiumStatus()
            syncPremium()
        }
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(BloomlyTheme.sage)
            Text(text)
                .font(.subheadline)
        }
    }

    private func purchase(_ product: Product) {
        isPurchasing = true
        errorMessage = nil
        Task {
            do {
                let success = try await store.purchase(product)
                if success { syncPremium(); finish() }
            } catch {
                errorMessage = L10n.paywallPurchaseError
            }
            isPurchasing = false
        }
    }

    private func syncPremium() {
        if let profile = profiles.first {
            profile.isPremium = store.isPremium
        }
    }

    private func finish() {
        syncPremium()
        onComplete()
        dismiss()
    }
}
