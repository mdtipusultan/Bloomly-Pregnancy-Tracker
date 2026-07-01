import Foundation
import UserNotifications

enum NotificationManager {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
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
