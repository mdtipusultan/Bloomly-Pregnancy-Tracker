import SwiftUI
import SwiftData

struct ToolsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Query private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if profiles.first?.isPremium == true {
                        NavigationLink { KegelTimerView() } label: {
                            toolCard(
                                title: L10n.toolsKegelTimer,
                                subtitle: L10n.toolsKegelSubtitle,
                                icon: "timer",
                                accent: BloomlyTheme.sageDark
                            )
                        }
                        .buttonStyle(.plain)
                        NavigationLink { KickCounterView() } label: {
                            toolCard(
                                title: L10n.toolsKickCounter,
                                subtitle: L10n.toolsKickSubtitle,
                                icon: "heart.fill",
                                accent: BloomlyTheme.blushDark
                            )
                        }
                        .buttonStyle(.plain)
                        NavigationLink { ContractionTimerView() } label: {
                            toolCard(
                                title: L10n.toolsContractionTimer,
                                subtitle: L10n.toolsContractionSubtitle,
                                icon: "waveform.path",
                                accent: BloomlyTheme.sage
                            )
                        }
                        .buttonStyle(.plain)
                        NavigationLink { HydrationTrackerView() } label: {
                            toolCard(
                                title: L10n.toolsHydration,
                                subtitle: L10n.toolsHydrationSubtitle,
                                icon: "drop.fill",
                                accent: Color.blue
                            )
                        }
                        .buttonStyle(.plain)
                        NavigationLink { WeightTrackerView() } label: {
                            toolCard(
                                title: L10n.toolsWeightTracker,
                                subtitle: L10n.toolsWeightSubtitle,
                                icon: "scalemass.fill",
                                accent: BloomlyTheme.sageDark
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        PremiumGateView(feature: L10n.toolsWellnessGate)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .bloomlyCard()
                    }
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle(L10n.toolsTitle)
            .bloomlyThemedNavigation()
            .bloomlyThemeAware()
            .bloomlyLanguageAware()
        }
    }

    private func toolCard(title: String, subtitle: String, icon: String, accent: Color) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(accent.opacity(0.16))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(accent)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Image(systemName: "chevron.forward")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .padding(16)
        .background(themeManager.palette.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: BloomlyTheme.blushDark.opacity(0.08), radius: 8, y: 4)
    }
}
