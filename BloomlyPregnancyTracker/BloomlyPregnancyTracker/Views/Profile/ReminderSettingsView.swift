import SwiftUI
import SwiftData
import UserNotifications

struct ReminderSettingsView: View {
    @Query private var profiles: [UserProfile]
    @State private var notificationsDenied = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        List {
            if notificationsDenied {
                Section {
                    Label {
                        Text("Notifications are disabled. Enable them in Settings → Bloomly → Notifications.")
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "bell.slash.fill")
                            .foregroundStyle(.orange)
                    }
                }
            }

            Section {
                if let profile {
                    Toggle("Water Reminders", isOn: Binding(
                        get: { profile.waterRemindersEnabled },
                        set: { newValue in
                            profile.waterRemindersEnabled = newValue
                            Task { await syncReminders(for: profile) }
                        }
                    ))
                    Toggle("Meal Reminders", isOn: Binding(
                        get: { profile.foodRemindersEnabled },
                        set: { newValue in
                            profile.foodRemindersEnabled = newValue
                            Task { await syncReminders(for: profile) }
                        }
                    ))
                }
            } footer: {
                Text("Daily local reminders to help you stay hydrated and eat on schedule.")
            }

            Section("Water Schedule") {
                ForEach(NotificationManager.waterReminderSchedule, id: \.self) { time in
                    Label(time, systemImage: "drop.fill")
                        .foregroundStyle(BloomlyTheme.sageDark)
                }
            }

            Section("Meal Schedule") {
                ForEach(NotificationManager.foodReminderSchedule, id: \.label) { meal in
                    HStack {
                        Label(meal.label, systemImage: meal.icon)
                            .foregroundStyle(BloomlyTheme.blushDark)
                        Spacer()
                        Text(meal.time)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                }
            }
        }
        .navigationTitle("Daily Reminders")
        .task { await checkNotificationStatus() }
    }

    private func syncReminders(for profile: UserProfile) async {
        let authorized = await NotificationManager.requestAuthorization()
        await checkNotificationStatus()
        guard authorized else { return }
        await NotificationManager.syncDailyReminders(
            waterEnabled: profile.waterRemindersEnabled,
            foodEnabled: profile.foodRemindersEnabled
        )
    }

    private func checkNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsDenied = settings.authorizationStatus == .denied
    }
}

extension NotificationManager {
    static var waterReminderSchedule: [String] {
        ["8:00 AM", "10:00 AM", "12:00 PM", "2:00 PM", "4:00 PM", "6:00 PM", "8:00 PM"]
    }

    static var foodReminderSchedule: [(label: String, time: String, icon: String)] {
        [
            ("Breakfast", "8:00 AM", "sunrise.fill"),
            ("Lunch", "12:30 PM", "sun.max.fill"),
            ("Snack", "3:30 PM", "carrot.fill"),
            ("Dinner", "6:30 PM", "moon.stars.fill")
        ]
    }
}
