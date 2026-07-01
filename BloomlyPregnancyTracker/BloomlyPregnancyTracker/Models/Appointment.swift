import Foundation
import SwiftData

@Model
final class Appointment {
    var date: Date
    var title: String
    var location: String?
    var type: String
    var notificationID: String?

    init(date: Date, title: String, location: String? = nil, type: String = "checkup", notificationID: String? = nil) {
        self.date = date
        self.title = title
        self.location = location
        self.type = type
        self.notificationID = notificationID
    }
}
