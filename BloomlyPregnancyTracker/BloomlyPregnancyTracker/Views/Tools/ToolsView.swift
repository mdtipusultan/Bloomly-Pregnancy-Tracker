import SwiftUI
import SwiftData

struct ToolsView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        NavigationStack {
            List {
                if profiles.first?.isPremium == true {
                    NavigationLink { KegelTimerView() } label: {
                        toolRow("Kegel Timer", icon: "timer", subtitle: "3 sets × 10 reps")
                    }
                    NavigationLink { KickCounterView() } label: {
                        toolRow("Kick Counter", icon: "hand.tap.fill", subtitle: "Track baby movements")
                    }
                    NavigationLink { ContractionTimerView() } label: {
                        toolRow("Contraction Timer", icon: "waveform.path", subtitle: "Time contractions")
                    }
                    NavigationLink { HydrationTrackerView() } label: {
                        toolRow("Hydration Tracker", icon: "drop.fill", subtitle: "Visual water counter")
                    }
                } else {
                    Section {
                        PremiumGateView(feature: "Wellness tools")
                            .listRowBackground(Color.clear)
                    }
                }
            }
            .navigationTitle("Tools")
        }
    }

    private func toolRow(_ title: String, icon: String, subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(BloomlyTheme.sageDark)
                .frame(width: 36)
            VStack(alignment: .leading) {
                Text(title).font(.headline)
                Text(subtitle).font(.caption).foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct KegelTimerView: View {
    @State private var phase: KegelPhase = .ready
    @State private var setCount = 0
    @State private var repCount = 0
    @State private var timer: Timer?
    @State private var countdown = 0

    enum KegelPhase { case ready, hold, release, rest, complete }

    var body: some View {
        VStack(spacing: 32) {
            Text("Set \(min(setCount + 1, 3)) of 3")
                .font(.headline)
            Text("Rep \(repCount) of 10")
                .foregroundStyle(BloomlyTheme.textSecondary)
            Text(phaseLabel)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(BloomlyTheme.sageDark)
            if countdown > 0 {
                Text("\(countdown)s")
                    .font(.title)
            }
            Button(setCount >= 3 && phase == .complete ? "Done!" : (phase == .ready ? "Start" : "Pause")) {
                if phase == .ready || phase == .complete { startSession() }
                else { stopTimer() }
            }
            .buttonStyle(.borderedProminent)
            .tint(BloomlyTheme.sageDark)
            .disabled(setCount >= 3 && phase == .complete)
            Text("Hold for 5 seconds, release for 5 seconds")
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Spacer()
        }
        .padding()
        .bloomlyScreenBackground()
        .navigationTitle("Kegel Timer")
        .onDisappear { stopTimer() }
    }

    private var phaseLabel: String {
        switch phase {
        case .ready: return "Ready"
        case .hold: return "Hold"
        case .release: return "Release"
        case .rest: return "Rest"
        case .complete: return "Complete!"
        }
    }

    private func startSession() {
        setCount = 0; repCount = 0; phase = .hold; runHold()
    }

    private func runHold() {
        countdown = 5; phase = .hold
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            countdown -= 1
            if countdown <= 0 { t.invalidate(); runRelease() }
        }
    }

    private func runRelease() {
        countdown = 5; phase = .release
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            countdown -= 1
            if countdown <= 0 {
                t.invalidate()
                repCount += 1
                if repCount >= 10 {
                    repCount = 0; setCount += 1
                    if setCount >= 3 { phase = .complete }
                    else { phase = .rest; countdown = 10; runRest() }
                } else { runHold() }
            }
        }
    }

    private func runRest() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { t in
            countdown -= 1
            if countdown <= 0 { t.invalidate(); runHold() }
        }
    }

    private func stopTimer() {
        timer?.invalidate(); timer = nil; phase = .ready; countdown = 0
    }
}

