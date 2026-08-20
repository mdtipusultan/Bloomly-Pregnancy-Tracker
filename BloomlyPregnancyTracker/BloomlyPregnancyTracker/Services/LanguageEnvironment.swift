import SwiftUI

extension LanguageManager {
    var layoutDirection: LayoutDirection {
        switch selectedLanguageID {
        case "ar", "he":
            return .rightToLeft
        default:
            return .leftToRight
        }
    }
}

/// Keeps SwiftUI in sync when the user changes app language.
struct LanguageEnvironmentModifier: ViewModifier {
    @State private var languageManager = LanguageManager.shared

    func body(content: Content) -> some View {
        content
            .environment(languageManager)
            .environment(\.locale, languageManager.locale)
            .environment(\.layoutDirection, languageManager.layoutDirection)
            .id(languageManager.selectedLanguageID)
    }
}

extension View {
    func bloomlyLanguageAware() -> some View {
        modifier(LanguageEnvironmentModifier())
    }
}
