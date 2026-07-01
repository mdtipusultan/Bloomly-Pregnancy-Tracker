import Foundation
import SwiftData

@Model
final class UserProfile {
    var lastMenstrualPeriod: Date?
    var dueDate: Date?
    var weightUnit: String
    var isFirstPregnancy: Bool
    var isPremium: Bool
    var hasCompletedOnboarding: Bool
    var trackingMode: String // "pregnant" or "planning"
    var averageCycleLength: Int
    var createdAt: Date

    init(
        lastMenstrualPeriod: Date? = nil,
        dueDate: Date? = nil,
        weightUnit: String = "kg",
        isFirstPregnancy: Bool = true,
        isPremium: Bool = false,
        hasCompletedOnboarding: Bool = false,
        trackingMode: String = "pregnant",
        averageCycleLength: Int = 28,
        createdAt: Date = .now
    ) {
        self.lastMenstrualPeriod = lastMenstrualPeriod
        self.dueDate = dueDate
        self.weightUnit = weightUnit
        self.isFirstPregnancy = isFirstPregnancy
        self.isPremium = isPremium
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.trackingMode = trackingMode
        self.averageCycleLength = averageCycleLength
        self.createdAt = createdAt
    }
}
