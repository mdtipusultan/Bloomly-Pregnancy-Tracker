import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var showWaterLog = false
    @State private var showSymptomLog = false
    @State private var showMoodLog = false
    @State private var showWeightLog = false

    private var profile: UserProfile? { profiles.first }
    private var week: Int { profile.map { PregnancyCalculator.currentWeek(profile: $0) } ?? 1 }
    private var weekEntry: WeekGuideEntry? { profile.flatMap { PregnancyCalculator.weekEntry(for: $0) } }
    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if profile?.trackingMode == "planning" {
                        planningHeader
                    } else {
                        pregnancyHeader
                    }
                    dailyTipCard
                    quickLogSection
                    if profile?.trackingMode == "pregnant" {
                        progressSection
                    }
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle("Home")
            .sheet(isPresented: $showWaterLog) { QuickWaterLogSheet() }
            .sheet(isPresented: $showSymptomLog) { QuickSymptomLogSheet() }
            .sheet(isPresented: $showMoodLog) { QuickMoodLogSheet() }
            .sheet(isPresented: $showWeightLog) { QuickWeightLogSheet() }
        }
    }

    private var pregnancyHeader: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Week \(week)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomlyTheme.blushDark)
                    if let days = profile.flatMap({ PregnancyCalculator.daysUntilDue(profile: $0) }) {
                        Text(days >= 0 ? "\(days) days until due date" : "Your due date has passed")
                            .font(.subheadline)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                }
                Spacer()
                ProgressRingView(progress: profile.map { PregnancyCalculator.progress(profile: $0) } ?? 0)
                    .frame(width: 64, height: 64)
            }

            if let entry = weekEntry {
                VStack(alignment: .leading, spacing: 8) {
                    Label(entry.babySize, systemImage: "leaf.fill")
                        .font(.headline)
                        .foregroundStyle(BloomlyTheme.sageDark)
                    HStack {
                        Label(entry.length, systemImage: "ruler")
                        Spacer()
                        Label(entry.weight, systemImage: "scalemass")
                    }
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                }
                .bloomlyCard()
            }
        }
    }

    private var planningHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Planning Mode")
                .font(.title.bold())
            Text("Track your cycle and prepare for your journey.")
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }

    private var dailyTipCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Daily Tip", systemImage: "lightbulb.fill")
                .font(.subheadline.bold())
                .foregroundStyle(BloomlyTheme.sageDark)
            Text(ContentLoader.dailyTip(for: .now))
                .font(.body)
                .foregroundStyle(BloomlyTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Log")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickButton("Water", icon: "drop.fill", value: "\(todayLog?.waterGlasses ?? 0)/8", color: .blue) {
                    showWaterLog = true
                }
                quickButton("Mood", icon: "face.smiling", value: moodLabel, color: BloomlyTheme.sage) {
                    showMoodLog = true
                }
                quickButton("Symptoms", icon: "heart.text.square", value: "\(todayLog?.symptoms.count ?? 0)", color: BloomlyTheme.blushDark, premium: true) {
                    showSymptomLog = true
                }
                quickButton("Weight", icon: "scalemass.fill", value: weightLabel, color: BloomlyTheme.sageDark, premium: true) {
                    showWeightLog = true
                }
            }
        }
    }

    private var moodLabel: String {
        guard let mood = todayLog?.mood, mood > 0, mood <= SymptomCatalog.moodEmojis.count else { return "—" }
        return SymptomCatalog.moodEmojis[mood - 1]
    }

    private var weightLabel: String {
        guard let w = todayLog?.weightValue else { return "—" }
        let unit = profile?.weightUnit ?? "kg"
        return String(format: "%.1f %@", w, unit)
    }

    private func quickButton(_ title: String, icon: String, value: String, color: Color, premium: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption.bold())
                Text(value)
                    .font(.caption2)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                if premium && !(profile?.isPremium ?? false) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(BloomlyTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Pregnancy Progress")
                .font(.headline)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(BloomlyTheme.creamDark)
                    Capsule()
                        .fill(BloomlyTheme.sage)
                        .frame(width: geo.size.width * (profile.map { PregnancyCalculator.progress(profile: $0) } ?? 0))
                }
            }
            .frame(height: 12)
            Text("Week \(week) of 40")
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .bloomlyCard()
    }
}

struct ProgressRingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(BloomlyTheme.creamDark, lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(BloomlyTheme.sage, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption2.bold())
        }
    }
}
