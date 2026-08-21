import SwiftUI
import SwiftData

struct ContractionTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ContractionSession.startTime, order: .reverse) private var sessions: [ContractionSession]

    @State private var activeSession: ContractionSession?
    @State private var tapPulse = 0

    private var isActive: Bool { activeSession != nil }
    private var completedSessions: [ContractionSession] {
        sessions.filter { $0.endTime != nil }
    }
    private var recentSessions: [ContractionSession] {
        Array(completedSessions.prefix(8))
    }
    private var lastDuration: TimeInterval? { completedSessions.first?.duration }
    private var averageInterval: TimeInterval? {
        let values = completedSessions.prefix(5).compactMap(\.intervalFromPrevious)
        guard !values.isEmpty else { return nil }
        return values.reduce(0, +) / Double(values.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                timerSection
                stats
                hintCard
                history
            }
            .padding()
            .padding(.top, 8)
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.toolsContractionTimer)
        .bloomlyThemedNavigation()
        .bloomlyThemeAware()
        .bloomlyLanguageAware()
        .sensoryFeedback(.impact(weight: .medium), trigger: tapPulse)
        .onDisappear { stopIfNeeded() }
    }

    private var timerSection: some View {
        TimelineView(.periodic(from: .now, by: 0.2)) { context in
            let elapsed = activeSession.map { context.date.timeIntervalSince($0.startTime) } ?? 0
            VStack(spacing: 18) {
                Button(action: toggle) {
                    ZStack {
                        Circle()
                            .fill(actionColor.opacity(0.18))
                            .frame(width: 210, height: 210)

                        VStack(spacing: 8) {
                            Image(systemName: isActive ? "stop.fill" : "play.fill")
                                .font(.title2)
                            Text(isActive ? L10n.t("tools.contraction.stop") : L10n.t("tools.contraction.start"))
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 16)
                        }
                        .foregroundStyle(.white)
                        .frame(width: 168, height: 168)
                        .background(actionColor)
                        .clipShape(Circle())
                        .shadow(color: actionColor.opacity(0.35), radius: 16, y: 8)
                    }
                }
                .buttonStyle(ToolTapButtonStyle())
                .accessibilityLabel(isActive ? L10n.t("tools.contraction.stop") : L10n.t("tools.contraction.start"))

                Text(formatTime(elapsed))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomlyTheme.textPrimary)
                    .monospacedDigit()
            }
        }
    }

    private var actionColor: Color {
        isActive ? BloomlyTheme.blushDark : BloomlyTheme.sageDark
    }

    private var stats: some View {
        HStack(spacing: 12) {
            statCard(
                icon: "clock",
                title: L10n.contractionLastDuration,
                value: lastDuration.map(formatTime) ?? "—"
            )
            statCard(
                icon: "arrow.triangle.2.circlepath",
                title: L10n.contractionAverageInterval,
                value: averageInterval.map(formatTime) ?? "—"
            )
        }
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(BloomlyTheme.textPrimary)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var hintCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "hand.tap.fill")
                .font(.title2)
                .foregroundStyle(BloomlyTheme.sageDark)
                .padding(.top, 2)
            Text(L10n.contractionHint)
                .font(.subheadline)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @ViewBuilder
    private var history: some View {
        if !recentSessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.commonHistory)
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textPrimary)

                VStack(spacing: 0) {
                    ForEach(Array(recentSessions.enumerated()), id: \.element.persistentModelID) { index, session in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.startTime.formatted(date: .omitted, time: .standard))
                                    .font(.subheadline.weight(.medium))
                                if let duration = session.duration {
                                    Text(L10n.contractionDuration(formatTime(duration)))
                                        .font(.caption)
                                        .foregroundStyle(BloomlyTheme.textSecondary)
                                }
                            }
                            Spacer()
                            if let interval = session.intervalFromPrevious {
                                Text(formatTime(interval))
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(BloomlyTheme.sageDark)
                                    .monospacedDigit()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if index < recentSessions.count - 1 {
                            BloomlyGroupedDivider()
                        }
                    }
                }
                .background(BloomlyTheme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func toggle() {
        tapPulse += 1
        if isActive {
            stopIfNeeded()
        } else {
            startContraction()
        }
    }

    private func startContraction() {
        let lastEnd = completedSessions.first?.endTime
        let interval = lastEnd.map { Date().timeIntervalSince($0) }
        let session = ContractionSession(startTime: .now, intervalFromPrevious: interval)
        modelContext.insert(session)
        activeSession = session
    }

    private func stopIfNeeded() {
        guard let active = activeSession else { return }
        active.endTime = .now
        activeSession = nil
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

private struct ToolTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.62), value: configuration.isPressed)
    }
}
