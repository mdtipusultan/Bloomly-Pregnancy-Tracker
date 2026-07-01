import SwiftUI
import SwiftData
import Charts

struct ProfileView: View {
    @Query private var profiles: [UserProfile]
    @State private var showPaywall = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            List {
                Section("Account") {
                    if let profile {
                        LabeledContent("Mode", value: profile.trackingMode == "pregnant" ? "Pregnant" : "Planning")
                        if profile.trackingMode == "pregnant" {
                            if let due = profile.dueDate {
                                LabeledContent("Due Date", value: due.formatted(date: .abbreviated, time: .omitted))
                            }
                            LabeledContent("Week", value: "\(PregnancyCalculator.currentWeek(profile: profile))")
                        }
                        LabeledContent("Premium", value: profile.isPremium ? "Bloomly Plus" : "Free")
                    }
                }

                Section("Features") {
                    NavigationLink("Baby Names") { BabyNamesView() }
                    if profile?.isPremium == true {
                        NavigationLink("Appointments") { AppointmentsView() }
                        NavigationLink("Nutrition Guide") { NutritionView() }
                        NavigationLink("Statistics") { StatisticsView() }
                    }
                    if profile?.trackingMode == "planning" {
                        NavigationLink("Cycle Tracker") { CycleTrackerView() }
                    }
                    if profile?.isPremium != true {
                        Button("Upgrade to Bloomly Plus") { showPaywall = true }
                    }
                }

                Section("Settings") {
                    NavigationLink("Privacy") { PrivacyView() }
                }
            }
            .navigationTitle("Profile")
            .sheet(isPresented: $showPaywall) {
                PaywallView(onComplete: {})
            }
        }
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Privacy Matters")
                    .font(.title2.bold())
                Text("Bloomly is designed with privacy at its core. All your pregnancy data, health logs, appointments, and preferences are stored exclusively on your device.")
                Text("We do not:")
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    bullet("Collect any personal data")
                    bullet("Send data to servers or the cloud")
                    bullet("Use analytics or tracking SDKs")
                    bullet("Show advertisements")
                    bullet("Require an account or login")
                }
                Text("Your data never leaves your iPhone unless you choose to back up your device through iCloud or iTunes.")
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle("Privacy")
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .top) {
            Text("•")
            Text(text)
        }
    }
}

struct BabyNamesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var savedNames: [SavedName]
    @State private var genderFilter = "all"
    @State private var letterFilter = "all"
    @State private var styleFilter = "all"
    @State private var showFavoritesOnly = false

    private var allNames: [BabyNameEntry] { ContentLoader.loadBabyNames() }

    private var filteredNames: [BabyNameEntry] {
        allNames.filter { name in
            if showFavoritesOnly && !savedNames.contains(where: { $0.name == name.name }) { return false }
            if genderFilter != "all" && name.gender != genderFilter { return false }
            if letterFilter != "all" && name.letter != letterFilter { return false }
            if styleFilter != "all" && name.style != styleFilter { return false }
            return true
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            filters
            List(filteredNames) { name in
                HStack {
                    VStack(alignment: .leading) {
                        Text(name.name).font(.headline)
                        Text("\(name.gender.capitalized) · \(name.style.capitalized)")
                            .font(.caption)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    Spacer()
                    Button {
                        toggleFavorite(name)
                    } label: {
                        Image(systemName: isSaved(name) ? "heart.fill" : "heart")
                            .foregroundStyle(BloomlyTheme.blushDark)
                    }
                }
            }
        }
        .navigationTitle("Baby Names")
        .toolbar {
            Toggle("Favorites", isOn: $showFavoritesOnly)
        }
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                filterMenu("Gender", selection: $genderFilter, options: ["all", "boy", "girl", "neutral"])
                filterMenu("Letter", selection: $letterFilter, options: ["all"] + (65...90).map { String(UnicodeScalar($0)!) })
                filterMenu("Style", selection: $styleFilter, options: ["all", "classic", "modern", "nature", "international"])
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    private func filterMenu(_ title: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { opt in
                Button(opt.capitalized) { selection.wrappedValue = opt }
            }
        } label: {
            Text("\(title): \(selection.wrappedValue.capitalized)")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(BloomlyTheme.creamDark)
                .clipShape(Capsule())
        }
    }

    private func isSaved(_ name: BabyNameEntry) -> Bool {
        savedNames.contains { $0.name == name.name }
    }

    private func toggleFavorite(_ name: BabyNameEntry) {
        if let existing = savedNames.first(where: { $0.name == name.name }) {
            modelContext.delete(existing)
        } else {
            modelContext.insert(SavedName(name: name.name, gender: name.gender, style: name.style))
        }
    }
}

