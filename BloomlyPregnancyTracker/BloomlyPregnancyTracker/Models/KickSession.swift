import Foundation
import SwiftData

@Model
final class KickSession {
    var startTime: Date
    var kicks: Int
    var durationMinutes: Int

    init(startTime: Date = .now, kicks: Int = 0, durationMinutes: Int = 0) {
        self.startTime = startTime
        self.kicks = kicks
        self.durationMinutes = durationMinutes
    }
}
