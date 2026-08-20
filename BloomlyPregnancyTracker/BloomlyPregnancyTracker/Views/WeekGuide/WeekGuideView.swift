import SwiftUI
import SwiftData

struct WeekGuideView: View {
    @Query private var profiles: [UserProfile]
    @State private var selectedWeek: Int = 1

    private var profile: UserProfile? { profiles.first }
    private var weeks: [WeekGuideEntry] { ContentLoader.loadWeekGuide() }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    weekPicker
                    if let entry = weeks.first(where: { $0.week == selectedWeek }) {
                        weekDetail(entry)
                    }
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle(L10n.weekGuideTitle)
            .bloomlyThemedNavigation()
            .bloomlyThemeAware()
            .bloomlyLanguageAware()
            .onAppear {
                selectedWeek = profile.map { PregnancyCalculator.currentWeek(profile: $0) } ?? 1
            }
        }
    }

    private var weekPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...42, id: \.self) { week in
                    Button {
                        selectedWeek = week
                    } label: {
                        Text("\(week)")
                            .font(.subheadline.bold())
                            .frame(width: 44, height: 44)
                            .background(selectedWeek == week ? BloomlyTheme.sage : BloomlyTheme.creamDark)
                            .foregroundStyle(selectedWeek == week ? .white : BloomlyTheme.textPrimary)
                            .clipShape(Circle())
                    }
                }
            }
        }
    }

    private func weekDetail(_ entry: WeekGuideEntry) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.weekNumber(entry.week))
                .font(.title.bold())
            BabySizeCard(entry: entry, week: entry.week)
            BabySizeTimelineStrip(currentWeek: entry.week, entries: timelineEntries(around: entry.week))
            HStack {
                detailCard(L10n.weekGuideLength, icon: "ruler", text: entry.length)
                detailCard(L10n.weekGuideWeight, icon: "scalemass", text: entry.weight)
            }
            detailCard(L10n.weekGuideDevelopment, icon: "sparkles", text: entry.localizedDevelopment)
            detailCard(L10n.weekGuideMomFeeling, icon: "heart.fill", text: entry.localizedMomFeeling)
            detailCard(L10n.weekGuideTip, icon: "lightbulb.fill", text: entry.localizedTip)
            if let appt = entry.localizedAppointmentReminder {
                detailCard(L10n.weekGuideAppointment, icon: "calendar", text: appt)
            }
        }
    }

    private func detailCard(_ title: String, icon: String, text: String) -> some View {
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

    private func timelineEntries(around week: Int) -> [WeekGuideEntry] {
        let lower = max(week - 4, 1)
        let upper = min(week + 4, 42)
        return weeks.filter { $0.week >= lower && $0.week <= upper }
    }
}
