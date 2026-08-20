import SwiftUI

enum BabySizeCustomIconKind {
    case pumpkin(small: Bool)
    case butternutSquash
}

struct BabySizeIcon: View {
    let sizeImage: String
    var fontSize: CGFloat = 56

    var body: some View {
        Group {
            switch BabySizeCatalog.customIconKind(for: sizeImage) {
            case .pumpkin(let small):
                PumpkinIconView(small: small)
            case .butternutSquash:
                ButternutSquashIconView()
            case nil:
                Text(BabySizeCatalog.emoji(for: sizeImage))
                    .font(.system(size: fontSize))
            }
        }
        .frame(width: fontSize * 1.15, height: fontSize * 1.15)
    }
}

// MARK: - Pumpkin

private struct PumpkinIconView: View {
    var small: Bool = false

    private var scale: CGFloat { small ? 0.78 : 1.0 }

    var body: some View {
        ZStack {
            pumpkinLobe(width: 26, height: 34, x: -9)
            pumpkinLobe(width: 30, height: 38, x: 0)
            pumpkinLobe(width: 26, height: 34, x: 9)

            Ellipse()
                .fill(Color.white.opacity(0.18))
                .frame(width: 10 * scale, height: 14 * scale)
                .offset(x: -5 * scale, y: -9 * scale)

            Capsule()
                .fill(Color(red: 0.38, green: 0.56, blue: 0.26))
                .frame(width: 11 * scale, height: 7 * scale)
                .offset(y: -21 * scale)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(red: 0.30, green: 0.46, blue: 0.20))
                .frame(width: 6 * scale, height: 11 * scale)
                .offset(y: -27 * scale)
        }
        .frame(width: 52 * scale, height: 48 * scale)
    }

    private func pumpkinLobe(width: CGFloat, height: CGFloat, x: CGFloat) -> some View {
        Ellipse()
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.97, green: 0.60, blue: 0.20),
                        Color(red: 0.86, green: 0.44, blue: 0.09)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: width * scale, height: height * scale)
            .offset(x: x * scale)
    }
}

// MARK: - Butternut Squash

private struct ButternutSquashIconView: View {
    var body: some View {
        ZStack {
            Ellipse()
                .fill(squashGradient)
                .frame(width: 34, height: 26)
                .offset(y: 11)

            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(squashGradient)
                .frame(width: 17, height: 26)
                .offset(y: -7)

            Capsule()
                .fill(Color(red: 0.52, green: 0.40, blue: 0.26))
                .frame(width: 8, height: 6)
                .offset(y: -22)
        }
        .frame(width: 40, height: 50)
    }

    private var squashGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.94, green: 0.78, blue: 0.48),
                Color(red: 0.82, green: 0.62, blue: 0.32)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
