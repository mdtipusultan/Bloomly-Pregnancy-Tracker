import SwiftUI
import SwiftData

@main
struct Bloomly_PregnancyTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserProfile.self,
            DailyLog.self,
            Appointment.self,
            KickSession.self,
            ContractionSession.self,
            SavedName.self,
            PeriodLog.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    _ = await NotificationManager.requestAuthorization()
                    await StoreKitManager.shared.refreshPremiumStatus()
                    syncPremiumToProfile()
                    await syncDailyReminders()
                }
        }
        .modelContainer(sharedModelContainer)
    }

    @MainActor
    private func syncDailyReminders() async {
        guard let context = try? sharedModelContainer.mainContext,
              let profile = try? context.fetch(FetchDescriptor<UserProfile>()).first else {
            await NotificationManager.syncDailyReminders(waterEnabled: true, foodEnabled: true)
            return
        }
        await NotificationManager.syncDailyReminders(
            waterEnabled: profile.waterRemindersEnabled,
            foodEnabled: profile.foodRemindersEnabled
        )
    }

    @MainActor
    private func syncPremiumToProfile() {
        let premium = StoreKitManager.shared.isPremium
        if let context = try? sharedModelContainer.mainContext,
           let profile = try? context.fetch(FetchDescriptor<UserProfile>()).first {
            profile.isPremium = premium
            try? context.save()
        }
    }
}
