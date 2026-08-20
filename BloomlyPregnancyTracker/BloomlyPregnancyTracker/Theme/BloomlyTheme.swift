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
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(8)
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

/// Apply to List rows or a `Group` wrapping sections. `listRowBackground` on the List itself is ignored.
struct BloomlyListRowBackground: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    func body(content: Content) -> some View {
        content
            .listRowBackground(themeManager.palette.cardBackground)
    }
}

struct BloomlyListSectionHeader: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String

    var body: some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(themeManager.palette.textSecondary)
            .textCase(nil)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 16)
            .padding(.bottom, 4)
    }
}

struct BloomlyGroupedSection<Content: View>: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(themeManager.palette.textSecondary)
                .textCase(nil)
                .padding(.horizontal, 4)

            VStack(spacing: 0) {
                content()
            }
            .foregroundStyle(themeManager.palette.textPrimary)
            .tint(themeManager.palette.sageDark)
            .background(themeManager.palette.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

struct BloomlyGroupedLabeledRow: View {
    @Environment(ThemeManager.self) private var themeManager
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(themeManager.palette.textSecondary)
        }
        .bloomlyGroupedRow()
    }
}

struct BloomlyGroupedButtonRow<Label: View>: View {
    let action: () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(action: action) {
            label()
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .bloomlyGroupedRow()
    }
}

struct BloomlyGroupedDivider: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Divider()
            .overlay(themeManager.palette.textSecondary.opacity(0.2))
            .padding(.leading, 16)
    }
}

struct BloomlyGroupedRow<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .bloomlyGroupedRow()
    }
}

struct BloomlyThemedScrollContent: ViewModifier {
    @Environment(ThemeManager.self) private var themeManager

    func body(content: Content) -> some View {
        content.foregroundStyle(themeManager.palette.textPrimary)
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

    func bloomlyListRowBackground() -> some View {
        modifier(BloomlyListRowBackground())
    }

    func bloomlyThemedScrollContent() -> some View {
        modifier(BloomlyThemedScrollContent())
    }

    func bloomlyThemedNavigation() -> some View {
        modifier(BloomlyThemedNavigation())
    }

    func bloomlyThemeAware() -> some View {
        modifier(ThemeEnvironmentModifier())
    }

    func bloomlyGroupedRow() -> some View {
        padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
