import SwiftUI
import SwiftData
import Charts

struct WeightTrackerView: View {
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]
    @State private var showLogSheet = false
    @State private var showStartingWeightSheet = false

    private var profile: UserProfile? { profiles.first }
    private var unit: String { profile?.weightUnit ?? "kg" }
    private var entries: [(date: Date, weight: Double)] { WeightCalculator.entries(from: logs) }
    private var latest: (date: Date, weight: Double)? { entries.last }
    private var week: Int { profile.map { PregnancyCalculator.currentWeek(profile: $0) } ?? 0 }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryCards
                chartSection
                if profile?.trackingMode == "pregnant", week > 0 {
                    guidanceCard
                }
                historySection
            }
            .padding()
        }
        .bloomlyScreenBackground()
        .navigationTitle(L10n.profileWeightTracker)
        .bloomlyThemedNavigation()
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(L10n.commonLog) { showLogSheet = true }
            }
        }
        .bloomlyLanguageAware()
        .sheet(isPresented: $showLogSheet) {
            WeightLogSheet()
        }
        .sheet(isPresented: $showStartingWeightSheet) {
            StartingWeightSheet()
        }
    }

    private var summaryCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                statCard(
                    title: L10n.weightLatest,
                    value: latest.map { WeightCalculator.format($0.weight, unit: unit) } ?? "—",
                    subtitle: latest.map { $0.date.formatted(date: .abbreviated, time: .omitted) } ?? L10n.weightNotLoggedYet
                )
                statCard(
                    title: L10n.weightStarting,
                    value: profile?.startingWeight.map { WeightCalculator.format($0, unit: unit) } ?? L10n.weightSet,
                    subtitle: profile?.startingWeight == nil ? L10n.t("weight.tapToAdd") : L10n.weightPrePregnancy
                )
                .onTapGesture {
                    if profile?.isPremium == true { showStartingWeightSheet = true }
                }
            }

            if let current = latest?.weight, let starting = profile?.startingWeight {
                let gain = WeightCalculator.totalGain(current: current, starting: starting)
                HStack(spacing: 12) {
                    statCard(
                        title: L10n.weightTotalChange,
                        value: WeightCalculator.formatChange(gain, unit: unit),
                        subtitle: L10n.weightSinceStarting
                    )
                    if let previous = WeightCalculator.previousEntry(before: .now, from: logs)?.weight {
                        let change = current - previous
                        statCard(
                            title: L10n.weightSinceLast,
                            value: WeightCalculator.formatChange(change, unit: unit),
                            subtitle: L10n.weightPreviousEntry
                        )
                    }
                }
            }
        }
    }

    private func statCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(BloomlyTheme.textPrimary)
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.weightTrend)
                .font(.headline)

            if entries.isEmpty {
                emptyState(
                    icon: "scalemass",
                    message: L10n.weightNoWeightYet,
                    actionTitle: L10n.weightLogWeight
                ) { showLogSheet = true }
            } else {
                Chart {
                    if let starting = profile?.startingWeight {
                        RuleMark(y: .value("Starting", starting))
                            .foregroundStyle(BloomlyTheme.blushDark.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    }
                    ForEach(entries, id: \.date) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.weight)
                        )
                        .foregroundStyle(BloomlyTheme.sageDark)
                        PointMark(
                            x: .value("Date", item.date),
                            y: .value("Weight", item.weight)
                        )
                        .foregroundStyle(BloomlyTheme.sage)
                    }
                }
                .chartYAxisLabel(unit)
                .frame(height: 220)
            }
        }
        .bloomlyCard()
    }

    private var guidanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(L10n.weightGuidance(week), systemImage: "info.circle.fill")
                .font(.headline)
                .foregroundStyle(BloomlyTheme.sageDark)
            Text(WeightCalculator.pregnancyGainGuidance(week: week, unit: unit))
                .font(.subheadline)
                .foregroundStyle(BloomlyTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .bloomlyCard()
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.commonHistory)
                .font(.headline)

            if entries.isEmpty {
                Text(L10n.weightHistoryEmpty)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            } else {
                ForEach(Array(entries.reversed().enumerated()), id: \.element.date) { index, item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline.bold())
                            if let starting = profile?.startingWeight {
                                Text(WeightCalculator.formatChange(item.weight - starting, unit: unit))
                                    .font(.caption)
                                    .foregroundStyle(BloomlyTheme.textSecondary)
                            }
                        }
                        Spacer()
                        Text(WeightCalculator.format(item.weight, unit: unit))
                            .font(.headline)
                    }
                    .padding(.vertical, 4)

                    if index < entries.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .bloomlyCard()
    }

    private func emptyState(icon: String, message: String, actionTitle: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(BloomlyTheme.sageDark)
            Text(message)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Button(actionTitle, action: action)
                .buttonStyle(.borderedProminent)
                .tint(BloomlyTheme.sageDark)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
}

