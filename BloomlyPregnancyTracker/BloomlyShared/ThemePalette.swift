import SwiftUI

struct BloomlyThemePalette: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let icon: String

    let blush: Color
    let blushDark: Color
    let cream: Color
    let creamDark: Color
    let sage: Color
    let sageDark: Color
    let textPrimary: Color
    let textSecondary: Color
    let cardBackground: Color

    var name: String { String(localized: String.LocalizationValue(nameKey)) }

    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [cream, blush.opacity(0.35)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [sageDark, sage],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    func moodColor(for mood: Int) -> Color {
        switch mood {
        case 1: return sage.opacity(0.9)
        case 2: return sage
        case 3: return textSecondary.opacity(0.6)
        case 4: return blushDark
        case 5: return Color.red.opacity(0.65)
        default: return textSecondary
        }
    }

    func severityColor(_ severity: String) -> Color {
        switch severity {
        case "mild": return sage.opacity(0.7)
        case "moderate": return Color.orange.opacity(0.8)
        case "strong": return Color.red.opacity(0.75)
        default: return textSecondary
        }
    }

    static func == (lhs: BloomlyThemePalette, rhs: BloomlyThemePalette) -> Bool {
        lhs.id == rhs.id
    }
}

enum ThemeRegistry {
    static let all: [BloomlyThemePalette] = [
        blush, dark, white, forest, rain, sunset, lavender, roseGold, midnight, peach, mint, coral
    ]

    static func palette(for id: String) -> BloomlyThemePalette {
        all.first { $0.id == id } ?? blush
    }

    // MARK: - Default (original Bloomly)

    static let blush = BloomlyThemePalette(
        id: "blush",
        nameKey: "theme.blush",
        icon: "heart.fill",
        blush: rgb(0.96, 0.82, 0.84),
        blushDark: rgb(0.88, 0.65, 0.70),
        cream: rgb(0.99, 0.97, 0.94),
        creamDark: rgb(0.95, 0.91, 0.86),
        sage: rgb(0.65, 0.76, 0.68),
        sageDark: rgb(0.45, 0.58, 0.50),
        textPrimary: rgb(0.25, 0.22, 0.24),
        textSecondary: rgb(0.50, 0.46, 0.48),
        cardBackground: Color.white.opacity(0.85)
    )

    static let dark = BloomlyThemePalette(
        id: "dark",
        nameKey: "theme.dark",
        icon: "moon.fill",
        blush: rgb(0.35, 0.28, 0.32),
        blushDark: rgb(0.55, 0.40, 0.48),
        cream: rgb(0.12, 0.12, 0.14),
        creamDark: rgb(0.18, 0.18, 0.20),
        sage: rgb(0.50, 0.62, 0.55),
        sageDark: rgb(0.65, 0.78, 0.70),
        textPrimary: rgb(0.95, 0.93, 0.94),
        textSecondary: rgb(0.65, 0.62, 0.64),
        cardBackground: rgb(0.22, 0.22, 0.25).opacity(0.92)
    )

    static let white = BloomlyThemePalette(
        id: "white",
        nameKey: "theme.white",
        icon: "sun.max.fill",
        blush: rgb(0.94, 0.94, 0.96),
        blushDark: rgb(0.78, 0.78, 0.82),
        cream: rgb(1.0, 1.0, 1.0),
        creamDark: rgb(0.96, 0.96, 0.98),
        sage: rgb(0.40, 0.45, 0.50),
        sageDark: rgb(0.25, 0.30, 0.35),
        textPrimary: rgb(0.15, 0.15, 0.18),
        textSecondary: rgb(0.45, 0.45, 0.50),
        cardBackground: Color.white.opacity(0.95)
    )

    static let forest = BloomlyThemePalette(
        id: "forest",
        nameKey: "theme.forest",
        icon: "leaf.fill",
        blush: rgb(0.75, 0.85, 0.72),
        blushDark: rgb(0.45, 0.62, 0.42),
        cream: rgb(0.94, 0.97, 0.91),
        creamDark: rgb(0.86, 0.92, 0.84),
        sage: rgb(0.38, 0.58, 0.40),
        sageDark: rgb(0.22, 0.42, 0.28),
        textPrimary: rgb(0.18, 0.28, 0.20),
        textSecondary: rgb(0.40, 0.52, 0.42),
        cardBackground: Color.white.opacity(0.82)
    )

    static let rain = BloomlyThemePalette(
        id: "rain",
        nameKey: "theme.rain",
        icon: "cloud.rain.fill",
        blush: rgb(0.72, 0.82, 0.92),
        blushDark: rgb(0.45, 0.62, 0.82),
        cream: rgb(0.92, 0.95, 0.98),
        creamDark: rgb(0.84, 0.90, 0.96),
        sage: rgb(0.45, 0.65, 0.82),
        sageDark: rgb(0.28, 0.48, 0.68),
        textPrimary: rgb(0.18, 0.28, 0.38),
        textSecondary: rgb(0.42, 0.52, 0.62),
        cardBackground: Color.white.opacity(0.88)
    )

