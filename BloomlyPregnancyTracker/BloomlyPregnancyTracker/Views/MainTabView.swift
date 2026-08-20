import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(LanguageManager.self) private var languageManager

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label(L10n.tabHome, systemImage: "house.fill") }
            WeekGuideView()
                .tabItem { Label(L10n.tabWeekGuide, systemImage: "calendar") }
            DailyLogView()
                .tabItem { Label(L10n.tabDailyLog, systemImage: "square.and.pencil") }
            ToolsView()
                .tabItem { Label(L10n.tabTools, systemImage: "wrench.and.screwdriver.fill") }
            ProfileView()
                .tabItem { Label(L10n.tabProfile, systemImage: "person.fill") }
        }
        .tint(themeManager.palette.sageDark)
        .toolbarBackground(themeManager.palette.cream, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarColorScheme(
            themeManager.palette.id == "dark" || themeManager.palette.id == "midnight" ? .dark : .light,
            for: .tabBar
        )
        .background {
            themeManager.palette.backgroundGradient
                .ignoresSafeArea()
        }
        .bloomlySystemAppearance()
        .background {
            BloomlyChromeRefresh(
                themeID: themeManager.selectedThemeID,
                languageID: languageManager.selectedLanguageID
            )
        }
        .bloomlyLanguageAware()
        .bloomlyThemeAware()
    }
}
