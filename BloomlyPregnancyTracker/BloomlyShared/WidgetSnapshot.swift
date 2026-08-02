import Foundation

struct WidgetSnapshot: Codable {
    var week: Int
    var babySizeText: String
    var sizeImage: String
    var length: String
    var weight: String
    var daysUntilDue: Int?
    var progress: Double
    var trackingMode: String
    var updatedAt: Date

    static let placeholder = WidgetSnapshot(
        week: 12,
        babySizeText: "Your baby is the size of a plum",
        sizeImage: "plum",
        length: "4.9 cm",
        weight: "24g",
        daysUntilDue: 196,
        progress: 0.3,
        trackingMode: "pregnant",
        updatedAt: .now
    )
}