struct AppointmentsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Appointment.date) private var appointments: [Appointment]
    @State private var showAdd = false

    private var upcoming: [Appointment] { appointments.filter { $0.date >= .now } }
    private var past: [Appointment] { appointments.filter { $0.date < .now }.reversed() }

    var body: some View {
        List {
            Section("Upcoming") {
                if upcoming.isEmpty {
                    Text("No upcoming appointments").foregroundStyle(BloomlyTheme.textSecondary)
                }
                ForEach(upcoming) { appt in
                    appointmentRow(appt)
                }
                .onDelete { indexSet in delete(upcoming, at: indexSet) }
            }
            Section("Past") {
                ForEach(past) { appt in
                    appointmentRow(appt)
                }
                .onDelete { indexSet in delete(Array(past), at: indexSet) }
            }
        }
        .navigationTitle("Appointments")
        .toolbar {
            Button { showAdd = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAdd) { AddAppointmentSheet() }
    }

    private func appointmentRow(_ appt: Appointment) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(appt.title).font(.headline)
            Text(appt.date.formatted(date: .abbreviated, time: .shortened))
                .font(.caption)
            if let loc = appt.location { Text(loc).font(.caption2).foregroundStyle(BloomlyTheme.textSecondary) }
            Text(appt.type.capitalized).font(.caption2).foregroundStyle(BloomlyTheme.sageDark)
        }
    }

    private func delete(_ list: [Appointment], at offsets: IndexSet) {
        for i in offsets {
            let appt = list[i]
            NotificationManager.cancelAppointmentReminders(id: appt.notificationID)
            modelContext.delete(appt)
        }
    }
}

struct AddAppointmentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var title = ""
    @State private var location = ""
    @State private var date = Date()
    @State private var type = "checkup"

    private let types = ["checkup", "ultrasound", "blood test", "glucose test", "other"]

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)
                TextField("Location", text: $location)
                DatePicker("Date & Time", selection: $date)
                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) { Text($0.capitalized).tag($0) }
                }
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { Task { await save() }; dismiss() }.disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() async {
        let notifID = UUID().uuidString
        let appt = Appointment(
            date: date,
            title: title,
            location: location.isEmpty ? nil : location,
            type: type,
            notificationID: notifID
        )
        modelContext.insert(appt)
        _ = await NotificationManager.scheduleAppointmentReminders(for: appt, id: notifID)
    }
}

struct NutritionView: View {
    @Query private var profiles: [UserProfile]

    private var trimester: String {
        guard let profile = profiles.first, profile.trackingMode == "pregnant" else { return "all" }
        return String(PregnancyCalculator.trimester(for: PregnancyCalculator.currentWeek(profile: profile)))
    }

    private var sections: [NutritionSection] {
        ContentLoader.loadNutrition().filter { $0.trimester == "all" || $0.trimester == trimester }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sections) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.title).font(.headline)
                        ForEach(section.items, id: \.self) { item in
                            HStack(alignment: .top) {
                                Text("•")
                                Text(item)
                            }
                            .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .bloomlyCard()
                }
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle("Nutrition")
    }
}

