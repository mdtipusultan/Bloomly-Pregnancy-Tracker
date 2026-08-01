import Foundation

enum WeightCalculator {
    static func increment(for unit: String) -> Double {
        unit == "lbs" ? 0.5 : 0.1
    }

    static func validRange(for unit: String) -> ClosedRange<Double> {
        unit == "lbs" ? 66...440 : 30...200
    }

    static func format(_ value: Double, unit: String) -> String {
        let decimals = unit == "lbs" ? 1 : 1
        return String(format: "%.\(decimals)f %@", value, unit)
    }

    static func formatChange(_ change: Double, unit: String) -> String {
        let sign = change >= 0 ? "+" : ""
        return "\(sign)\(format(change, unit: unit))"
    }

    static func entries(from logs: [DailyLog]) -> [(date: Date, weight: Double)] {
        logs.compactMap { log in
            guard let weight = log.weightValue else { return nil }
            return (log.date, weight)
        }
        .sorted { $0.date < $1.date }
    }

    static func latest(from logs: [DailyLog]) -> (date: Date, weight: Double)? {
        entries(from: logs).last
    }

    static func weight(on date: Date, from logs: [DailyLog]) -> Double? {
        let day = Calendar.current.startOfDay(for: date)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: day) }?.weightValue
    }

    static func previousEntry(before date: Date, from logs: [DailyLog]) -> (date: Date, weight: Double)? {
        let day = Calendar.current.startOfDay(for: date)
        return entries(from: logs).last { $0.date < day }
    }

    static func totalGain(current: Double, starting: Double) -> Double {
        current - starting
    }

    static func isValid(_ value: Double, unit: String) -> Bool {
        validRange(for: unit).contains(value)
    }

    static func pregnancyGainGuidance(week: Int, unit: String) -> String {
        let totalRange = unit == "lbs" ? "25–35 lbs total" : "11–16 kg total"
        switch week {
        case 1...13:
            return "First trimester: aim for about 1–4.5 lbs. Typical \(totalRange) for a healthy pregnancy."
        case 14...27:
            return "Second trimester: about 1 lb per week is common. Typical \(totalRange) overall."
        default:
            return "Third trimester: steady gain continues. Typical \(totalRange) overall."
        }
    }

    static func logForDate(_ date: Date, in logs: [DailyLog]) -> DailyLog? {
        let day = Calendar.current.startOfDay(for: date)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }
}
