import SwiftUI

enum BloomlyTheme {
    private static var palette: BloomlyThemePalette {
        ThemeManager.shared.palette
    }

    static var blush: Color { palette.blush }
    static var blushDark: Color { palette.blushDark }
    static var cream: Color { palette.cream }
    static var creamDark: Color { palette.creamDark }
    static var sage: Color { palette.sage }
    static var sageDark: Color { palette.sageDark }
    static var textPrimary: Color { palette.textPrimary }
    static var textSecondary: Color { palette.textSecondary }
    static var cardBackground: Color { palette.cardBackground }

    static var backgroundGradient: LinearGradient { palette.backgroundGradient }
    static var primaryGradient: LinearGradient { palette.primaryGradient }

    static func moodColor(for mood: Int) -> Color {
        palette.moodColor(for: mood)
    }

    static func severityColor(_ severity: String) -> Color {
        palette.severityColor(severity)
    }
}

struct BloomlyCard: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    func body(content: Content) -> some View {
        let palette = themeManager.palette
        content
            .padding()
            .background(palette.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: palette.blushDark.opacity(0.12), radius: 8, y: 4)
    }
}

struct BloomlyScreenBackground: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    @ViewBuilder
    func body(content: Content) -> some View {
        let gradient = themeManager.palette.backgroundGradient
        if #available(iOS 18.0, *) {
            content.containerBackground(gradient, for: .navigation)
        } else {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    gradient.ignoresSafeArea()
                }
        }
    }
}

struct BloomlyThemedList: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    @ViewBuilder
    func body(content: Content) -> some View {
        let palette = themeManager.palette
        let styled = content
            .scrollContentBackground(.hidden)
            .listRowBackground(palette.cardBackground)
            .listRowSeparatorTint(palette.textSecondary.opacity(0.25))
            .foregroundStyle(palette.textPrimary)
            .tint(palette.sageDark)

        if #available(iOS 18.0, *) {
            styled.containerBackground(palette.backgroundGradient, for: .navigation)
        } else {
            styled
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    palette.backgroundGradient.ignoresSafeArea()
                }
        }
    }
}

struct BloomlyThemedNavigation: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    func body(content: Content) -> some View {
        let palette = themeManager.palette
        content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(palette.id == "dark" || palette.id == "midnight" ? .dark : .light, for: .navigationBar)
    }
}

/// Keeps SwiftUI in sync when the user changes app theme.
struct ThemeEnvironmentModifier: ViewModifier {
    @State private var themeManager = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            .environment(themeManager)
            .id(themeManager.selectedThemeID)
    }
}

extension View {
    func bloomlyCard() -> some View {
        modifier(BloomlyCard())
    }

    func bloomlyScreenBackground() -> some View {
        modifier(BloomlyScreenBackground())
    }

    func bloomlyThemedList() -> some View {
        modifier(BloomlyThemedList())
    }

    func bloomlyThemedNavigation() -> some View {
        modifier(BloomlyThemedNavigation())
    }

    func bloomlyThemeAware() -> some View {
        modifier(ThemeEnvironmentModifier())
    }
}
