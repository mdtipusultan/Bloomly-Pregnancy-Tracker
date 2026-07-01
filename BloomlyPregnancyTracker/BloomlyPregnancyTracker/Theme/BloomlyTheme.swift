import SwiftUI

enum BloomlyTheme {
    static let blush = Color(red: 0.96, green: 0.82, blue: 0.84)
    static let blushDark = Color(red: 0.88, green: 0.65, blue: 0.70)
    static let cream = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let creamDark = Color(red: 0.95, green: 0.91, blue: 0.86)
    static let sage = Color(red: 0.65, green: 0.76, blue: 0.68)
    static let sageDark = Color(red: 0.45, green: 0.58, blue: 0.50)
    static let textPrimary = Color(red: 0.25, green: 0.22, blue: 0.24)
    static let textSecondary = Color(red: 0.50, green: 0.46, blue: 0.48)
    static let cardBackground = Color.white.opacity(0.85)

    static let backgroundGradient = LinearGradient(
        colors: [cream, blush.opacity(0.35)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func moodColor(for mood: Int) -> Color {
        switch mood {
        case 1: return Color(red: 0.45, green: 0.78, blue: 0.55)
        case 2: return sage
        case 3: return Color(red: 0.70, green: 0.72, blue: 0.78)
        case 4: return Color(red: 0.95, green: 0.65, blue: 0.45)
        case 5: return Color(red: 0.85, green: 0.45, blue: 0.50)
        default: return textSecondary
        }
    }

    static func severityColor(_ severity: String) -> Color {
        switch severity {
        case "mild": return sage.opacity(0.7)
        case "moderate": return Color.orange.opacity(0.8)
        case "strong": return Color.red.opacity(0.75)
        default: return textSecondary
        }
    }
}

struct BloomlyCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(BloomlyTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: BloomlyTheme.blushDark.opacity(0.12), radius: 8, y: 4)
    }
}

extension View {
    func bloomlyCard() -> some View {
        modifier(BloomlyCard())
    }

    func bloomlyScreenBackground() -> some View {
        background(BloomlyTheme.backgroundGradient.ignoresSafeArea())
    }
}