struct WeightLogSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    @Query(sort: \DailyLog.date, order: .reverse) private var logs: [DailyLog]

    var logDate: Date = .now

    @State private var weight: Double = 0
    @State private var hasWeight = false
    @State private var showError = false

    private var profile: UserProfile? { profiles.first }
    private var unit: String { profile?.weightUnit ?? "kg" }
    private var step: Double { WeightCalculator.increment(for: unit) }

    private var existingLog: DailyLog? {
        WeightCalculator.logForDate(logDate, in: logs)
    }

    private var previousWeight: Double? {
        WeightCalculator.previousEntry(before: logDate, from: logs)?.weight
    }

    var body: some View {
        NavigationStack {
            Group {
                if profile?.isPremium == true {
                    logContent
                } else {
                    PremiumGateView(feature: L10n.profileWeightTracker)
                }
            }
            .bloomlyScreenBackground()
            .navigationTitle(navigationTitle)
            .bloomlyThemedNavigation()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(L10n.commonCancel) { dismiss() } }
                if profile?.isPremium == true {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(L10n.commonSave) { save(); dismiss() }
                            .disabled(!hasWeight || !WeightCalculator.isValid(weight, unit: unit))
                    }
                }
            }
            .onAppear { loadExisting() }
            .alert(L10n.weightInvalidTitle, isPresented: $showError) {
                Button(L10n.commonOK, role: .cancel) {}
            } message: {
                let range = WeightCalculator.validRange(for: unit)
                Text(L10n.weightRange(
                    WeightCalculator.format(range.lowerBound, unit: unit),
                    WeightCalculator.format(range.upperBound, unit: unit)
                ))
            }
        }
    }

    private var navigationTitle: String {
        Calendar.current.isDateInToday(logDate) ? L10n.weightLogTitle : logDate.formatted(date: .abbreviated, time: .omitted)
    }

    private var logContent: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text(hasWeight ? WeightCalculator.format(weight, unit: unit) : "—")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomlyTheme.sageDark)
                    .contentTransition(.numericText())

                if let previous = previousWeight, hasWeight {
                    let change = weight - previous
                    Text(L10n.weightSinceLastEntry(WeightCalculator.formatChange(change, unit: unit)))
                        .font(.subheadline)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }

                if let starting = profile?.startingWeight, hasWeight {
                    let gain = WeightCalculator.totalGain(current: weight, starting: starting)
                    Text(L10n.weightSinceStartingWeight(WeightCalculator.formatChange(gain, unit: unit)))
                        .font(.caption)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }
            }

            HStack(spacing: 32) {
                adjustButton(systemName: "minus.circle.fill") {
                    adjustWeight(by: -step)
                }
                adjustButton(systemName: "plus.circle.fill") {
                    adjustWeight(by: step)
                }
            }

            VStack(spacing: 8) {
                Text(L10n.weightOrEnterManually)
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                TextField(L10n.weightFieldPlaceholder, value: $weight, format: .number.precision(.fractionLength(1)))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .font(.title2.bold())
                    .padding()
                    .background(BloomlyTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: weight) { _, _ in
                        hasWeight = true
                    }
            }
            .padding(.horizontal)

            if profile?.startingWeight == nil {
                Text(L10n.weightStartingWeightTip)
                    .font(.caption)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .animation(.easeInOut(duration: 0.15), value: weight)
    }

    private func adjustButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 52))
                .foregroundStyle(BloomlyTheme.sageDark)
        }
    }

    private func loadExisting() {
        if let existing = existingLog?.weightValue {
            weight = existing
            hasWeight = true
        } else if let previous = previousWeight {
            weight = previous
            hasWeight = true
        } else if let starting = profile?.startingWeight {
            weight = starting
            hasWeight = true
        }
    }

    private func adjustWeight(by amount: Double) {
        if !hasWeight {
            if let previous = previousWeight {
                weight = previous
            } else if let starting = profile?.startingWeight {
                weight = starting
            } else {
                weight = unit == "lbs" ? 140 : 65
            }
            hasWeight = true
        }
        weight = unit == "lbs"
            ? (max(0, weight + amount) * 2).rounded() / 2
            : (max(0, weight + amount) * 10).rounded() / 10
    }

    private func save() {
        guard WeightCalculator.isValid(weight, unit: unit) else {
            showError = true
            return
        }
        if let log = existingLog {
            log.weightValue = weight
        } else {
            modelContext.insert(DailyLog(date: logDate, weightValue: weight))
        }
    }
}

struct StartingWeightSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    @State private var weight: Double = 65
    @State private var showError = false

    private var profile: UserProfile? { profiles.first }
    private var unit: String { profile?.weightUnit ?? "kg" }
    private var step: Double { WeightCalculator.increment(for: unit) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(L10n.weightStartingTitle)
                    .font(.title3.bold())
                Text(L10n.weightStartingSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .multilineTextAlignment(.center)

                Text(WeightCalculator.format(weight, unit: unit))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomlyTheme.sageDark)

                HStack(spacing: 32) {
                    Button { weight = max(0, weight - step) } label: {
                        Image(systemName: "minus.circle.fill").font(.largeTitle)
                    }
                    Button { weight += step } label: {
                        Image(systemName: "plus.circle.fill").font(.largeTitle)
                    }
                }
                .foregroundStyle(BloomlyTheme.sageDark)

                Spacer()
            }
            .padding()
            .bloomlyScreenBackground()
            .bloomlyThemedNavigation()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(L10n.commonCancel) { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.commonSave) { save(); dismiss() }
                        .disabled(!WeightCalculator.isValid(weight, unit: unit))
                }
            }
            .onAppear {
                if let starting = profile?.startingWeight {
                    weight = starting
                } else {
                    weight = unit == "lbs" ? 140 : 65
                }
            }
            .alert(L10n.weightInvalidTitle, isPresented: $showError) {
                Button(L10n.commonOK, role: .cancel) {}
            } message: {
                Text(L10n.weightInvalidUnit(unit))
            }
        }
    }

    private func save() {
        guard WeightCalculator.isValid(weight, unit: unit), let profile else {
            showError = true
            return
        }
        profile.startingWeight = weight
    }
}

// Backward-compatible alias used from Home quick log.
typealias QuickWeightLogSheet = WeightLogSheet
