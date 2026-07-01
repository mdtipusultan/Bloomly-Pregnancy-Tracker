import Foundation
import SwiftData

@Model
final class SavedName {
    var name: String
    var gender: String
    var style: String
    var savedAt: Date

    init(name: String, gender: String, style: String, savedAt: Date = .now) {
        self.name = name
        self.gender = gender
        self.style = style
        self.savedAt = savedAt
    }
}
