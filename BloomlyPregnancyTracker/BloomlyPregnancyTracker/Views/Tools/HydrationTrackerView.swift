import SwiftUI
import SwiftData

struct HydrationTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    @State private var tapPulse = 0
    @State private var goalPulse = 0

    private let goal = 8
    private let maxGlasses = 12

    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private var glasses: Int { todayLog?.waterGlasses ?? 0 }
    private var goalReached: Bool { glasses >= goal }
    private var progress: Double { min(Double(glasses) / Double(goal), 1) }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                ring
                stepper
                glassGrid
                caption
            }
            .padding()
            .padding(.top, 8)
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.toolsHydration)
        .bloomlyThemedNavigation()
        .bloomlyThemeAware()
        .bloomlyLanguageAware()
        .sensoryFeedback(.impact(weight: .light), trigger: tapPulse)
        .sensoryFeedback(.success, trigger: goalPulse)
    }

    private var ring: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.12))
                .frame(width: 210, height: 210)

            Circle()
                .stroke(BloomlyTheme.creamDark, lineWidth: 10)
                .frame(width: 196, height: 196)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 196, height: 196)
                .animation(.spring(response: 0.4, dampingFraction: 0.75), value: glasses)

            VStack(spacing: 4) {
                Text("\(glasses)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.blue)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: glasses)
                Text("/ \(goal)")
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.homeWaterIntake)
        .accessibilityValue("\(glasses) / \(goal)")
    }

    private var stepper: some View {
        HStack(spacing: 28) {
            Button { adjust(-1) } label: {
                Image(systemName: "minus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(BloomlyTheme.sageDark)
                    .frame(width: 56, height: 56)
                    .background(BloomlyTheme.cardBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(glasses <= 0)
            .opacity(glasses <= 0 ? 0.4 : 1)

            Text(L10n.homeGlassesOfWater)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BloomlyTheme.textSecondary)

            Button { adjust(1) } label: {
                Image(systemName: "plus")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(BloomlyTheme.sageDark)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .disabled(glasses >= maxGlasses)
            .opacity(glasses >= maxGlasses ? 0.4 : 1)
        }
    }

    private var glassGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 12) {
            ForEach(0..<goal, id: \.self) { index in
                let filled = index < min(glasses, goal)
                Button { tapGlass(index) } label: {
                    VStack(spacing: 8) {
                        Image(systemName: filled ? "drop.fill" : "drop")
                            .font(.title)
                            .foregroundStyle(filled ? Color.blue : BloomlyTheme.creamDark)
                            .symbolEffect(.bounce, value: filled && index == glasses - 1)
                        Text("\(index + 1)")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(BloomlyTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var caption: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: goalReached ? "checkmark.circle.fill" : "drop.fill")
                .font(.title2)
                .foregroundStyle(goalReached ? BloomlyTheme.sageDark : Color.blue)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 4) {
                Text(goalReached ? L10n.hydrationGoalReached : L10n.homeDailyGoalWater)
                    .font(.headline)
                    .foregroundStyle(BloomlyTheme.textPrimary)
                Text(L10n.hydrationTapHint)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BloomlyTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func tapGlass(_ index: Int) {
        if index < glasses {
            setGlasses(index)
        } else if index == glasses {
            setGlasses(index + 1)
        }
    }

    private func adjust(_ delta: Int) {
        setGlasses(glasses + delta)
    }

    private func setGlasses(_ value: Int) {
        let next = min(maxGlasses, max(0, value))
        let wasBelowGoal = glasses < goal
        if let log = todayLog {
            log.waterGlasses = next
        } else if next > 0 {
            modelContext.insert(DailyLog(waterGlasses: next))
        }
        tapPulse += 1
        if wasBelowGoal && next >= goal {
            goalPulse += 1
        }
    }
}
