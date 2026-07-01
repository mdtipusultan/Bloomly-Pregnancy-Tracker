import Foundation
import SwiftData

@Model
final class PeriodLog {
    var startDate: Date
    var endDate: Date?

    init(startDate: Date, endDate: Date? = nil) {
        self.startDate = Calendar.current.startOfDay(for: startDate)
        self.endDate = endDate.map { Calendar.current.startOfDay(for: $0) }
    }
}
