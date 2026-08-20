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
            Group {
                if notificationsDenied {
                    Section {
                        Button {
                            NotificationManager.openNotificationSettings()
                        } label: {
                            Label {
                                Text(L10n.t("reminders.notificationsDisabled"))
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
                        Toggle(L10n.t("reminders.waterReminders"), isOn: waterReminderBinding(for: profile))
                        Toggle(L10n.t("reminders.mealReminders"), isOn: foodReminderBinding(for: profile))
                    }
                } footer: {
                    Text(L10n.t("reminders.footer"))
                }

                Section {
                    ForEach(NotificationManager.waterReminderSchedule, id: \.self) { time in
                        Label(time, systemImage: "drop.fill")
                            .foregroundStyle(BloomlyTheme.sageDark)
                    }
                } header: {
                    BloomlyListSectionHeader(title: L10n.t("reminders.waterSchedule"))
                }

                Section {
                    ForEach(NotificationManager.localizedFoodReminderSchedule, id: \.label) { meal in
                        HStack {
                            Label(meal.label, systemImage: meal.icon)
                                .foregroundStyle(BloomlyTheme.blushDark)
                            Spacer()
                            Text(meal.time)
                                .foregroundStyle(BloomlyTheme.textSecondary)
                        }
                    }
                } header: {
                    BloomlyListSectionHeader(title: L10n.t("reminders.mealSchedule"))
                }
            }
            .bloomlyListRowBackground()
        }
        .bloomlyThemedList()
        .navigationTitle(L10n.profileDailyReminders)
        .bloomlyThemedNavigation()
        .bloomlyThemeAware()
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

    static var localizedFoodReminderSchedule: [(label: String, time: String, icon: String)] {
        [
            (L10n.t("reminders.breakfast"), "8:00 AM", "sunrise.fill"),
            (L10n.t("reminders.lunch"), "12:30 PM", "sun.max.fill"),
            (L10n.t("reminders.snack"), "3:30 PM", "carrot.fill"),
            (L10n.t("reminders.dinner"), "6:30 PM", "moon.stars.fill")
        ]
    }

    static var foodReminderSchedule: [(label: String, time: String, icon: String)] {
        localizedFoodReminderSchedule
    }
}
