import SwiftUI
import SwiftData

struct KickCounterView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \KickSession.startTime, order: .reverse) private var sessions: [KickSession]

    @State private var kicks = 0
    @State private var sessionStart: Date?
    @State private var kickTimes: [Date] = []
    @State private var pulse = false
    @State private var tapPulse = 0
    @State private var goalPulse = 0

    private let goal = 10

    private var isActive: Bool { sessionStart != nil }
    private var goalReached: Bool { kicks >= goal }
    private var progress: Double { min(Double(kicks) / Double(goal), 1) }
    private var recentSessionsToShow: [KickSession] { Array(sessions.prefix(5)) }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                tapControl
                countSection
                if isActive {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        statsSection(now: context.date)
                    }
                } else {
                    statsSection(now: .now)
                }
                encouragementCard
                if isActive {
                    sessionActions
                }
                recentSessions
            }
            .padding()
            .padding(.top, 8)
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.toolsKickCounter)
        .bloomlyThemedNavigation()
        .bloomlyThemeAware()
        .bloomlyLanguageAware()
        .sensoryFeedback(.impact(weight: .medium), trigger: tapPulse)
        .sensoryFeedback(.success, trigger: goalPulse)
        .onAppear {
            pulse = true
        }
    }

    private var tapControl: some View {
        Button(action: registerKick) {
            ZStack {
                Circle()
                    .fill(BloomlyTheme.sage.opacity(0.22))
                    .frame(width: 210, height: 210)
                    .scaleEffect(pulse ? 1.08 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulse)

                Circle()
                    .stroke(BloomlyTheme.creamDark, lineWidth: 8)
                    .frame(width: 196, height: 196)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        BloomlyTheme.sageDark,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 196, height: 196)
                    .animation(.spring(response: 0.45, dampingFraction: 0.72), value: kicks)

                VStack(spacing: 10) {
                    Image(systemName: goalReached ? "checkmark.circle.fill" : "heart.fill")
                        .font(.title)
                        .symbolEffect(.bounce, value: kicks)
                    Text(L10n.kickTapForKick)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.7)
                        .padding(.horizontal, 16)
                }
                .foregroundStyle(.white)
                .frame(width: 168, height: 168)
                .background(BloomlyTheme.sageDark)
                .clipShape(Circle())
                .shadow(color: BloomlyTheme.sageDark.opacity(0.35), radius: 16, y: 8)
            }
        }
        .buttonStyle(KickTapButtonStyle())
        .accessibilityLabel(L10n.kickTapForKick)
        .accessibilityValue("\(kicks) \(L10n.kickKicks)")
        .accessibilityHint(L10n.kickIdleHint)
    }

    private var countSection: some View {
        VStack(spacing: 4) {
            Text("\(kicks)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundStyle(BloomlyTheme.sageDark)
                .contentTransition(.numericText())
                .animation(.snappy, value: kicks)
            Text(L10n.kickKicks)
                .font(.title3)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
    }

    private func statsSection(now: Date) -> some View {
        VStack(spacing: 12) {
            VStack(spacing: 4) {
                Text(L10n.kickSessionTime)
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                Text(sessionDurationText(now: now))
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(BloomlyTheme.textPrimary)
                    .monospacedDigit()
            }

            HStack(spacing: 12) {
                statCard(
                    icon: "clock",
                    title: L10n.kickLastKick,
                    value: lastKickText(now: now)
                )
                statCard(
                    icon: "waveform.path.ecg",
                    title: L10n.kickAverageInterval,
                    value: averageIntervalText
                )
            }
        }
    }

    private func statCard(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
                .labelStyle(.titleAndIcon)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(BloomlyTheme.textPrimary)
                .monospacedDigit()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var encouragementCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: goalReached ? "heart.circle.fill" : "heart.fill")
                .font(.title2)
                .foregroundStyle(BloomlyTheme.sageDark)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(goalReached ? L10n.kickGoalReached : L10n.kickCountGoal)
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textPrimary)
                Text(kicks == 0 ? L10n.kickIdleHint : L10n.kickEncouragement)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .animation(.easeInOut(duration: 0.25), value: goalReached)
    }

    private var sessionActions: some View {
        VStack(spacing: 12) {
            Button(action: saveSession) {
                Text(L10n.kickSaveSession)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BloomlyTheme.sageDark)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(L10n.commonReset) { resetSession() }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
    }

    @ViewBuilder
    private var recentSessions: some View {
        if !sessions.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.commonHistory)
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textPrimary)

                VStack(spacing: 0) {
                    ForEach(Array(recentSessionsToShow.enumerated()), id: \.element.persistentModelID) { index, session in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(session.startTime.formatted(date: .abbreviated, time: .shortened))
                                    .font(.subheadline.weight(.medium))
                                Text(sessionSummary(session))
                                    .font(.caption)
                                    .foregroundStyle(BloomlyTheme.textSecondary)
                            }
                            Spacer()
                            Text("\(session.kicks)")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(BloomlyTheme.sageDark)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)

                        if index < recentSessionsToShow.count - 1 {
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

    private func registerKick() {
        if sessionStart == nil {
            sessionStart = .now
        }
        kicks += 1
        kickTimes.append(.now)
        tapPulse += 1
        if kicks == goal {
            goalPulse += 1
        }
    }

    private func resetSession() {
        kicks = 0
        sessionStart = nil
        kickTimes = []
    }

    private func saveSession() {
        guard let start = sessionStart else { return }
        let minutes = Int(Date().timeIntervalSince(start) / 60)
        modelContext.insert(
            KickSession(startTime: start, kicks: kicks, durationMinutes: max(minutes, 1))
        )
        resetSession()
    }

    private func sessionDurationText(now: Date) -> String {
        guard let start = sessionStart else { return formatClock(0) }
        return formatClock(now.timeIntervalSince(start))
    }

    private func lastKickText(now: Date) -> String {
        guard let last = kickTimes.last else { return "—" }
        return formatClock(now.timeIntervalSince(last))
    }

    private var averageIntervalText: String {
        guard kickTimes.count >= 2 else { return "—" }
        let intervals = zip(kickTimes.dropFirst(), kickTimes).map { later, earlier in
            later.timeIntervalSince(earlier)
        }
        let average = intervals.reduce(0, +) / Double(intervals.count)
        return formatClock(average)
    }

    private func sessionSummary(_ session: KickSession) -> String {
        let duration = Duration.seconds(session.durationMinutes * 60)
            .formatted(.units(allowed: [.minutes], width: .abbreviated))
        return "\(session.kicks) \(L10n.kickKicks) · \(duration)"
    }

    private func formatClock(_ interval: TimeInterval) -> String {
        let total = max(0, Int(interval))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

private struct KickTapButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.62), value: configuration.isPressed)
    }
}
