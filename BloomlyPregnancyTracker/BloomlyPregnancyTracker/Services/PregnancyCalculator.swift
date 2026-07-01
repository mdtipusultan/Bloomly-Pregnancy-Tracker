import Foundation

enum PregnancyCalculator {
    static let totalWeeks = 40

    static func dueDate(fromLMP lmp: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: 280, to: lmp) ?? lmp
    }

    static func lmp(fromDueDate dueDate: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -280, to: dueDate) ?? dueDate
    }

    static func currentWeek(profile: UserProfile, referenceDate: Date = .now) -> Int {
        guard profile.trackingMode == "pregnant" else { return 0 }
        let start: Date?
        if let lmp = profile.lastMenstrualPeriod {
            start = lmp
        } else if let due = profile.dueDate {
            start = lmp(fromDueDate: due)
        } else {
            return 1
        }
        guard let start else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: start, to: referenceDate).day ?? 0
        return min(max(days / 7 + 1, 1), 42)
    }

    static func daysUntilDue(profile: UserProfile, referenceDate: Date = .now) -> Int? {
        guard profile.trackingMode == "pregnant", let dueDate = profile.dueDate else { return nil }
        return Calendar.current.dateComponents([.day], from: referenceDate, to: dueDate).day
    }

    static func progress(profile: UserProfile, referenceDate: Date = .now) -> Double {
        let week = Double(currentWeek(profile: profile, referenceDate: referenceDate))
        return min(max(week / Double(totalWeeks), 0), 1)
    }

    static func trimester(for week: Int) -> Int {
        switch week {
        case 1...13: return 1
        case 14...27: return 2
        default: return 3
        }
    }

    static func weekEntry(for profile: UserProfile) -> WeekGuideEntry? {
        let week = currentWeek(profile: profile)
        return ContentLoader.loadWeekGuide().first { $0.week == week }
    }
}

enum CycleCalculator {
    static func predictNextPeriod(after logs: [PeriodLog], cycleLength: Int) -> Date? {
        guard let last = logs.sorted(by: { $0.startDate > $1.startDate }).first else { return nil }
        return Calendar.current.date(byAdding: .day, value: cycleLength, to: last.startDate)
    }

    static func fertileWindow(from periodStart: Date, cycleLength: Int) -> (start: Date, end: Date, ovulation: Date) {
        let ovulation = Calendar.current.date(byAdding: .day, value: cycleLength - 14, to: periodStart) ?? periodStart
        let start = Calendar.current.date(byAdding: .day, value: -5, to: ovulation) ?? ovulation
        let end = Calendar.current.date(byAdding: .day, value: 1, to: ovulation) ?? ovulation
        return (start, end, ovulation)
    }
}

enum StatsCalculator {
    static func waterStreak(from logs: [DailyLog], goal: Int = 8) -> (current: Int, best: Int) {
        let sorted = logs.filter { $0.waterGlasses >= goal }
            .map { Calendar.current.startOfDay(for: $0.date) }
            .sorted(by: >)
        guard !sorted.isEmpty else { return (0, 0) }

        var current = 0
        var check = Calendar.current.startOfDay(for: .now)
        for day in sorted {
            if day == check {
                current += 1
                check = Calendar.current.date(byAdding: .day, value: -1, to: check) ?? check
            } else if day < check { break }
        }

        var best = 0
        var streak = 0
        var prev: Date?
        for day in sorted.reversed() {
            if let p = prev, Calendar.current.dateComponents([.day], from: p, to: day).day == 1 {
                streak += 1
            } else {
                streak = 1
            }
            best = max(best, streak)
            prev = day
        }
        return (current, best)
    }

    static func symptomFrequency(from logs: [DailyLog]) -> [(symptom: String, count: Int)] {
        var counts: [String: Int] = [:]
        for log in logs {
            for s in log.symptoms {
                counts[s, default: 0] += 1
            }
        }
        return counts.sorted { $0.value > $1.value }.map { ($0.key, $0.value) }
    }
}
