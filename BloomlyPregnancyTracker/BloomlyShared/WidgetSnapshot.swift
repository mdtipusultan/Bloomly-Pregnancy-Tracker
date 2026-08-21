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
        babySizeText: "Your baby is the size of a lime",
        sizeImage: "lime",
        length: "5.4 cm",
        weight: "14g",
        daysUntilDue: 196,
        progress: 0.3,
        trackingMode: "pregnant",
        updatedAt: .now
    )
}
