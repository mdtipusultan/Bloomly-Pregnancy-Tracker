import SwiftUI

enum BabySizeCatalog {
    static func emoji(for sizeImage: String) -> String {
        emojiMap[sizeImage] ?? "🌱"
    }

    static func shortName(for sizeImage: String) -> String {
        sizeImage.replacingOccurrences(of: "_", with: " ").capitalized
    }

    static func trimesterAccent(for week: Int) -> Color {
        switch week {
        case 1...13: return Color(red: 0.65, green: 0.76, blue: 0.68)
        case 14...27: return Color(red: 0.88, green: 0.65, blue: 0.70)
        default: return Color(red: 0.75, green: 0.55, blue: 0.62)
        }
    }

    private static let emojiMap: [String: String] = [
        "poppy_seed": "🌸",
        "sesame_seed": "⚪️",
        "lentil": "🫘",
        "blueberry": "🫐",
        "raspberry": "🍇",
        "grape": "🍇",
        "cherry": "🍒",
        "strawberry": "🍓",
        "fig": "🫒",
        "lime": "🍋‍🟩",
        "peach": "🍑",
        "plum": "🍑",
        "lemon": "🍋",
        "nectarine": "🍑",
        "apple": "🍎",
        "avocado": "🥑",
        "pear": "🍐",
        "bell_pepper": "🫑",
        "mango": "🥭",
        "banana": "🍌",
        "carrot": "🥕",
        "papaya": "🍈",
        "grapefruit": "🍊",
        "cantaloupe": "🍈",
        "cauliflower": "🥦",
        "head_of_lettuce": "🥬",
        "lettuce": "🥬",
        "rutabaga": "🥔",
        "eggplant": "🍆",
        "butternut_squash": "🎃",
        "cabbage": "🥬",
        "coconut": "🥥",
        "jicama": "🥔",
        "pineapple": "🍍",
        "honeydew_melon": "🍈",
        "romaine_lettuce": "🥬",
        "bunch_of_swiss_chard": "🥬",
        "mini_watermelon": "🍉",
        "pumpkin": "🎃",
        "watermelon": "🍉",
        "small_pumpkin": "🎃",
        "full_term_baby": "👶"
    ]
}
