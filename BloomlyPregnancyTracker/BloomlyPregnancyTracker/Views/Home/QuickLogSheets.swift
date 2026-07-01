import SwiftUI
import SwiftData

struct QuickWaterLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var glasses = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("\(glasses)")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                Text("glasses of water")
                    .foregroundStyle(BloomlyTheme.textSecondary)
                HStack(spacing: 20) {
                    Button { glasses = max(0, glasses - 1) } label: {
                        Image(systemName: "minus.circle.fill").font(.largeTitle)
                    }
                    Button { glasses = min(12, glasses + 1) } label: {
                        Image(systemName: "plus.circle.fill").font(.largeTitle)
                    }
                }
                .foregroundStyle(BloomlyTheme.sageDark)
                ProgressView(value: Double(glasses), total: 8)
                    .tint(.blue)
                    .padding(.horizontal)
                Text("Daily goal: 8 glasses")
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                Spacer()
            }
            .padding()
            .bloomlyScreenBackground()
            .navigationTitle("Water Intake")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) { Button("Save") { save(); dismiss() } }
            }
            .onAppear {
                glasses = todayLog?.waterGlasses ?? 0
            }
        }
    }

    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private func save() {
        if let log = todayLog {
            log.waterGlasses = glasses
        } else {
            modelContext.insert(DailyLog(waterGlasses: glasses))
        }
    }
}

struct QuickMoodLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var selectedMood = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("How are you feeling?")
                    .font(.title3.bold())
                HStack(spacing: 16) {
                    ForEach(1...5, id: \.self) { mood in
                        Button {
                            selectedMood = mood
                        } label: {
                            Text(SymptomCatalog.moodEmojis[mood - 1])
                                .font(.system(size: selectedMood == mood ? 48 : 36))
                                .padding(8)
                                .background(selectedMood == mood ? BloomlyTheme.blush.opacity(0.5) : Color.clear)
                                .clipShape(Circle())
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .bloomlyScreenBackground()
            .navigationTitle("Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }.disabled(selectedMood == 0)
                }
            }
            .onAppear { selectedMood = todayLog?.mood ?? 0 }
        }
    }

    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private func save() {
        if let log = todayLog {
            log.mood = selectedMood
        } else {
            modelContext.insert(DailyLog(mood: selectedMood))
        }
    }
}

struct QuickSymptomLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var selected: Set<String> = []
    @State private var severities: [String: String] = [:]

    var body: some View {
        NavigationStack {
            Group {
                if profiles.first?.isPremium == true {
                    List {
                        ForEach(SymptomCatalog.all, id: \.key) { symptom in
                            Section(symptom.label) {
                                Toggle("Logged", isOn: binding(for: symptom.key))
                                if selected.contains(symptom.key) {
                                    Picker("Severity", selection: severityBinding(for: symptom.key)) {
                                        ForEach(SymptomCatalog.severities, id: \.self) { s in
                                            Text(s.capitalized).tag(s)
                                        }
                                    }
                                    .pickerStyle(.segmented)
                                }
                            }
                        }
                    }
                } else {
                    PremiumGateView(feature: "Symptom logging")
                }
            }
            .navigationTitle("Symptoms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                if profiles.first?.isPremium == true {
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { save(); dismiss() } }
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func binding(for key: String) -> Binding<Bool> {
        Binding(
            get: { selected.contains(key) },
            set: { isOn in
                if isOn { selected.insert(key); severities[key] = severities[key] ?? "mild" }
                else { selected.remove(key); severities.removeValue(forKey: key) }
            }
        )
    }

    private func severityBinding(for key: String) -> Binding<String> {
        Binding(get: { severities[key] ?? "mild" }, set: { severities[key] = $0 })
    }

    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private func loadExisting() {
        guard let log = todayLog else { return }
        selected = Set(log.symptoms)
        severities = log.symptomSeverity
    }

    private func save() {
        if let log = todayLog {
            log.symptoms = Array(selected)
            log.symptomSeverity = severities
        } else {
            modelContext.insert(DailyLog(symptoms: Array(selected), symptomSeverity: severities))
        }
    }
}

struct QuickWeightLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var weightText = ""

    var body: some View {
        NavigationStack {
            Group {
                if profiles.first?.isPremium == true {
                    VStack(spacing: 24) {
                        TextField("Weight", text: $weightText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .multilineTextAlignment(.center)
                        Text(profiles.first?.weightUnit ?? "kg")
                            .foregroundStyle(BloomlyTheme.textSecondary)
                        Spacer()
                    }
                    .padding()
                } else {
                    PremiumGateView(feature: "Weight tracking")
                }
            }
            .bloomlyScreenBackground()
            .navigationTitle("Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                if profiles.first?.isPremium == true {
                    ToolbarItem(placement: .confirmationAction) { Button("Save") { save(); dismiss() } }
                }
            }
            .onAppear {
                if let w = todayLog?.weightValue { weightText = String(format: "%.1f", w) }
            }
        }
    }

    private var todayLog: DailyLog? {
        let today = Calendar.current.startOfDay(for: .now)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }

    private func save() {
        guard let value = Double(weightText) else { return }
        if let log = todayLog {
            log.weightValue = value
        } else {
            modelContext.insert(DailyLog(weightValue: value))
        }
    }
}

struct PremiumGateView: View {
    let feature: String
    @State private var showPaywall = false

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.fill")
                .font(.largeTitle)
                .foregroundStyle(BloomlyTheme.blushDark)
            Text("\(feature) is part of Bloomly Plus")
                .font(.headline)
            Button("Upgrade") { showPaywall = true }
                .buttonStyle(.borderedProminent)
                .tint(BloomlyTheme.sageDark)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView(onComplete: {})
        }
    }
}