struct StatisticsView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date) private var logs: [DailyLog]

    private var weightData: [(date: Date, weight: Double)] {
        logs.compactMap { log in
            guard let w = log.weightValue else { return nil }
            return (log.date, w)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                weightChart
                symptomChart
                moodCalendar
                waterStreak
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle("Statistics")
    }

    private var weightChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weight Over Time").font(.headline)
            if weightData.isEmpty {
                Text("No weight data yet").foregroundStyle(BloomlyTheme.textSecondary)
            } else {
                Chart(weightData, id: \.date) { item in
                    LineMark(x: .value("Date", item.date), y: .value("Weight", item.weight))
                        .foregroundStyle(BloomlyTheme.sage)
                }
                .frame(height: 200)
            }
        }
        .bloomlyCard()
    }

    private var symptomChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Symptom Frequency").font(.headline)
            let freq = StatsCalculator.symptomFrequency(from: logs).prefix(5)
            if freq.isEmpty {
                Text("No symptom data yet").foregroundStyle(BloomlyTheme.textSecondary)
            } else {
                Chart(Array(freq), id: \.symptom) { item in
                    BarMark(x: .value("Count", item.count), y: .value("Symptom", SymptomCatalog.all.first { $0.key == item.symptom }?.label ?? item.symptom))
                        .foregroundStyle(BloomlyTheme.blushDark)
                }
                .frame(height: 180)
            }
        }
        .bloomlyCard()
    }

    private var moodCalendar: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Mood History").font(.headline)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
                ForEach(logs.filter { $0.mood > 0 }.suffix(28)) { log in
                    Text(log.mood <= 5 ? SymptomCatalog.moodEmojis[log.mood - 1] : "—")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(4)
                        .background(BloomlyTheme.moodColor(for: log.mood).opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .bloomlyCard()
    }

    private var waterStreak: some View {
        let streak = StatsCalculator.waterStreak(from: logs)
        return VStack(alignment: .leading, spacing: 8) {
            Text("Water Streak").font(.headline)
            HStack {
                VStack {
                    Text("\(streak.current)").font(.title.bold())
                    Text("Current").font(.caption)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(streak.best)").font(.title.bold())
                    Text("Best").font(.caption)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .bloomlyCard()
    }
}

struct CycleTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \PeriodLog.startDate, order: .reverse) private var periodLogs: [PeriodLog]
    @State private var showAddPeriod = false

    var body: some View {
        List {
            if let next = CycleCalculator.predictNextPeriod(after: periodLogs, cycleLength: profiles.first?.averageCycleLength ?? 28) {
                Section("Prediction") {
                    LabeledContent("Next Period", value: next.formatted(date: .abbreviated, time: .omitted))
                    if let last = periodLogs.first {
                        let window = CycleCalculator.fertileWindow(from: last.startDate, cycleLength: profiles.first?.averageCycleLength ?? 28)
                        LabeledContent("Fertile Window", value: "\(window.start.formatted(date: .abbreviated, time: .omitted)) – \(window.end.formatted(date: .abbreviated, time: .omitted))")
                        LabeledContent("Ovulation Estimate", value: window.ovulation.formatted(date: .abbreviated, time: .omitted))
                    }
                }
            }
            Section("History") {
                ForEach(periodLogs) { log in
                    VStack(alignment: .leading) {
                        Text("\(log.startDate.formatted(date: .abbreviated, time: .omitted)) – \(log.endDate?.formatted(date: .abbreviated, time: .omitted) ?? "ongoing")")
                    }
                }
                .onDelete { offsets in
                    for i in offsets { modelContext.delete(periodLogs[i]) }
                }
            }
        }
        .navigationTitle("Cycle Tracker")
        .toolbar {
            Button { showAddPeriod = true } label: { Image(systemName: "plus") }
        }
        .sheet(isPresented: $showAddPeriod) { AddPeriodSheet() }
    }
}

struct AddPeriodSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var hasEndDate = false

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                Toggle("Period ended", isOn: $hasEndDate)
                if hasEndDate {
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Log Period")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save(); dismiss() } }
            }
        }
    }

    private func save() {
        modelContext.insert(PeriodLog(startDate: startDate, endDate: hasEndDate ? endDate : nil))
    }
}
