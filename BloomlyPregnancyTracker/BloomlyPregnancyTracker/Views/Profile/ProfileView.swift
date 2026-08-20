import SwiftUI
import SwiftData
import Charts
import StoreKit

struct ProfileView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(LanguageManager.self) private var languageManager
    @Query private var profiles: [UserProfile]
    @State private var store = StoreKitManager.shared
    @State private var showPaywall = false
    @State private var isRestoring = false

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let profile {
                        BloomlyGroupedSection(title: L10n.profileAccount) {
                            BloomlyGroupedLabeledRow(
                                title: L10n.profileMode,
                                value: profile.trackingMode == "pregnant" ? L10n.profilePregnant : L10n.profilePlanning
                            )
                            if profile.trackingMode == "pregnant" {
                                BloomlyGroupedDivider()
                                if let due = profile.dueDate {
                                    BloomlyGroupedLabeledRow(
                                        title: L10n.profileDueDate,
                                        value: due.formatted(date: .abbreviated, time: .omitted)
                                    )
                                    BloomlyGroupedDivider()
                                }
                                BloomlyGroupedLabeledRow(
                                    title: L10n.profileWeek,
                                    value: "\(PregnancyCalculator.currentWeek(profile: profile))"
                                )
                            }
                            BloomlyGroupedDivider()
                            BloomlyGroupedLabeledRow(
                                title: L10n.profilePremium,
                                value: profile.isPremium ? L10n.profileBloomlyPlus : L10n.profileFree
                            )
                        }
                    }

                    BloomlyGroupedSection(title: L10n.profileSubscription) {
                        BloomlyGroupedButtonRow {
                            Task { await restorePurchases() }
                        } label: {
                            HStack {
                                Label(L10n.profileRestorePurchases, systemImage: "arrow.clockwise")
                                Spacer()
                                if isRestoring {
                                    ProgressView()
                                }
                            }
                        }
                        .disabled(isRestoring)

                        BloomlyGroupedDivider()

                        BloomlyGroupedButtonRow {
                            showPaywall = true
                        } label: {
                            Label(L10n.profileManageSubscription, systemImage: "creditcard")
                        }
                    }

                    BloomlyGroupedSection(title: L10n.profileFeatures) {
                        featureLinks
                    }

                    BloomlyGroupedSection(title: L10n.profileSettings) {
                        if let profile {
                            PartnerSettingsFields(profile: profile)
                        }
                        settingsLinks
                    }
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle(L10n.profileTitle)
            .bloomlyThemedNavigation()
            .bloomlyThemeAware()
            .bloomlyLanguageAware()
            .onChange(of: profile?.partnerName) { _, _ in
                WidgetDataSync.sync(profile: profile)
            }
            .fullScreenCover(isPresented: $showPaywall) {
                PaywallView(onComplete: {})
            }
        }
    }

    private func restorePurchases() async {
        isRestoring = true
        defer { isRestoring = false }
        await store.restorePurchases()
        syncPremiumStatus()
    }

    private func syncPremiumStatus() {
        if let profile = profiles.first {
            profile.isPremium = store.isPremium
        }
    }

    @ViewBuilder
    private var featureLinks: some View {
        if profile?.trackingMode == "pregnant" {
            NavigationLink(L10n.profileBumpJournal) { BumpJournalView() }
                .bloomlyGroupedRow()
            BloomlyGroupedDivider()
            if let profile, let entry = PregnancyCalculator.weekEntry(for: profile) {
                NavigationLink {
                    PartnerShareView(
                        profile: profile,
                        entry: entry,
                        week: PregnancyCalculator.currentWeek(profile: profile)
                    )
                } label: {
                    Label(L10n.profileSharePartner, systemImage: "heart.text.square.fill")
                        .foregroundStyle(BloomlyTheme.textPrimary)
                }
                .bloomlyGroupedRow()
                BloomlyGroupedDivider()
            }
        }
        NavigationLink(L10n.profileBabyNames) { BabyNamesView() }
            .bloomlyGroupedRow()
        if profile?.isPremium == true {
            BloomlyGroupedDivider()
            NavigationLink(L10n.profileAppointments) { AppointmentsView() }
                .bloomlyGroupedRow()
            BloomlyGroupedDivider()
            NavigationLink(L10n.profileWeightTracker) { WeightTrackerView() }
                .bloomlyGroupedRow()
            BloomlyGroupedDivider()
            NavigationLink(L10n.profileNutrition) { NutritionView() }
                .bloomlyGroupedRow()
            BloomlyGroupedDivider()
            NavigationLink(L10n.profileStatistics) { StatisticsView() }
                .bloomlyGroupedRow()
        }
        if profile?.trackingMode == "planning" {
            BloomlyGroupedDivider()
            NavigationLink(L10n.profileCycleTracker) { CycleTrackerView() }
                .bloomlyGroupedRow()
        }
        if profile?.isPremium != true {
            BloomlyGroupedDivider()
            BloomlyGroupedButtonRow { showPaywall = true } label: {
                Text(L10n.profileUpgrade)
            }
        }
    }

    @ViewBuilder
    private var settingsLinks: some View {
        NavigationLink {
            AppearanceSettingsView()
        } label: {
            HStack {
                Label(L10n.settingsAppearance, systemImage: "paintpalette.fill")
                Spacer()
                Text(L10n.t(themeManager.selectedTheme.nameKey))
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
        .bloomlyGroupedRow()
        BloomlyGroupedDivider()
        NavigationLink {
            LanguageSettingsView()
        } label: {
            HStack {
                Label(L10n.settingsLanguage, systemImage: "globe")
                Spacer()
                Text("\(languageManager.currentLanguage.flag) \(languageManager.currentLanguage.nativeName)")
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
        }
        .bloomlyGroupedRow()
        BloomlyGroupedDivider()
        NavigationLink(L10n.profileDailyReminders) { ReminderSettingsView() }
            .bloomlyGroupedRow()
        BloomlyGroupedDivider()
        NavigationLink(L10n.profilePrivacy) { PrivacyView() }
            .bloomlyGroupedRow()
    }
}

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(L10n.profilePrivacyTitle)
                    .font(.title2.bold())
                Text(L10n.profilePrivacyBody)
                Text(L10n.profilePrivacyWeDoNot)
                    .font(.headline)
                VStack(alignment: .leading, spacing: 8) {
                    bullet(L10n.t("profile.privacyBullet1"))
                    bullet(L10n.t("profile.privacyBullet2"))
                    bullet(L10n.t("profile.privacyBullet3"))
                    bullet(L10n.t("profile.privacyBullet4"))
                    bullet(L10n.t("profile.privacyBullet5"))
                }
                Text(L10n.profilePrivacyFooter)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
            .padding()
            .bloomlyThemedScrollContent()
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.profilePrivacy)
        .bloomlyThemedNavigation()
        .bloomlyThemeAware()
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
                .bloomlyListRowBackground()
            }
            .bloomlyThemedList()
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.profileBabyNames)
        .bloomlyThemedNavigation()
        .toolbar {
            Toggle(L10n.profileFavorites, isOn: $showFavoritesOnly)
        }
    }

    private var filters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                filterMenu(L10n.commonGender, selection: $genderFilter, options: ["all", "boy", "girl", "neutral"])
                filterMenu(L10n.commonLetter, selection: $letterFilter, options: ["all"] + (65...90).map { String(UnicodeScalar($0)!) })
                filterMenu(L10n.commonStyle, selection: $styleFilter, options: ["all", "classic", "modern", "nature", "international"])
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
            Group {
                Section(L10n.profileUpcoming) {
                    if upcoming.isEmpty {
                        Text(L10n.profileNoAppointments).foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    ForEach(upcoming) { appt in
                        appointmentRow(appt)
                    }
                    .onDelete { indexSet in delete(upcoming, at: indexSet) }
                }
                Section(L10n.profilePast) {
                    ForEach(past) { appt in
                        appointmentRow(appt)
                    }
                    .onDelete { indexSet in delete(Array(past), at: indexSet) }
                }
            }
            .bloomlyListRowBackground()
        }
        .bloomlyThemedList()
        .navigationTitle(L10n.profileAppointments)
        .bloomlyThemedNavigation()
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
            .navigationTitle(L10n.profileNewAppointment)
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
        .navigationTitle(L10n.profileNutrition)
        .bloomlyThemedNavigation()
    }
}

