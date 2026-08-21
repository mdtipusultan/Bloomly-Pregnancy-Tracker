import SwiftUI
import SwiftData

struct HomeView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var showWaterLog = false
    @State private var showSymptomLog = false
    @State private var showMoodLog = false
    @State private var showWeightLog = false
    @State private var showPartnerShare = false

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
                VStack(spacing: 16) {
                    if profile?.trackingMode == "planning" {
                        planningHeader
                    } else {
                        pregnancyHeader
                    }
                    dailyTipCard
                    quickLogSection
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle(L10n.homeTitle)
            .bloomlyThemedNavigation()
            .bloomlyThemeAware()
            .bloomlyLanguageAware()
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        ReminderSettingsView()
                    } label: {
                        Image(systemName: "bell")
                    }
                    .accessibilityLabel(L10n.profileDailyReminders)
                }
            }
            .sheet(isPresented: $showWaterLog) { QuickWaterLogSheet() }
            .sheet(isPresented: $showSymptomLog) { QuickSymptomLogSheet() }
            .sheet(isPresented: $showMoodLog) { QuickMoodLogSheet() }
            .sheet(isPresented: $showWeightLog) { QuickWeightLogSheet() }
            .sheet(isPresented: $showPartnerShare) {
                if let profile, let entry = weekEntry {
                    PartnerShareView(profile: profile, entry: entry, week: week)
                }
            }
            .onAppear { WidgetDataSync.sync(profile: profile) }
            .onChange(of: week) { _, _ in WidgetDataSync.sync(profile: profile) }
        }
    }

    private var pregnancyHeader: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.weekNumber(week))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(BloomlyTheme.blushDark)
                    if let days = profile.flatMap({ PregnancyCalculator.daysUntilDue(profile: $0) }) {
                        Text(days >= 0 ? L10n.daysUntilDue(days) : L10n.homeDueDatePassed)
                            .font(.subheadline)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                }
                Spacer()
                ProgressRingView(progress: profile.map { PregnancyCalculator.progress(profile: $0) } ?? 0)
                    .frame(width: 72, height: 72)
            }

            if let entry = weekEntry {
                BabySizeCard(
                    entry: entry,
                    week: week,
                    layout: .split,
                    showShareButton: true,
                    onShare: { showPartnerShare = true }
                )

                HomeWeekChipStrip(
                    currentWeek: week,
                    weeks: weekChips(around: week)
                )
            }
        }
    }

    private var planningHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.homePlanningMode)
                .font(.title.bold())
            Text(L10n.homePlanningSubtitle)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }

    private var dailyTipCard: some View {
        NavigationLink {
            HomeDailyTipView(entry: weekEntry)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .font(.body)
                    .foregroundStyle(BloomlyTheme.sageDark)
                    .frame(width: 36, height: 36)
                    .background(BloomlyTheme.sage.opacity(0.22))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.homeDailyTip)
                        .font(.subheadline.bold())
                        .foregroundStyle(BloomlyTheme.textPrimary)
                    Text(ContentLoader.dailyTip(for: .now))
                        .font(.subheadline)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 8)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .padding(.top, 10)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .bloomlyCard()
        }
        .buttonStyle(.plain)
    }

    private var quickLogSection: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            quickButton(
                L10n.homeWater,
                icon: "drop.fill",
                value: "\(todayLog?.waterGlasses ?? 0) / 8",
                caption: L10n.homeGlasses,
                color: .blue
            ) {
                showWaterLog = true
            }
            quickButton(
                L10n.homeMood,
                icon: "face.smiling",
                value: moodLabel,
                color: Color(red: 0.93, green: 0.76, blue: 0.32)
            ) {
                showMoodLog = true
            }
            quickButton(
                L10n.homeSymptoms,
                icon: "camera.macro",
                value: "\(todayLog?.symptoms.count ?? 0)",
                caption: L10n.homeNotedToday,
                color: BloomlyTheme.blushDark,
                premium: true
            ) {
                showSymptomLog = true
            }
            quickButton(
                L10n.homeWeight,
                icon: "scalemass.fill",
                value: weightLabel,
                caption: todayLog?.weightValue == nil ? nil : L10n.homeUpdatedToday,
                color: Color(red: 0.45, green: 0.58, blue: 0.72),
                premium: true
            ) {
                showWeightLog = true
            }
        }
    }

    private var moodLabel: String {
        guard let mood = todayLog?.mood, mood > 0, mood <= 5 else { return "—" }
        return L10n.homeMoodName(mood)
    }

    private var weightLabel: String {
        let unit = profile?.weightUnit ?? "kg"
        if let w = todayLog?.weightValue {
            return WeightCalculator.format(w, unit: unit)
        }
        if let w = profile?.startingWeight {
            return WeightCalculator.format(w, unit: unit)
        }
        return "—"
    }

    private func quickButton(
        _ title: String,
        icon: String,
        value: String,
        caption: String? = nil,
        color: Color,
        premium: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(color)
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(BloomlyTheme.textPrimary)
                    Spacer(minLength: 0)
                    if premium && !(profile?.isPremium ?? false) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                }

                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(BloomlyTheme.textPrimary)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                if let caption {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
            .padding(14)
            .background(BloomlyTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func weekChips(around week: Int) -> [Int] {
        let lower = max(week - 2, 1)
        let upper = min(week + 2, 42)
        return Array(lower...upper)
    }
}

private struct HomeWeekChipStrip: View {
    let currentWeek: Int
    let weeks: [Int]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(weeks, id: \.self) { week in
                let isCurrent = week == currentWeek
                Text(L10n.homeWeekChip(week))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(isCurrent ? .white : BloomlyTheme.textSecondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrent ? BloomlyTheme.sage : BloomlyTheme.creamDark.opacity(0.7))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(L10n.weekNumber(currentWeek))
    }
}

private struct HomeDailyTipView: View {
    let entry: WeekGuideEntry?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                tipCard(
                    title: L10n.homeDailyTip,
                    icon: "lightbulb.fill",
                    text: ContentLoader.dailyTip(for: .now)
                )

                if let entry {
                    tipCard(
                        title: L10n.homeThisWeeksTip,
                        icon: "leaf.fill",
                        text: entry.localizedTip
                    )
                    tipCard(
                        title: L10n.weekGuideDevelopment,
                        icon: "sparkles",
                        text: entry.localizedDevelopment
                    )
                    tipCard(
                        title: L10n.weekGuideMomFeeling,
                        icon: "heart.fill",
                        text: entry.localizedMomFeeling
                    )
                }
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.homeDailyTip)
        .bloomlyThemedNavigation()
        .bloomlyLanguageAware()
    }

    private func tipCard(title: String, icon: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundStyle(BloomlyTheme.sageDark)
            Text(text)
                .font(.body)
                .foregroundStyle(BloomlyTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }
}

struct ProgressRingView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(BloomlyTheme.creamDark, lineWidth: 7)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(BloomlyTheme.sage, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.caption.bold())
                .foregroundStyle(BloomlyTheme.textPrimary)
        }
        .accessibilityLabel(L10n.homePregnancyProgress)
        .accessibilityValue("\(Int(progress * 100))%")
    }
}
