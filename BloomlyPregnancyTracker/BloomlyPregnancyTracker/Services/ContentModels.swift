import Foundation

struct WeekGuideEntry: Codable, Identifiable {
    let week: Int
    let babySize: String
    let length: String
    let weight: String
    let development: String
    let momFeeling: String
    let tip: String
    let appointmentReminder: String?

    var id: Int { week }
}

struct DailyTip: Codable, Identifiable {
    let id: Int
    let text: String
}

struct BabyNameEntry: Codable, Identifiable, Hashable {
    let name: String
    let gender: String
    let style: String
    let letter: String

    var id: String { name }
}

struct NutritionSection: Codable, Identifiable {
    let id: String
    let title: String
    let trimester: String
    let items: [String]
}

enum SymptomCatalog {
    static let all: [(key: String, label: String)] = [
        ("nausea", "Nausea"),
        ("fatigue", "Fatigue"),
        ("heartburn", "Heartburn"),
        ("cramps", "Cramps"),
        ("swelling", "Swelling"),
        ("mood_swings", "Mood Swings"),
        ("cravings", "Cravings"),
        ("back_pain", "Back Pain"),
        ("headache", "Headache"),
        ("spotting", "Spotting")
    ]

    static let severities = ["mild", "moderate", "strong"]

    static let moodEmojis = ["😊", "😌", "😔", "😤", "😰"]
}

enum ContentLoader {
    static func loadWeekGuide() -> [WeekGuideEntry] {
        load("week_guide", as: [WeekGuideEntry].self) ?? []
    }

    static func loadDailyTips() -> [DailyTip] {
        load("daily_tips", as: [DailyTip].self) ?? []
    }

    static func loadBabyNames() -> [BabyNameEntry] {
        load("baby_names", as: [BabyNameEntry].self) ?? []
    }

    static func loadNutrition() -> [NutritionSection] {
        load("nutrition", as: [NutritionSection].self) ?? []
    }

    static func dailyTip(for date: Date) -> String {
        let tips = loadDailyTips()
        guard !tips.isEmpty else { return "Rest when you need to — your body is doing amazing work." }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        return tips[dayOfYear % tips.count].text
    }

    private static func load<T: Decodable>(_ name: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
}