struct StatisticsView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date) private var logs: [DailyLog]

    private var profile: UserProfile? { profiles.first }
    private var unit: String { profile?.weightUnit ?? "kg" }
    private var weightData: [(date: Date, weight: Double)] {
        WeightCalculator.entries(from: logs)
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
        .navigationTitle(L10n.profileStatistics)
        .bloomlyThemedNavigation()
    }

    private var weightChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.statsWeightOverTime).font(.headline)
                Spacer()
                NavigationLink(L10n.statsDetails) { WeightTrackerView() }
                    .font(.caption)
            }

            if weightData.isEmpty {
                Text(L10n.statsNoWeightData)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            } else {
                if let latest = weightData.last?.weight, let starting = profile?.startingWeight {
                    HStack {
                        summaryPill(L10n.weightLatest, WeightCalculator.format(latest, unit: unit))
                        summaryPill(L10n.statsGain, WeightCalculator.formatChange(latest - starting, unit: unit))
                    }
                }

                Chart {
                    if let starting = profile?.startingWeight {
                        RuleMark(y: .value("Starting", starting))
                            .foregroundStyle(BloomlyTheme.blushDark.opacity(0.4))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }
                    ForEach(weightData, id: \.date) { item in
                        LineMark(x: .value("Date", item.date), y: .value("Weight", item.weight))
                            .foregroundStyle(BloomlyTheme.sage)
                        PointMark(x: .value("Date", item.date), y: .value("Weight", item.weight))
                            .foregroundStyle(BloomlyTheme.sageDark)
                    }
                }
                .chartYAxisLabel(unit)
                .frame(height: 200)
            }
        }
        .bloomlyCard()
    }

    private func summaryPill(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.caption2).foregroundStyle(BloomlyTheme.textSecondary)
            Text(value).font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(BloomlyTheme.cream.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var symptomChart: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.statsSymptomFrequency).font(.headline)
            let freq = StatsCalculator.symptomFrequency(from: logs).prefix(5)
            if freq.isEmpty {
                Text(L10n.statsNoSymptomData).foregroundStyle(BloomlyTheme.textSecondary)
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
            Text(L10n.statsMoodHistory).font(.headline)
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
            Text(L10n.statsWaterStreak).font(.headline)
            HStack {
                VStack {
                    Text("\(streak.current)").font(.title.bold())
                    Text(L10n.statsCurrent).font(.caption)
                }
                .frame(maxWidth: .infinity)
                VStack {
                    Text("\(streak.best)").font(.title.bold())
                    Text(L10n.statsBest).font(.caption)
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
            Group {
                if let next = CycleCalculator.predictNextPeriod(after: periodLogs, cycleLength: profiles.first?.averageCycleLength ?? 28) {
                    Section(L10n.statsPrediction) {
                        LabeledContent(L10n.statsNextPeriod, value: next.formatted(date: .abbreviated, time: .omitted))
                        if let last = periodLogs.first {
                            let window = CycleCalculator.fertileWindow(from: last.startDate, cycleLength: profiles.first?.averageCycleLength ?? 28)
                            LabeledContent(L10n.statsFertileWindow, value: "\(window.start.formatted(date: .abbreviated, time: .omitted)) – \(window.end.formatted(date: .abbreviated, time: .omitted))")
                            LabeledContent(L10n.statsOvulationEstimate, value: window.ovulation.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                }
                Section(L10n.commonHistory) {
                    ForEach(periodLogs) { log in
                        VStack(alignment: .leading) {
                            Text("\(log.startDate.formatted(date: .abbreviated, time: .omitted)) – \(log.endDate?.formatted(date: .abbreviated, time: .omitted) ?? L10n.commonOngoing)")
                        }
                    }
                    .onDelete { offsets in
                        for i in offsets { modelContext.delete(periodLogs[i]) }
                    }
                }
            }
            .bloomlyListRowBackground()
        }
        .bloomlyThemedList()
        .navigationTitle(L10n.profileCycleTracker)
        .bloomlyThemedNavigation()
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
            .navigationTitle(L10n.profileLogPeriod)
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
