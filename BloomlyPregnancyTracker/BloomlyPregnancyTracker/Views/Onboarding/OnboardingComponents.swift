import SwiftUI

// MARK: - Animated Background

struct OnboardingBackground: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            BloomlyTheme.backgroundGradient

            Circle()
                .fill(BloomlyTheme.blush.opacity(0.45))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: animate ? -90 : -120, y: animate ? -220 : -180)

            Circle()
                .fill(BloomlyTheme.sage.opacity(0.35))
                .frame(width: 220, height: 220)
                .blur(radius: 50)
                .offset(x: animate ? 130 : 100, y: animate ? 280 : 320)

            Circle()
                .fill(BloomlyTheme.blushDark.opacity(0.15))
                .frame(width: 160, height: 160)
                .blur(radius: 40)
                .offset(x: animate ? 60 : 30, y: animate ? -60 : -30)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                animate = true
            }
        }
    }
}

// MARK: - Step Indicator

struct OnboardingStepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    let stepTitle: String

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 8) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Capsule()
                        .fill(index <= currentStep ? BloomlyTheme.sageDark : BloomlyTheme.creamDark)
                        .frame(height: 4)
                        .overlay {
                            if index == currentStep {
                                Capsule()
                                    .fill(BloomlyTheme.primaryGradient)
                                    .frame(height: 4)
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: currentStep)
                }
            }

            HStack {
                Text("Step \(currentStep + 1) of \(totalSteps)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BloomlyTheme.sageDark)
                Spacer()
                Text(stepTitle)
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
    }
}

// MARK: - Hero Icon

struct OnboardingHeroIcon: View {
    let systemName: String
    let colors: [Color]
    @State private var pulse = false

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [colors.first?.opacity(0.35) ?? .clear, .clear],
                        center: .center,
                        startRadius: 20,
                        endRadius: pulse ? 70 : 55
                    )
                )
                .frame(width: 140, height: 140)

            Circle()
                .fill(BloomlyTheme.cardBackground)
                .frame(width: 96, height: 96)
                .shadow(color: BloomlyTheme.blushDark.opacity(0.18), radius: 16, y: 8)

            Image(systemName: systemName)
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(
                    LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .symbolEffect(.pulse.byLayer, options: .repeating.speed(0.4))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// MARK: - Feature Highlight

struct OnboardingFeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(BloomlyTheme.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }

            Spacer(minLength: 0)
        }
    }
}

// MARK: - Mode Card

struct OnboardingModeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(isSelected ? Color.white.opacity(0.2) : BloomlyTheme.sage.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? .white : BloomlyTheme.sageDark)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                        .opacity(isSelected ? 0.9 : 0.7)
                }

                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .white : BloomlyTheme.textSecondary.opacity(0.4))
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isSelected ? AnyShapeStyle(BloomlyTheme.primaryGradient) : AnyShapeStyle(BloomlyTheme.creamDark))
            }
            .foregroundStyle(isSelected ? .white : BloomlyTheme.textPrimary)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(isSelected ? Color.clear : BloomlyTheme.sage.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: isSelected ? BloomlyTheme.sageDark.opacity(0.25) : .clear, radius: 12, y: 6)
            .scaleEffect(isSelected ? 1.02 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview Card

struct OnboardingPregnancyPreview: View {
    let week: Int
    let dueDate: Date
    let trimester: Int

    var body: some View {
        HStack(spacing: 0) {
            previewStat(value: "\(week)", label: "Week", icon: "calendar.circle.fill")
            Divider().frame(height: 44)
            previewStat(value: "T\(trimester)", label: "Trimester", icon: "leaf.circle.fill")
            Divider().frame(height: 44)
            previewStat(
                value: dueDate.formatted(.dateTime.month(.abbreviated).day()),
                label: "Due",
                icon: "heart.circle.fill"
            )
        }
        .padding(.vertical, 14)
        .background(BloomlyTheme.sage.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(BloomlyTheme.sage.opacity(0.25), lineWidth: 1)
        }
    }

    private func previewStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(BloomlyTheme.sageDark)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(BloomlyTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Primary Button

struct OnboardingPrimaryButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background(BloomlyTheme.primaryGradient)
            .clipShape(Capsule())
            .shadow(color: BloomlyTheme.sageDark.opacity(0.35), radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}
