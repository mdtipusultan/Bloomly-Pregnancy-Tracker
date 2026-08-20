import SwiftUI
import UIKit

enum BloomlySystemAppearance {
    static func apply(palette: BloomlyThemePalette) {
        applyTabBar(palette: palette)
        applyNavigationBar(palette: palette)
        applyListSection(palette: palette)
    }

    private static func applyTabBar(palette: BloomlyThemePalette) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(palette.cream)
        appearance.shadowColor = UIColor(palette.textSecondary.opacity(0.15))

        let normal = appearance.stackedLayoutAppearance
        normal.normal.iconColor = UIColor(palette.textSecondary)
        normal.normal.titleTextAttributes = [.foregroundColor: UIColor(palette.textSecondary)]
        normal.selected.iconColor = UIColor(palette.sageDark)
        normal.selected.titleTextAttributes = [.foregroundColor: UIColor(palette.sageDark)]

        let inline = appearance.inlineLayoutAppearance
        inline.normal.iconColor = UIColor(palette.textSecondary)
        inline.selected.iconColor = UIColor(palette.sageDark)

        let compact = appearance.compactInlineLayoutAppearance
        compact.normal.iconColor = UIColor(palette.textSecondary)
        compact.selected.iconColor = UIColor(palette.sageDark)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = UIColor(palette.sageDark)
        UITabBar.appearance().unselectedItemTintColor = UIColor(palette.textSecondary)
    }

    private static func applyNavigationBar(palette: BloomlyThemePalette) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor(palette.textPrimary)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(palette.textPrimary)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        UINavigationBar.appearance().prefersLargeTitles = false
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor(palette.sageDark)
    }

    private static func applyListSection(palette: BloomlyThemePalette) {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = UIColor(palette.cardBackground)
    }
}

struct BloomlySystemAppearanceModifier: ViewModifier {
    @State private var themeManager = ThemeManager.shared
    @State private var languageManager = LanguageManager.shared

    func body(content: Content) -> some View {
        content
            .onAppear { apply() }
            .onChange(of: themeManager.selectedThemeID) { _, _ in apply() }
            .onChange(of: languageManager.selectedLanguageID) { _, _ in apply() }
    }

    private func apply() {
        BloomlySystemAppearance.apply(palette: themeManager.palette)
    }
}

extension View {
    func bloomlySystemAppearance() -> some View {
        modifier(BloomlySystemAppearanceModifier())
    }
}

/// Re-applies UIKit chrome when the view tree is rebuilt after theme/language changes.
struct BloomlyChromeRefresh: View {
    let themeID: String
    let languageID: String

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear {
                BloomlySystemAppearance.apply(palette: ThemeManager.shared.palette)
            }
            .id("\(themeID)-\(languageID)")
    }
}
