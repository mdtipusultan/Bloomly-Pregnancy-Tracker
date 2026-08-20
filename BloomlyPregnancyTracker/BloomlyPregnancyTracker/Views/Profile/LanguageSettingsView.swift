import SwiftUI

struct LanguageSettingsView: View {
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        List {
            Section {
                ForEach(LanguageRegistry.all) { language in
                    Button {
                        withAnimation {
                            languageManager.selectLanguage(language)
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Text(language.flag)
                                .font(.title2)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(language.nativeName)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(BloomlyTheme.textPrimary)
                                Text(L10n.t(language.nameKey))
                                    .font(.caption)
                                    .foregroundStyle(BloomlyTheme.textSecondary)
                            }

                            Spacer()

                            if languageManager.selectedLanguageID == language.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(BloomlyTheme.sageDark)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            } footer: {
                Text(L10n.settingsLanguageFooter)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
        .bloomlyThemedList()
        .bloomlyScreenBackground()
        .navigationTitle(L10n.settingsLanguage)
        .bloomlyThemedNavigation()
        .bloomlyLanguageAware()
    }
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
    .environment(LanguageManager.shared)
    .environment(\.locale, Locale(identifier: "en"))
}
