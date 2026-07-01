import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var profiles: [UserProfile]
    @State private var showPaywall = false

    var body: some View {
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