struct KickCounterView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var kicks = 0
    @State private var sessionStart: Date?
    @State private var isActive = false

    var body: some View {
        VStack(spacing: 32) {
            Text("\(kicks)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(BloomlyTheme.blushDark)
            Text("kicks")
                .foregroundStyle(BloomlyTheme.textSecondary)
            Button {
                if !isActive { isActive = true; sessionStart = .now }
                kicks += 1
            } label: {
                Text("Tap for Kick")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(BloomlyTheme.sage)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            if isActive {
                Button("Save Session") { saveSession() }
                    .buttonStyle(.borderedProminent)
                    .tint(BloomlyTheme.sageDark)
                Button("Reset") { kicks = 0; isActive = false; sessionStart = nil }
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
            Spacer()
        }
        .padding()
        .bloomlyScreenBackground()
        .navigationTitle("Kick Counter")
    }

    private func saveSession() {
        guard let start = sessionStart else { return }
        let minutes = Int(Date().timeIntervalSince(start) / 60)
        modelContext.insert(KickSession(startTime: start, kicks: kicks, durationMinutes: max(minutes, 1)))
        kicks = 0; isActive = false; sessionStart = nil
    }
}

struct ContractionTimerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ContractionSession.startTime, order: .reverse) private var sessions: [ContractionSession]
    @State private var activeSession: ContractionSession?
    @State private var timer: Timer?
    @State private var elapsed: TimeInterval = 0

    var body: some View {
        VStack(spacing: 24) {
            Text(formatTime(elapsed))
                .font(.system(size: 56, weight: .bold, design: .monospaced))
                .foregroundStyle(BloomlyTheme.blushDark)
            Button(activeSession == nil ? "Start Contraction" : "Stop Contraction") {
                toggleContraction()
            }
            .buttonStyle(.borderedProminent)
            .tint(BloomlyTheme.sageDark)
            if !sessions.isEmpty {
                List(sessions.prefix(10)) { session in
                    VStack(alignment: .leading) {
                        Text(session.startTime.formatted(date: .omitted, time: .shortened))
                        if let duration = session.duration {
                            Text("Duration: \(formatTime(duration))")
                                .font(.caption)
                        }
                        if let interval = session.intervalFromPrevious {
                            Text("Interval: \(formatTime(interval))")
                                .font(.caption)
                                .foregroundStyle(BloomlyTheme.textSecondary)
                        }
                    }
                }
                .frame(maxHeight: 250)
            }
            Spacer()
        }
        .padding()
        .bloomlyScreenBackground()
        .navigationTitle("Contraction Timer")
        .onDisappear { timer?.invalidate() }
    }

    private func toggleContraction() {
        if let active = activeSession {
            active.endTime = .now
            timer?.invalidate(); timer = nil
            elapsed = 0; activeSession = nil
        } else {
            let lastEnd = sessions.first?.endTime
            let interval = lastEnd.map { Date().timeIntervalSince($0) }
            let session = ContractionSession(startTime: .now, intervalFromPrevious: interval)
            modelContext.insert(session)
            activeSession = session
            elapsed = 0
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                elapsed = Date().timeIntervalSince(session.startTime)
            }
        }
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        let mins = Int(interval) / 60
        let secs = Int(interval) % 60
        return String(format: "%d:%02d", mins, secs)
    }
}

struct HydrationTrackerView: View {
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    private var todayGlasses: Int {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }?.waterGlasses ?? 0
    }

    var body: some View {
        VStack(spacing: 24) {
            Text("\(todayGlasses) / 8")
                .font(.title.bold())
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                ForEach(0..<8, id: \.self) { i in
                    Image(systemName: i < todayGlasses ? "cup.and.saucer.fill" : "cup.and.saucer")
                        .font(.largeTitle)
                        .foregroundStyle(i < todayGlasses ? .blue : BloomlyTheme.creamDark)
                }
            }
            Text("Log water from the Home tab quick actions")
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Spacer()
        }
        .padding()
        .bloomlyScreenBackground()
        .navigationTitle("Hydration")
    }
}
