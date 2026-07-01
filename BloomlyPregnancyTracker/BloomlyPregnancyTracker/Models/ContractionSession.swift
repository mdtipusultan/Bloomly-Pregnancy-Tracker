import Foundation
import SwiftData

@Model
final class ContractionSession {
    var startTime: Date
    var endTime: Date?
    var intervalFromPrevious: Double?

    init(startTime: Date = .now, endTime: Date? = nil, intervalFromPrevious: Double? = nil) {
        self.startTime = startTime
        self.endTime = endTime
        self.intervalFromPrevious = intervalFromPrevious
    }

    var duration: TimeInterval? {
        guard let endTime else { return nil }
        return endTime.timeIntervalSince(startTime)
    }
}
