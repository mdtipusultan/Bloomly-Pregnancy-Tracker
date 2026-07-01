import SwiftUI
import SwiftData

struct DailyLogView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var selectedDate = Date()
    @State private var notes = ""

    private var profile: UserProfile? { profiles.first }
    private var logForDate: DailyLog? {
        let day = Calendar.current.startOfDay(for: selectedDate)
        return logs.first { Calendar.current.isDate($0.date, inSameDayAs: day) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    DatePicker("Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .bloomlyCard()
                    summarySection
                    notesSection
                }
                .padding()
            }
            .bloomlyScreenBackground()
            .navigationTitle("Daily Log")
            .onChange(of: selectedDate) { _, _ in loadNotes() }
            .onAppear { loadNotes() }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Day Summary")
                .font(.headline)
            HStack {
                summaryItem("Mood", value: moodText)
                summaryItem("Water", value: "\(logForDate?.waterGlasses ?? 0)/8")
            }
            if profile?.isPremium == true {
                HStack {
                    summaryItem("Weight", value: weightText)
                    summaryItem("Symptoms", value: "\(logForDate?.symptoms.count ?? 0)")
                }
                if let symptoms = logForDate?.symptoms, !symptoms.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(symptoms, id: \.self) { s in
                            let label = SymptomCatalog.all.first { $0.key == s }?.label ?? s
                            let sev = logForDate?.symptomSeverity[s] ?? "mild"
                            Text("\(label) (\(sev))")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(BloomlyTheme.severityColor(sev))
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .bloomlyCard()
    }

    private var moodText: String {
        guard let m = logForDate?.mood, m > 0, m <= 5 else { return "—" }
        return SymptomCatalog.moodEmojis[m - 1]
    }

    private var weightText: String {
        guard let w = logForDate?.weightValue else { return "—" }
        return String(format: "%.1f %@", w, profile?.weightUnit ?? "kg")
    }

    private func summaryItem(_ title: String, value: String) -> some View {
        VStack {
            Text(title).font(.caption).foregroundStyle(BloomlyTheme.textSecondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.headline)
            TextEditor(text: $notes)
                .frame(minHeight: 120)
                .onChange(of: notes) { _, newValue in saveNotes(newValue) }
        }
        .bloomlyCard()
    }

    private func loadNotes() {
        notes = logForDate?.notes ?? ""
    }

    private func saveNotes(_ text: String) {
        let trimmed = text.isEmpty ? nil : text
        if let log = logForDate {
            log.notes = trimmed
        } else if trimmed != nil {
            modelContext.insert(DailyLog(date: selectedDate, notes: trimmed))
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }
        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
