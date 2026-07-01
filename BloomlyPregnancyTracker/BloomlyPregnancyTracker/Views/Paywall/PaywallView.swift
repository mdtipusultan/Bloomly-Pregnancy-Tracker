import SwiftUI
import _SwiftData_SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
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
                        Text("Bloomly Plus")
                            .font(.title.bold())
                        Text("Unlock the full wellness experience")
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    .padding(.top)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("Full symptom & weight logging")
                        featureRow("Wellness tools: Kegel, kick & contraction timers")
                        featureRow("Appointments with reminders")
                        featureRow("Statistics & history charts")
                        featureRow("Trimester-aware nutrition guide")
                    }
                    .bloomlyCard()

                    if store.isLoading {
                        ProgressView()
                    } else if store.products.isEmpty {
                        Text("Subscriptions will appear when configured in App Store Connect.")
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

                    Button("Restore Purchases") {
                        Task { await store.restorePurchases(); syncPremium() }
                    }
                    .font(.subheadline)

                    Button("Start Free") {
                        finish()
                    }
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.sageDark)
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationBarTitleDisplayMode(.inline)
        }
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
                errorMessage = "Purchase could not be completed."
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
