import SwiftUI

struct AppLanguage: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let nativeName: String
    let flag: String

    var locale: Locale { Locale(identifier: id) }
}

enum LanguageRegistry {
    static let all: [AppLanguage] = [
        AppLanguage(id: "en", nameKey: "language.english", nativeName: "English", flag: "🇺🇸"),
        AppLanguage(id: "es", nameKey: "language.spanish", nativeName: "Español", flag: "🇪🇸"),
        AppLanguage(id: "fr", nameKey: "language.french", nativeName: "Français", flag: "🇫🇷"),
        AppLanguage(id: "de", nameKey: "language.german", nativeName: "Deutsch", flag: "🇩🇪"),
        AppLanguage(id: "it", nameKey: "language.italian", nativeName: "Italiano", flag: "🇮🇹"),
        AppLanguage(id: "pt", nameKey: "language.portuguese", nativeName: "Português", flag: "🇧🇷"),
        AppLanguage(id: "ar", nameKey: "language.arabic", nativeName: "العربية", flag: "🇸🇦"),
        AppLanguage(id: "hi", nameKey: "language.hindi", nativeName: "हिन्दी", flag: "🇮🇳"),
        AppLanguage(id: "bn", nameKey: "language.bengali", nativeName: "বাংলা", flag: "🇧🇩"),
        AppLanguage(id: "ja", nameKey: "language.japanese", nativeName: "日本語", flag: "🇯🇵"),
        AppLanguage(id: "ko", nameKey: "language.korean", nativeName: "한국어", flag: "🇰🇷"),
        AppLanguage(id: "zh-Hans", nameKey: "language.chinese", nativeName: "简体中文", flag: "🇨🇳"),
        AppLanguage(id: "ru", nameKey: "language.russian", nativeName: "Русский", flag: "🇷🇺"),
        AppLanguage(id: "uk", nameKey: "language.ukrainian", nativeName: "Українська", flag: "🇺🇦"),
        AppLanguage(id: "nl", nameKey: "language.dutch", nativeName: "Nederlands", flag: "🇳🇱"),
        AppLanguage(id: "sv", nameKey: "language.swedish", nativeName: "Svenska", flag: "🇸🇪"),
        AppLanguage(id: "tr", nameKey: "language.turkish", nativeName: "Türkçe", flag: "🇹🇷"),
        AppLanguage(id: "pl", nameKey: "language.polish", nativeName: "Polski", flag: "🇵🇱"),
        AppLanguage(id: "vi", nameKey: "language.vietnamese", nativeName: "Tiếng Việt", flag: "🇻🇳"),
        AppLanguage(id: "th", nameKey: "language.thai", nativeName: "ไทย", flag: "🇹🇭"),
        AppLanguage(id: "id", nameKey: "language.indonesian", nativeName: "Bahasa Indonesia", flag: "🇮🇩"),
        AppLanguage(id: "ms", nameKey: "language.malay", nativeName: "Bahasa Melayu", flag: "🇲🇾"),
        AppLanguage(id: "he", nameKey: "language.hebrew", nativeName: "עברית", flag: "🇮🇱"),
        AppLanguage(id: "el", nameKey: "language.greek", nativeName: "Ελληνικά", flag: "🇬🇷"),
        AppLanguage(id: "ro", nameKey: "language.romanian", nativeName: "Română", flag: "🇷🇴")
    ]

    static func language(for id: String) -> AppLanguage {
        all.first { $0.id == id } ?? all[0]
    }
}

@Observable
final class LanguageManager {
    static let shared = LanguageManager()

    private static let storageKey = "bloomly.selectedLanguage"

    var selectedLanguageID: String {
        didSet {
            guard selectedLanguageID != oldValue else { return }
            UserDefaults.standard.set(selectedLanguageID, forKey: Self.storageKey)
            currentLanguage = LanguageRegistry.language(for: selectedLanguageID)
            L10n.resetCache()
        }
    }

    var currentLanguage: AppLanguage

    var locale: Locale { currentLanguage.locale }

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.storageKey) ?? "en"
        selectedLanguageID = stored
        currentLanguage = LanguageRegistry.language(for: stored)
    }

    func selectLanguage(_ language: AppLanguage) {
        selectedLanguageID = language.id
    }
}
