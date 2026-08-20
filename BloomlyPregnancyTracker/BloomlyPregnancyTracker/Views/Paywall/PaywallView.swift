import SwiftUI
import _SwiftData_SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(LanguageManager.self) private var languageManager
    @Query private var profiles: [UserProfile]
    @State private var store = StoreKitManager.shared
    @State private var isPurchasing = false
    @State private var errorMessage: String?
    @State private var selectedProductID: String?

    var onComplete: () -> Void

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    private var palette: BloomlyThemePalette { themeManager.palette }

    private var selectedProduct: Product? {
        guard let id = selectedProductID else { return preferredDefaultProduct }
        return store.products.first { $0.id == id } ?? preferredDefaultProduct
    }

    private var preferredDefaultProduct: Product? {
        store.products.first { $0.id == StoreKitManager.yearlyID }
            ?? store.products.first
    }

    private var yearlySavingsPercent: Int? {
        guard
            let monthly = store.products.first(where: { $0.id == StoreKitManager.monthlyID }),
            let yearly = store.products.first(where: { $0.id == StoreKitManager.yearlyID })
        else { return nil }

        let monthlyYear = NSDecimalNumber(decimal: monthly.price).doubleValue * 12
        let yearlyPrice = NSDecimalNumber(decimal: yearly.price).doubleValue
        guard monthlyYear > 0, yearlyPrice < monthlyYear else { return nil }
        return Int((((monthlyYear - yearlyPrice) / monthlyYear) * 100).rounded())
    }

    var body: some View {
        ZStack {
            palette.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                GeometryReader { geo in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 22) {
                            heroSection
                                .frame(height: 300 + geo.safeAreaInsets.top)
                                .padding(.top, -geo.safeAreaInsets.top)

                            featuresSection
                            plansSection
                            footerActions
                        }
                        .frame(width: geo.size.width)
                        .padding(.bottom, 16)
                    }
                }

                purchaseBar
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                finish()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background {
                        Circle().fill(.ultraThinMaterial)
                    }
                    .overlay {
                        Circle().strokeBorder(.white.opacity(0.35), lineWidth: 0.8)
                    }
            }
            .padding(.top, 8)
            .padding(.trailing, 16)
        }
        .bloomlyThemeAware()
        .bloomlyLanguageAware()
        .id(languageManager.selectedLanguageID)
        .task {
            await store.loadProducts()
            await store.refreshPremiumStatus()
            syncPremium()
            if selectedProductID == nil {
                selectedProductID = preferredDefaultProduct?.id
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            Image("PaywallHero")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .clipped()

            LinearGradient(
                colors: [
                    .clear,
                    palette.cream.opacity(0.12),
                    palette.cream.opacity(0.88),
                    palette.cream
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 8) {
                Text(L10n.paywallHeroCare)
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundStyle(palette.sageDark)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(palette.sage.opacity(0.28), in: Capsule())

                Text(L10n.paywallTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(palette.textPrimary)

                Text(L10n.paywallSubtitle)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(palette.textSecondary)
                    .padding(.horizontal, 28)
            }
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .clipped()
    }

    // MARK: - Features

    private var featuresSection: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                featureChip(icon: "heart.fill", label: L10n.paywallFeatureTools)
                featureChip(icon: "chart.line.uptrend.xyaxis", label: L10n.paywallFeatureStatistics)
                featureChip(icon: "leaf.fill", label: L10n.paywallFeatureNutrition)
            }
            .padding(.horizontal, 20)

            VStack(spacing: 0) {
                paywallFeature(icon: "list.bullet.clipboard.fill", title: L10n.paywallFeatureSymptoms, tint: palette.blushDark)
                paywallDivider
                paywallFeature(icon: "heart.circle.fill", title: L10n.paywallFeatureTools, tint: palette.sageDark)
                paywallDivider
                paywallFeature(icon: "calendar.badge.clock", title: L10n.paywallFeatureAppointments, tint: palette.sage)
                paywallDivider
                paywallFeature(icon: "chart.bar.fill", title: L10n.paywallFeatureStatistics, tint: palette.blushDark)
                paywallDivider
                paywallFeature(icon: "leaf.fill", title: L10n.paywallFeatureNutrition, tint: palette.sageDark)
            }
            .padding(.vertical, 4)
            .background(palette.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: palette.blushDark.opacity(0.1), radius: 14, y: 6)
            .padding(.horizontal, 20)
        }
    }

    private func featureChip(icon: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.sageDark)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(palette.textSecondary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(palette.cardBackground.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(palette.sage.opacity(0.22), lineWidth: 1)
        }
    }

    private var paywallDivider: some View {
        Divider()
            .overlay(palette.textSecondary.opacity(0.15))
            .padding(.leading, 68)
    }

    private func paywallFeature(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.14))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
            }

            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.textPrimary)

            Spacer(minLength: 0)

            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundStyle(palette.sageDark)
                .padding(6)
                .background(palette.sage.opacity(0.18))
                .clipShape(Circle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Plans

    @ViewBuilder
    private var plansSection: some View {
        VStack(spacing: 12) {
            if store.isLoading {
                ProgressView()
                    .padding(.vertical, 24)
            } else if store.products.isEmpty {
                Text(L10n.paywallSubscriptionsPlaceholder)
                    .font(.subheadline)
                    .foregroundStyle(palette.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 24)
            } else {
                ForEach(store.products, id: \.id) { product in
                    planCard(product)
                }
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
        }
        .padding(.horizontal, 20)
    }

    private func planCard(_ product: Product) -> some View {
        let isSelected = selectedProductID == product.id
            || (selectedProductID == nil && product.id == preferredDefaultProduct?.id)
        let isBestValue = product.id == StoreKitManager.yearlyID
        let isOwned = store.isPurchased(product.id)

        return VStack(spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.78)) {
                    selectedProductID = product.id
                }
            } label: {
                HStack(alignment: .top, spacing: 12) {
                    selectionIndicator(isSelected: isSelected, isOwned: isOwned)

                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(product.displayName)
                                .font(.headline)
                                .foregroundStyle(palette.textPrimary)

                            if isBestValue {
                                Text(L10n.paywallBestValue)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(palette.primaryGradient, in: Capsule())
                            }

                            if isOwned {
                                Text(L10n.paywallPurchased)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(palette.sageDark)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(palette.sage.opacity(0.22), in: Capsule())
                            }
                        }

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(product.displayPrice)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(palette.textPrimary)
                            Text(periodLabel(for: product))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(palette.textSecondary)
                        }

                        if isBestValue, let yearlySavingsPercent {
                            Text(L10n.paywallSavePercent(yearlySavingsPercent))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(palette.sageDark)
                        } else if !product.description.isEmpty {
                            Text(product.description)
                                .font(.caption)
                                .foregroundStyle(palette.textSecondary)
                                .lineLimit(2)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            planActionButton(for: product, isOwned: isOwned)
        }
        .padding(16)
        .background(palette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    isSelected ? palette.sageDark : palette.sage.opacity(0.22),
                    lineWidth: isSelected ? 2.5 : 1
                )
        }
        .shadow(
            color: isSelected ? palette.sageDark.opacity(0.18) : palette.blushDark.opacity(0.08),
            radius: isSelected ? 16 : 8,
            y: isSelected ? 8 : 4
        )
        .scaleEffect(isSelected ? 1.01 : 1)
        .disabled(isPurchasing)
    }

    private func selectionIndicator(isSelected: Bool, isOwned: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isSelected || isOwned ? palette.sageDark : palette.textSecondary.opacity(0.35),
                    lineWidth: 2
                )
                .frame(width: 22, height: 22)

            if isOwned {
                Circle()
                    .fill(palette.sageDark)
                    .frame(width: 14, height: 14)
                Image(systemName: "checkmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white)
            } else if isSelected {
                Circle()
                    .fill(palette.sageDark)
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.top, 2)
    }

    private func planActionButton(for product: Product, isOwned: Bool) -> some View {
        Button {
            if isOwned {
                selectedProductID = product.id
            } else {
                selectedProductID = product.id
                purchase(product)
            }
        } label: {
            HStack(spacing: 6) {
                if isPurchasing, selectedProductID == product.id, !isOwned {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: isOwned ? "checkmark.circle.fill" : "bag.fill")
                        .font(.subheadline.weight(.semibold))
                    Text(isOwned ? L10n.paywallPurchased : L10n.paywallContinuePrice(product.displayPrice))
                        .font(.subheadline.weight(.semibold))
                }
            }
            .foregroundStyle(isOwned ? palette.sageDark : .white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background {
                if isOwned {
                    Capsule().fill(palette.sage.opacity(0.22))
                } else {
                    Capsule().fill(palette.primaryGradient)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing || isOwned)
        .accessibilityLabel(isOwned ? L10n.paywallPurchased : L10n.paywallContinuePrice(product.displayPrice))
    }

    // MARK: - Footer + sticky bar

    private var footerActions: some View {
        VStack(spacing: 12) {
            Button(L10n.paywallRestore) {
                Task {
                    await store.restorePurchases()
                    syncPremium()
                    if let owned = store.products.first(where: { store.isPurchased($0.id) }) {
                        selectedProductID = owned.id
                    }
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(palette.sageDark)

            Button(L10n.paywallStartFree) {
                finish()
            }
            .font(.subheadline)
            .foregroundStyle(palette.textSecondary)

            Text(L10n.paywallLegal)
                .font(.caption2)
                .foregroundStyle(palette.textSecondary.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 4)
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private var purchaseBar: some View {
        if let product = selectedProduct, !store.products.isEmpty {
            let isOwned = store.isPurchased(product.id)
            VStack(spacing: 8) {
                Divider().opacity(0.35)

                Button {
                    if !isOwned {
                        purchase(product)
                    }
                } label: {
                    HStack(spacing: 8) {
                        if isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: isOwned ? "checkmark.circle.fill" : "sparkles")
                                .font(.subheadline.weight(.semibold))
                            Text(isOwned ? L10n.paywallPurchased : L10n.paywallContinuePrice(product.displayPrice))
                                .font(.headline)
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        isOwned
                            ? AnyShapeStyle(palette.sageDark.opacity(0.55))
                            : AnyShapeStyle(palette.primaryGradient)
                    )
                    .clipShape(Capsule())
                    .shadow(color: palette.sageDark.opacity(isOwned ? 0.12 : 0.32), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .disabled(isPurchasing || isOwned)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 10)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Helpers

    private func periodLabel(for product: Product) -> String {
        guard let period = product.subscription?.subscriptionPeriod else {
            return L10n.paywallOneTime
        }
        switch period.unit {
        case .year:
            return L10n.paywallPerYear
        case .month:
            return L10n.paywallPerMonth
        default:
            return product.displayName
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
