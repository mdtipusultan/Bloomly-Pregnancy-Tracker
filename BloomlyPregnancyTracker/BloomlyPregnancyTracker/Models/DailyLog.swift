import Foundation
import SwiftData

@Model
final class DailyLog {
    var date: Date
    var mood: Int
    var waterGlasses: Int
    var weightValue: Double?
    var notes: String?
    var symptomsJSON: String
    var symptomSeverityJSON: String

    init(
        date: Date = Calendar.current.startOfDay(for: .now),
        mood: Int = 0,
        waterGlasses: Int = 0,
        weightValue: Double? = nil,
        notes: String? = nil,
        symptoms: [String] = [],
        symptomSeverity: [String: String] = [:]
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.mood = mood
        self.waterGlasses = waterGlasses
        self.weightValue = weightValue
        self.notes = notes
        self.symptomsJSON = (try? JSONEncoder().encode(symptoms)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        self.symptomSeverityJSON = (try? JSONEncoder().encode(symptomSeverity)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }

    var symptoms: [String] {
        get {
            guard let data = symptomsJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String].self, from: data) else { return [] }
            return decoded
        }
        set {
            symptomsJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        }
    }

    var symptomSeverity: [String: String] {
        get {
            guard let data = symptomSeverityJSON.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: String].self, from: data) else { return [:] }
            return decoded
        }
        set {
            symptomSeverityJSON = (try? JSONEncoder().encode(newValue)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
        }
    }
}
