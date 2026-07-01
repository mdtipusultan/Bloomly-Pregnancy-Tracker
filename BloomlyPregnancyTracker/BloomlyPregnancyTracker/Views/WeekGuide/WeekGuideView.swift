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
            .navigationTitle("Week Guide")
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
            Text("Week \(entry.week)")
                .font(.title.bold())
            detailCard("Baby Size", icon: "leaf.fill", text: entry.babySize)
            HStack {
                detailCard("Length", icon: "ruler", text: entry.length)
                detailCard("Weight", icon: "scalemass", text: entry.weight)
            }
            detailCard("Development", icon: "sparkles", text: entry.development)
            detailCard("How You May Feel", icon: "heart.fill", text: entry.momFeeling)
            detailCard("Tip", icon: "lightbulb.fill", text: entry.tip)
            if let appt = entry.appointmentReminder {
                detailCard("Appointment", icon: "calendar", text: appt)
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
}
