import SwiftUI
import SwiftData
import UserNotifications

struct ReminderSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Query private var profiles: [UserProfile]
    @State private var notificationsDenied = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        List {
            if notificationsDenied {
                Section {
                    Button {
                        NotificationManager.openNotificationSettings()
                    } label: {
                        Label {
                            Text("Notifications are disabled. Tap here to open Settings and enable them for Bloomly.")
                                .font(.subheadline)
                                .foregroundStyle(BloomlyTheme.textPrimary)
                        } icon: {
                            Image(systemName: "bell.slash.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            Section {
                if let profile {
                    Toggle("Water Reminders", isOn: waterReminderBinding(for: profile))
                    Toggle("Meal Reminders", isOn: foodReminderBinding(for: profile))
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
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task { await checkNotificationStatus() }
        }
    }

    private func waterReminderBinding(for profile: UserProfile) -> Binding<Bool> {
        Binding(
            get: { notificationsDenied ? false : profile.waterRemindersEnabled },
            set: { newValue in
                handleReminderToggle(newValue, keyPath: \.waterRemindersEnabled, for: profile)
            }
        )
    }

    private func foodReminderBinding(for profile: UserProfile) -> Binding<Bool> {
        Binding(
            get: { notificationsDenied ? false : profile.foodRemindersEnabled },
            set: { newValue in
                handleReminderToggle(newValue, keyPath: \.foodRemindersEnabled, for: profile)
            }
        )
    }

    private func handleReminderToggle(
        _ newValue: Bool,
        keyPath: ReferenceWritableKeyPath<UserProfile, Bool>,
        for profile: UserProfile
    ) {
        if newValue {
            Task { await enableReminder(keyPath: keyPath, for: profile) }
        } else {
            profile[keyPath: keyPath] = false
            Task { await syncReminders(for: profile) }
        }
    }

    private func enableReminder(
        keyPath: ReferenceWritableKeyPath<UserProfile, Bool>,
        for profile: UserProfile
    ) async {
        await checkNotificationStatus()

        if notificationsDenied {
            NotificationManager.openNotificationSettings()
            return
        }

        let status = await NotificationManager.authorizationStatus()
        if status == .notDetermined {
            let authorized = await NotificationManager.requestAuthorization()
            await checkNotificationStatus()
            guard authorized else {
                await MainActor.run {
                    profile[keyPath: keyPath] = false
                }
                return
            }
        }

        await MainActor.run {
            profile[keyPath: keyPath] = true
        }
        await syncReminders(for: profile)
    }

    private func syncReminders(for profile: UserProfile) async {
        await NotificationManager.syncDailyReminders(
            waterEnabled: profile.waterRemindersEnabled,
            foodEnabled: profile.foodRemindersEnabled
        )
    }

    private func checkNotificationStatus() async {
        let status = await NotificationManager.authorizationStatus()
        let denied = status == .denied

        await MainActor.run {
            notificationsDenied = denied
            if denied, let profile {
                profile.waterRemindersEnabled = false
                profile.foodRemindersEnabled = false
            }
        }

        if denied {
            NotificationManager.cancelDailyReminders()
        }
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
