import SwiftUI

struct SplashScreenView: View {
    @State private var iconScale: CGFloat = 0.6
    @State private var iconOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            BloomlyTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(BloomlyTheme.blush.opacity(0.5))
                        .frame(width: 120, height: 120)
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [BloomlyTheme.sageDark, BloomlyTheme.blushDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                VStack(spacing: 8) {
                    Text("Bloomly")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomlyTheme.textPrimary)
                    Text("Your pregnancy companion")
                        .font(.subheadline)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                iconScale = 1
                iconOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.25)) {
                textOpacity = 1
            }
        }
    }
}