    static let sunset = BloomlyThemePalette(
        id: "sunset",
        nameKey: "theme.sunset",
        icon: "sunset.fill",
        blush: rgb(0.98, 0.78, 0.62),
        blushDark: rgb(0.92, 0.52, 0.38),
        cream: rgb(0.99, 0.94, 0.88),
        creamDark: rgb(0.96, 0.86, 0.78),
        sage: rgb(0.88, 0.58, 0.42),
        sageDark: rgb(0.72, 0.38, 0.28),
        textPrimary: rgb(0.32, 0.22, 0.18),
        textSecondary: rgb(0.58, 0.42, 0.36),
        cardBackground: Color.white.opacity(0.85)
    )

    static let lavender = BloomlyThemePalette(
        id: "lavender",
        nameKey: "theme.lavender",
        icon: "sparkles",
        blush: rgb(0.88, 0.82, 0.96),
        blushDark: rgb(0.68, 0.55, 0.82),
        cream: rgb(0.97, 0.95, 0.99),
        creamDark: rgb(0.92, 0.88, 0.96),
        sage: rgb(0.62, 0.52, 0.78),
        sageDark: rgb(0.48, 0.38, 0.65),
        textPrimary: rgb(0.28, 0.22, 0.32),
        textSecondary: rgb(0.52, 0.46, 0.58),
        cardBackground: Color.white.opacity(0.88)
    )

    static let roseGold = BloomlyThemePalette(
        id: "roseGold",
        nameKey: "theme.roseGold",
        icon: "crown.fill",
        blush: rgb(0.96, 0.82, 0.78),
        blushDark: rgb(0.82, 0.58, 0.52),
        cream: rgb(0.99, 0.96, 0.94),
        creamDark: rgb(0.95, 0.90, 0.86),
        sage: rgb(0.78, 0.62, 0.55),
        sageDark: rgb(0.62, 0.45, 0.40),
        textPrimary: rgb(0.30, 0.22, 0.20),
        textSecondary: rgb(0.55, 0.45, 0.42),
        cardBackground: Color.white.opacity(0.87)
    )

    static let midnight = BloomlyThemePalette(
        id: "midnight",
        nameKey: "theme.midnight",
        icon: "moon.stars.fill",
        blush: rgb(0.28, 0.32, 0.55),
        blushDark: rgb(0.45, 0.48, 0.72),
        cream: rgb(0.08, 0.10, 0.18),
        creamDark: rgb(0.14, 0.16, 0.28),
        sage: rgb(0.55, 0.58, 0.82),
        sageDark: rgb(0.72, 0.75, 0.92),
        textPrimary: rgb(0.92, 0.92, 0.96),
        textSecondary: rgb(0.62, 0.64, 0.72),
        cardBackground: rgb(0.18, 0.20, 0.32).opacity(0.90)
    )

    static let peach = BloomlyThemePalette(
        id: "peach",
        nameKey: "theme.peach",
        icon: "carrot.fill",
        blush: rgb(0.98, 0.88, 0.78),
        blushDark: rgb(0.92, 0.68, 0.52),
        cream: rgb(1.0, 0.97, 0.93),
        creamDark: rgb(0.98, 0.92, 0.86),
        sage: rgb(0.88, 0.65, 0.48),
        sageDark: rgb(0.75, 0.48, 0.32),
        textPrimary: rgb(0.32, 0.24, 0.20),
        textSecondary: rgb(0.58, 0.48, 0.42),
        cardBackground: Color.white.opacity(0.86)
    )

    static let mint = BloomlyThemePalette(
        id: "mint",
        nameKey: "theme.mint",
        icon: "wind",
        blush: rgb(0.78, 0.94, 0.88),
        blushDark: rgb(0.52, 0.82, 0.72),
        cream: rgb(0.94, 0.99, 0.97),
        creamDark: rgb(0.86, 0.96, 0.92),
        sage: rgb(0.42, 0.78, 0.65),
        sageDark: rgb(0.28, 0.62, 0.52),
        textPrimary: rgb(0.18, 0.28, 0.24),
        textSecondary: rgb(0.42, 0.55, 0.50),
        cardBackground: Color.white.opacity(0.88)
    )

    static let coral = BloomlyThemePalette(
        id: "coral",
        nameKey: "theme.coral",
        icon: "flame.fill",
        blush: rgb(0.98, 0.78, 0.72),
        blushDark: rgb(0.92, 0.48, 0.42),
        cream: rgb(0.99, 0.95, 0.93),
        creamDark: rgb(0.96, 0.88, 0.85),
        sage: rgb(0.88, 0.52, 0.48),
        sageDark: rgb(0.72, 0.32, 0.32),
        textPrimary: rgb(0.32, 0.20, 0.20),
        textSecondary: rgb(0.58, 0.40, 0.40),
        cardBackground: Color.white.opacity(0.87)
    )

    private static func rgb(_ r: Double, _ g: Double, _ b: Double) -> Color {
        Color(red: r, green: g, blue: b)
    }
}
