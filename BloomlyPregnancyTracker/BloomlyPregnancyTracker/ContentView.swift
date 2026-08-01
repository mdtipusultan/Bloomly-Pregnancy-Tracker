import SwiftUI
import SwiftData

struct ContentView: View {
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
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [
            UserProfile.self, DailyLog.self, Appointment.self,
            KickSession.self, ContractionSession.self, SavedName.self, PeriodLog.self
        ], inMemory: true)
}
