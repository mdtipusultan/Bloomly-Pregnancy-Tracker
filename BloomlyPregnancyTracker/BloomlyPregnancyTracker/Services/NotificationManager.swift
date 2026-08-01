import Foundation
import UserNotifications

enum NotificationManager {
    private static let waterReminderPrefix = "bloomly-water-"
    private static let foodReminderPrefix = "bloomly-food-"

    private static let waterReminderHours = [8, 10, 12, 14, 16, 18, 20]

    private static let foodReminders: [(id: String, title: String, body: String, hour: Int, minute: Int)] = [
        ("breakfast", "Breakfast Time", "Start your day with a nutritious meal for you and baby.", 8, 0),
        ("lunch", "Lunch Time", "Time for a balanced lunch — protein and veggies are great choices.", 12, 30),
        ("snack", "Healthy Snack", "A light snack can help keep your energy up.", 15, 30),
        ("dinner", "Dinner Time", "Enjoy a wholesome dinner to end your day.", 18, 30)
    ]

    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func syncDailyReminders(waterEnabled: Bool, foodEnabled: Bool) async {
        cancelDailyReminders()

        if waterEnabled {
            for (index, hour) in waterReminderHours.enumerated() {
                await scheduleRepeatingReminder(
                    identifier: "\(waterReminderPrefix)\(index)",
                    title: "Time to Hydrate",
                    body: "Stay healthy — drink a glass of water.",
                    hour: hour,
                    minute: 0
                )
            }
        }

        if foodEnabled {
            for meal in foodReminders {
                await scheduleRepeatingReminder(
                    identifier: "\(foodReminderPrefix)\(meal.id)",
                    title: meal.title,
                    body: meal.body,
                    hour: meal.hour,
                    minute: meal.minute
                )
            }
        }
    }

    static func cancelDailyReminders() {
        let waterIDs = waterReminderHours.indices.map { "\(waterReminderPrefix)\($0)" }
        let foodIDs = foodReminders.map { "\(foodReminderPrefix)\($0.id)" }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: waterIDs + foodIDs)
    }

    private static func scheduleRepeatingReminder(
        identifier: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await UNUserNotificationCenter.current().add(request)
    }

    static func scheduleAppointmentReminders(for appointment: Appointment, id: String = UUID().uuidString) async -> String {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id, "\(id)-1h"])

        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: appointment.date)
        if let dayBefore, dayBefore > .now {
            let content = UNMutableNotificationContent()
            content.title = "Appointment Tomorrow"
            content.body = "\(appointment.title) is scheduled for tomorrow."
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dayBefore),
                repeats: false
            )
            try? await center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }

        let hourBefore = Calendar.current.date(byAdding: .hour, value: -1, to: appointment.date)
        if let hourBefore, hourBefore > .now {
            let content = UNMutableNotificationContent()
            content.title = "Appointment in 1 Hour"
            content.body = "\(appointment.title) starts soon."
            content.sound = .default
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: hourBefore),
                repeats: false
            )
            try? await center.add(UNNotificationRequest(identifier: "\(id)-1h", content: content, trigger: trigger))
        }
        return id
    }

    static func cancelAppointmentReminders(id: String?) {
        guard let id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id, "\(id)-1h"])
    }
}
