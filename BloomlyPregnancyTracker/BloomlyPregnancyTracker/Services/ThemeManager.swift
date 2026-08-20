import SwiftUI

@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    private static let storageKey = "bloomly.selectedTheme"
    private static let appGroupThemeKey = "bloomly.theme"

    var selectedThemeID: String {
        didSet {
            guard selectedThemeID != oldValue else { return }
            UserDefaults.standard.set(selectedThemeID, forKey: Self.storageKey)
            BloomlyAppGroup.sharedDefaults?.set(selectedThemeID, forKey: Self.appGroupThemeKey)
            palette = ThemeRegistry.palette(for: selectedThemeID)
        }
    }

    var palette: BloomlyThemePalette

    var selectedTheme: BloomlyThemePalette {
        palette
    }

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey) ?? ThemeRegistry.blush.id
        selectedThemeID = stored
        palette = ThemeRegistry.palette(for: stored)
        BloomlyAppGroup.sharedDefaults?.set(stored, forKey: Self.appGroupThemeKey)
    }

    func selectTheme(_ theme: BloomlyThemePalette) {
        selectedThemeID = theme.id
    }
}
