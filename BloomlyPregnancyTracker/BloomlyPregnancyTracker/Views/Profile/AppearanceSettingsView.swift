import SwiftUI

struct AppearanceSettingsView: View {
    @Environment(ThemeManager.self) private var themeManager

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(L10n.settingsAppearanceSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .padding(.horizontal, 4)

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(ThemeRegistry.all) { theme in
                        ThemeCard(
                            theme: theme,
                            isSelected: themeManager.selectedThemeID == theme.id
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                themeManager.selectTheme(theme)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.settingsAppearance)
        .bloomlyThemedNavigation()
    }
}

private struct ThemeCard: View {
    let theme: BloomlyThemePalette
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(theme.backgroundGradient)
                        .frame(height: 72)

                    HStack(spacing: 6) {
                        Circle().fill(theme.sage).frame(width: 18, height: 18)
                        Circle().fill(theme.blush).frame(width: 18, height: 18)
                        Circle().fill(theme.sageDark).frame(width: 18, height: 18)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(isSelected ? theme.sageDark : Color.clear, lineWidth: 3)
                }

                HStack(spacing: 4) {
                    Image(systemName: theme.icon)
                        .font(.caption2)
                    Text(L10n.t(theme.nameKey))
                        .font(.caption.weight(.medium))
                        .lineLimit(1)
                }
                .foregroundStyle(BloomlyTheme.textPrimary)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(theme.sageDark)
                }
            }
            .padding(10)
            .background(BloomlyTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: BloomlyTheme.blushDark.opacity(0.08), radius: 6, y: 3)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AppearanceSettingsView()
    }
    .environment(ThemeManager.shared)
}
