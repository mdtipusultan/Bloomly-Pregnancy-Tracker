import SwiftUI

struct BabySizeCard: View {
    enum Layout {
        case stacked
        case split
    }

    let entry: WeekGuideEntry
    var week: Int
    var compact: Bool = false
    var layout: Layout = .stacked
    var showShareButton: Bool = false
    var onShare: (() -> Void)?

    @State private var fruitScale: CGFloat = 0.6
    @State private var fruitOpacity: Double = 0
    @State private var pulse = false

    private var accent: Color { BabySizeCatalog.trimesterAccent(for: week) }

    var body: some View {
        Group {
            if layout == .split {
                splitLayout
            } else {
                stackedLayout
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
        .onAppear { animateIn() }
        .onChange(of: week) { _, _ in animateIn() }
    }

    private var splitLayout: some View {
        HStack(alignment: .center, spacing: 16) {
            BabySizeIcon(sizeImage: entry.sizeImage, fontSize: 68)
                .scaleEffect(fruitScale)
                .opacity(fruitOpacity)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.localizedBabySize)
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textPrimary)
                    .multilineTextAlignment(.leading)

                Text(entry.length)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                Text(entry.weight)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }

            Spacer(minLength: 0)

            if showShareButton, let onShare {
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                }
                .buttonStyle(.bordered)
                .tint(BloomlyTheme.sageDark)
                .controlSize(.small)
                .accessibilityLabel(L10n.babySizeSharePartner)
            }
        }
    }

    private var stackedLayout: some View {
        VStack(spacing: compact ? 10 : 16) {
            ZStack {
                Circle()
                    .fill(accent.opacity(0.18))
                    .frame(width: compact ? 72 : 110, height: compact ? 72 : 110)
                    .scaleEffect(pulse ? 1.06 : 1.0)

                BabySizeIcon(sizeImage: entry.sizeImage, fontSize: compact ? 36 : 56)
                    .scaleEffect(fruitScale)
                    .opacity(fruitOpacity)
            }

            VStack(spacing: 6) {
                Text(entry.localizedBabySize)
                    .font(compact ? .subheadline.bold() : .headline)
                    .foregroundStyle(BloomlyTheme.sageDark)
                    .multilineTextAlignment(.center)

                HStack(spacing: 16) {
                    Label(entry.length, systemImage: "ruler")
                    Label(entry.weight, systemImage: "scalemass")
                }
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
            }

            if showShareButton, let onShare {
                Button(action: onShare) {
                    Label(L10n.babySizeSharePartner, systemImage: "square.and.arrow.up")
                        .font(.caption.bold())
                }
                .buttonStyle(.bordered)
                .tint(BloomlyTheme.sageDark)
            }
        }
    }

    private func animateIn() {
        fruitScale = 0.55
        fruitOpacity = 0
        pulse = false

        withAnimation(.spring(response: 0.55, dampingFraction: 0.62)) {
            fruitScale = 1.0
            fruitOpacity = 1.0
        }

        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.4)) {
            pulse = true
        }
    }
}

struct BabySizeTimelineStrip: View {
    let currentWeek: Int
    let entries: [WeekGuideEntry]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(entries) { entry in
                        VStack(spacing: 6) {
                            BabySizeIcon(
                                sizeImage: entry.sizeImage,
                                fontSize: entry.week == currentWeek ? 32 : 22
                            )
                                .scaleEffect(entry.week == currentWeek ? 1.1 : 0.9)
                            Text("W\(entry.week)")
                                .font(.caption2.bold())
                                .foregroundStyle(entry.week == currentWeek ? BloomlyTheme.sageDark : BloomlyTheme.textSecondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 10)
                        .background(entry.week == currentWeek ? BloomlyTheme.sage.opacity(0.25) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .id(entry.week)
                    }
                }
                .padding(.horizontal, 4)
            }
            .onAppear {
                proxy.scrollTo(currentWeek, anchor: .center)
            }
            .onChange(of: currentWeek) { _, newWeek in
                withAnimation(.easeInOut) {
                    proxy.scrollTo(newWeek, anchor: .center)
                }
            }
        }
    }
}
