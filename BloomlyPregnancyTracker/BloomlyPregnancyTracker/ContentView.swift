import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(LanguageManager.self) private var languageManager
    @Query private var profiles: [UserProfile]
    @State private var showPaywall = false
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .animation(.easeOut(duration: 0.4), value: showSplash)
        .bloomlySystemAppearance()
        .bloomlyLanguageAware()
        .task {
            try? await Task.sleep(for: .seconds(2))
            showSplash = false
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        Group {
            if let profile = profiles.first, profile.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView(showPaywall: $showPaywall)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onComplete: {})
        }
        .id("\(themeManager.selectedThemeID)-\(languageManager.selectedLanguageID)-main")
        .onChange(of: languageManager.selectedLanguageID) { _, _ in
            WidgetDataSync.sync(profile: profiles.first)
        }
    }
}

#Preview {
    ContentView()
        .environment(ThemeManager.shared)
        .environment(LanguageManager.shared)
        .modelContainer(for: [
            UserProfile.self, DailyLog.self, Appointment.self,
            KickSession.self, ContractionSession.self, SavedName.self, PeriodLog.self,
            BumpPhoto.self
        ], inMemory: true)
}
