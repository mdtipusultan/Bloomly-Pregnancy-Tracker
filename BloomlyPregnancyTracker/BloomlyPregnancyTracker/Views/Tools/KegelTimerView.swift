import SwiftUI
import Combine

struct KegelTimerView: View {
    @State private var phase: KegelPhase = .ready
    @State private var setCount = 0
    @State private var repCount = 0
    @State private var countdown = 0
    @State private var isRunning = false
    @State private var completePulse = 0

    private let holdSeconds = 5
    private let releaseSeconds = 5
    private let restSeconds = 10
    private let repsPerSet = 10
    private let totalSets = 3

    enum KegelPhase { case ready, hold, release, rest, complete }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ring
                phaseLabel
                stats
                actions
                instructionCard
            }
            .padding()
            .padding(.top, 8)
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.toolsKegelTimer)
        .bloomlyThemedNavigation()
        .bloomlyThemeAware()
        .bloomlyLanguageAware()
        .sensoryFeedback(.impact(weight: .light), trigger: phase)
        .sensoryFeedback(.success, trigger: completePulse)
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            tick()
        }
        .onDisappear { reset(toReady: true) }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .fill(phaseColor.opacity(0.16))
                .frame(width: 210, height: 210)

            Circle()
                .stroke(BloomlyTheme.creamDark, lineWidth: 10)
                .frame(width: 196, height: 196)

            Circle()
                .trim(from: 0, to: ringProgress)
                .stroke(phaseColor, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 196, height: 196)
                .animation(.linear(duration: 0.25), value: countdown)

            VStack(spacing: 6) {
                Text(countdownText)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(phaseColor)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                Text("s")
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
    }

    private var phaseLabel: some View {
        Text(phaseTitle)
            .font(.system(size: 28, weight: .bold, design: .rounded))
            .foregroundStyle(BloomlyTheme.textPrimary)
    }

    private var stats: some View {
        VStack(spacing: 12) {
            HStack(spacing: 8) {
                ForEach(0..<totalSets, id: \.self) { index in
                    Capsule()
                        .fill(index < setCount ? BloomlyTheme.sageDark : BloomlyTheme.creamDark)
                        .frame(height: 8)
                }
            }
            .padding(.horizontal, 24)

            HStack(spacing: 12) {
                statCard(L10n.kegelSetOf(displayedSet), icon: "square.stack.fill")
                statCard(L10n.kegelRepOf(repCount), icon: "repeat")
            }
        }
    }

    private var displayedSet: Int {
        if phase == .complete { return totalSets }
        return min(setCount + 1, totalSets)
    }

    private func statCard(_ title: String, icon: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(BloomlyTheme.sageDark)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BloomlyTheme.textPrimary)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var actions: some View {
        VStack(spacing: 12) {
            Button(action: primaryAction) {
                Text(primaryTitle)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(phaseColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)

            if phase != .ready {
                Button(L10n.commonReset) { reset(toReady: true) }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
    }

    private var instructionCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title2)
                .foregroundStyle(BloomlyTheme.sageDark)
                .padding(.top, 2)
            Text(L10n.t("tools.kegel.instructions"))
                .font(.subheadline)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var primaryTitle: String {
        if phase == .complete { return L10n.commonStart }
        if phase == .ready { return L10n.commonStart }
        if isRunning { return L10n.commonPause }
        return L10n.commonResume
    }

    private var phaseTitle: String {
        switch phase {
        case .ready: return L10n.t("tools.kegel.ready")
        case .hold: return L10n.t("tools.kegel.hold")
        case .release: return L10n.t("tools.kegel.release")
        case .rest: return L10n.t("tools.kegel.rest")
        case .complete: return L10n.t("tools.kegel.complete")
        }
    }

    private var phaseColor: Color {
        switch phase {
        case .ready, .complete: return BloomlyTheme.sageDark
        case .hold: return BloomlyTheme.sageDark
        case .release: return BloomlyTheme.sage
        case .rest: return BloomlyTheme.blushDark
        }
    }

    private var phaseDuration: Int {
        switch phase {
        case .hold: return holdSeconds
        case .release: return releaseSeconds
        case .rest: return restSeconds
        default: return holdSeconds
        }
    }

    private var ringProgress: Double {
        guard phase != .ready, phase != .complete else { return phase == .complete ? 1 : 0 }
        return Double(countdown) / Double(max(phaseDuration, 1))
    }

    private var countdownText: String {
        if phase == .ready { return "\(holdSeconds)" }
        if phase == .complete { return "0" }
        return "\(countdown)"
    }

    private func primaryAction() {
        if phase == .ready || phase == .complete {
            startSession()
        } else if isRunning {
            isRunning = false
        } else {
            isRunning = true
        }
    }

    private func startSession() {
        setCount = 0
        repCount = 0
        beginHold()
        isRunning = true
    }

    private func tick() {
        guard isRunning, phase != .ready, phase != .complete else { return }
        countdown -= 1
        if countdown <= 0 {
            advance()
        }
    }

    private func beginHold() {
        phase = .hold
        countdown = holdSeconds
    }

    private func beginRelease() {
        phase = .release
        countdown = releaseSeconds
    }

    private func beginRest() {
        phase = .rest
        countdown = restSeconds
    }

    private func advance() {
        switch phase {
        case .hold:
            beginRelease()
        case .release:
            repCount += 1
            if repCount >= repsPerSet {
                repCount = 0
                setCount += 1
                if setCount >= totalSets {
                    phase = .complete
                    countdown = 0
                    isRunning = false
                    completePulse += 1
                } else {
                    beginRest()
                }
            } else {
                beginHold()
            }
        case .rest:
            beginHold()
        case .ready, .complete:
            break
        }
    }

    private func reset(toReady: Bool) {
        isRunning = false
        countdown = 0
        setCount = 0
        repCount = 0
        if toReady {
            phase = .ready
        }
    }
}
