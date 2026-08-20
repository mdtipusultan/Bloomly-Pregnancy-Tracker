import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(LanguageManager.self) private var languageManager
    @Binding var showPaywall: Bool

    @State private var step = 0
    @State private var trackingMode = "pregnant"
    @State private var dateInputMethod = "lmp"
    @State private var selectedDate = Date()
    @State private var isFirstPregnancy = true
    @State private var weightUnit = "kg"
    @State private var startingWeightText = ""
    @State private var waterRemindersEnabled = true
    @State private var foodRemindersEnabled = true
    @FocusState private var isWeightFieldFocused: Bool

    private let totalSteps = 4

    private var stepTitles: [String] {
        [
            L10n.onboardingStepWelcome,
            L10n.onboardingStepJourney,
            L10n.onboardingStepDates,
            L10n.onboardingStepPreferences
        ]
    }

    var body: some View {
        ZStack {
            OnboardingBackground()

            VStack(spacing: 20) {
                header

                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    modeStep.tag(1)
                    dateStep.tag(2)
                    personalStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: step)
                .onChange(of: step) { _, newStep in
                    focusWeightFieldIfNeeded(for: newStep)
                }

                navigationButtons
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .bloomlyLanguageAware()
        .id(languageManager.selectedLanguageID)
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "leaf.fill")
                    .font(.title3)
                    .foregroundStyle(BloomlyTheme.sageDark)
                Text(L10n.appName)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(BloomlyTheme.textPrimary)
                Spacer()
            }
            .padding(.top, 8)

            OnboardingStepIndicator(
                currentStep: step,
                totalSteps: totalSteps,
                stepTitle: stepTitles[step]
            )
        }
    }

    // MARK: - Step 0: Welcome

    private var welcomeStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                OnboardingHeroIcon(
                    systemName: "heart.circle.fill",
                    colors: [BloomlyTheme.blushDark, BloomlyTheme.sageDark]
                )
                .padding(.top, 8)

                VStack(spacing: 10) {
                    Text(L10n.onboardingWelcomeTitle)
                        .font(.title2.bold())
                        .multilineTextAlignment(.center)
                    Text(L10n.onboardingWelcomeSubtitle)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    OnboardingFeatureRow(
                        icon: "lock.shield.fill",
                        title: L10n.onboardingFeaturePrivacyTitle,
                        subtitle: L10n.onboardingFeaturePrivacySubtitle,
                        tint: BloomlyTheme.sageDark
                    )
                    OnboardingFeatureRow(
                        icon: "sparkles",
                        title: L10n.onboardingFeatureGuidesTitle,
                        subtitle: L10n.onboardingFeatureGuidesSubtitle,
                        tint: BloomlyTheme.blushDark
                    )
                    OnboardingFeatureRow(
                        icon: "heart.text.square.fill",
                        title: L10n.onboardingFeatureLoggingTitle,
                        subtitle: L10n.onboardingFeatureLoggingSubtitle,
                        tint: BloomlyTheme.sage
                    )
                }
                .padding(.top, 4)
            }
            .padding(.vertical, 4)
        }
        .bloomlyCard()
    }

    // MARK: - Step 1: Mode

    private var modeStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.onboardingModeTitle)
                    .font(.title2.bold())
                Text(L10n.onboardingModeSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }

            OnboardingModeCard(
                title: L10n.onboardingModePregnantTitle,
                subtitle: L10n.onboardingModePregnantSubtitle,
                icon: "figure.and.child.holdinghands",
                isSelected: trackingMode == "pregnant"
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    trackingMode = "pregnant"
                    if step == 2 { clampSelectedDateToPregnancyRange() }
                }
            }

            OnboardingModeCard(
                title: L10n.onboardingModePlanningTitle,
                subtitle: L10n.onboardingModePlanningSubtitle,
                icon: "calendar.badge.clock",
                isSelected: trackingMode == "planning"
            ) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    trackingMode = "planning"
                }
            }

            Spacer(minLength: 0)
        }
        .bloomlyCard()
    }

    // MARK: - Step 2: Dates

    private var dateStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if trackingMode == "pregnant" {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.onboardingDatesPregnantTitle)
                            .font(.title2.bold())
                        Text(L10n.onboardingDatesPregnantSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }

                    Picker("Input method", selection: $dateInputMethod) {
                        Text(L10n.onboardingDatesLastPeriod).tag("lmp")
                        Text(L10n.onboardingDatesDueDate).tag("due")
                    }
                    .pickerStyle(.segmented)

                    OnboardingPregnancyPreview(
                        week: previewWeek,
                        dueDate: previewDueDate,
                        trimester: PregnancyCalculator.trimester(for: previewWeek)
                    )
                    .transition(.scale.combined(with: .opacity))

                    DatePicker(
                        dateInputMethod == "lmp" ? L10n.onboardingDatesLMPLabel : L10n.onboardingDatesDueDate,
                        selection: pregnancyDateSelection,
                        in: pregnancyDateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.graphical)
                    .tint(BloomlyTheme.sageDark)
                    .id(dateInputMethod)
                    .onChange(of: dateInputMethod) { clampSelectedDateToPregnancyRange() }
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L10n.onboardingDatesPlanningTitle)
                            .font(.title2.bold())
                        Text(L10n.onboardingDatesPlanningSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "drop.circle.fill")
                            .font(.title2)
                            .foregroundStyle(BloomlyTheme.blushDark)
                        Text(L10n.onboardingDatesPlanningTip)
                            .font(.caption)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BloomlyTheme.blush.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    DatePicker(L10n.onboardingDatesLastPeriodStart, selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(BloomlyTheme.sageDark)
                }
            }
        }
        .bloomlyCard()
    }

    // MARK: - Step 3: Preferences

    private var personalStep: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.onboardingPrefsTitle)
                        .font(.title2.bold())
                    Text(L10n.onboardingPrefsSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }

                if trackingMode == "pregnant" {
                    preferenceRow(icon: "star.circle.fill", title: L10n.onboardingPrefsFirstPregnancy) {
                        Toggle(L10n.onboardingPrefsFirstPregnancyToggle, isOn: $isFirstPregnancy)
                            .labelsHidden()
                            .tint(BloomlyTheme.sageDark)
                    }
                }

                preferenceRow(icon: "scalemass.fill", title: L10n.onboardingPrefsWeightUnit) {
                    Picker(L10n.onboardingPrefsWeightUnit, selection: $weightUnit) {
                        Text("kg").tag("kg")
                        Text("lbs").tag("lbs")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 160)
                }

                if trackingMode == "pregnant" {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Image(systemName: "figure.stand")
                                .foregroundStyle(BloomlyTheme.sageDark)
                            Text(L10n.onboardingPrefsStartingWeight)
                                .font(.subheadline.weight(.semibold))
                            Text(L10n.commonOptional)
                                .font(.caption)
                                .foregroundStyle(BloomlyTheme.textSecondary)
                        }

                        HStack(spacing: 12) {
                            TextField(
                                weightUnit == "lbs" ? "e.g. 140" : "e.g. 65",
                                text: $startingWeightText
                            )
                            .keyboardType(.decimalPad)
                            .focused($isWeightFieldFocused)
                            .padding(12)
                            .background(BloomlyTheme.creamDark)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                            Text(weightUnit)
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(BloomlyTheme.sageDark)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .background(BloomlyTheme.sage.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }

                        Text(L10n.onboardingPrefsStartingWeightHint)
                            .font(.caption)
                            .foregroundStyle(BloomlyTheme.textSecondary)
                    }
                    .padding(14)
                    .background(BloomlyTheme.cream.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "bell.badge.fill")
                            .foregroundStyle(BloomlyTheme.sageDark)
                        Text(L10n.onboardingPrefsDailyReminders)
                            .font(.subheadline.weight(.semibold))
                    }

                    preferenceRow(icon: "drop.fill", title: L10n.t("reminders.waterReminders")) {
                        Toggle(L10n.t("reminders.waterReminders"), isOn: $waterRemindersEnabled)
                            .labelsHidden()
                            .tint(BloomlyTheme.sageDark)
                    }

                    preferenceRow(icon: "fork.knife", title: L10n.t("reminders.mealReminders")) {
                        Toggle(L10n.t("reminders.mealReminders"), isOn: $foodRemindersEnabled)
                            .labelsHidden()
                            .tint(BloomlyTheme.sageDark)
                    }

                    Text(L10n.onboardingPrefsNotificationHint)
                        .font(.caption)
                        .foregroundStyle(BloomlyTheme.textSecondary)
                }
                .padding(14)
                .background(BloomlyTheme.cream.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .bloomlyCard()
    }

    private func preferenceRow<Content: View>(
        icon: String,
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        HStack {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(BloomlyTheme.textPrimary)
            Spacer()
            content()
        }
        .padding(.vertical, 4)
    }

    // MARK: - Navigation

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if step > 0 {
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        step -= 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.caption.weight(.semibold))
                        Text(L10n.commonBack)
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(BloomlyTheme.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }

            Spacer()

            OnboardingPrimaryButton(
                title: step < totalSteps - 1 ? L10n.commonContinue : L10n.onboardingGetStarted,
                icon: step < totalSteps - 1 ? "arrow.right" : "sparkles"
            ) {
                if step < totalSteps - 1 {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        step += 1
                    }
                } else {
                    Task { await completeOnboarding() }
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Pregnancy Preview Helpers

    private var previewLMP: Date {
        if dateInputMethod == "lmp" {
            selectedDate
        } else {
            PregnancyCalculator.lmp(fromDueDate: selectedDate)
        }
    }

    private var previewDueDate: Date {
        if dateInputMethod == "lmp" {
            PregnancyCalculator.dueDate(fromLMP: selectedDate)
        } else {
            selectedDate
        }
    }

    private var previewWeek: Int {
        let days = Calendar.current.dateComponents([.day], from: previewLMP, to: .now).day ?? 0
        return min(max(days / 7 + 1, 1), 42)
    }

    private var pregnancyDateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: .now)
        if dateInputMethod == "lmp" {
            let earliest = Calendar.current.date(byAdding: .weekOfYear, value: -42, to: today) ?? .distantPast
            return earliest...today
        } else {
            let latest = Calendar.current.date(byAdding: .weekOfYear, value: 42, to: today) ?? .distantFuture
            return today...latest
        }
    }

    private var pregnancyDateSelection: Binding<Date> {
        Binding(
            get: {
                let range = pregnancyDateRange
                return min(max(selectedDate, range.lowerBound), range.upperBound)
            },
            set: { selectedDate = $0 }
        )
    }

    private func clampSelectedDateToPregnancyRange() {
        let range = pregnancyDateRange
        selectedDate = min(max(selectedDate, range.lowerBound), range.upperBound)
    }

    private func focusWeightFieldIfNeeded(for step: Int) {
        guard step == 3, trackingMode == "pregnant" else {
            isWeightFieldFocused = false
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            isWeightFieldFocused = true
        }
    }

    // MARK: - Complete

    private func completeOnboarding() async {
        var waterEnabled = waterRemindersEnabled
        var foodEnabled = foodRemindersEnabled

        if waterEnabled || foodEnabled {
            let authorized = await NotificationManager.requestAuthorization()
            if !authorized {
                waterEnabled = false
                foodEnabled = false
                await MainActor.run {
                    waterRemindersEnabled = false
                    foodRemindersEnabled = false
                }
            }
        }

        var lmp: Date?
        var due: Date?
        if trackingMode == "pregnant" {
            if dateInputMethod == "lmp" {
                lmp = selectedDate
                due = PregnancyCalculator.dueDate(fromLMP: selectedDate)
            } else {
                due = selectedDate
                lmp = PregnancyCalculator.lmp(fromDueDate: selectedDate)
            }
        } else {
            lmp = selectedDate
        }

        let trimmedWeight = startingWeightText.trimmingCharacters(in: .whitespaces)
        let parsedWeight = trimmedWeight.isEmpty ? nil : Double(trimmedWeight)
        let startingWeight = parsedWeight.flatMap { weight in
            WeightCalculator.isValid(weight, unit: weightUnit) ? weight : nil
        }

        await MainActor.run {
            let profile = UserProfile(
                lastMenstrualPeriod: lmp,
                dueDate: due,
                weightUnit: weightUnit,
                startingWeight: startingWeight,
                isFirstPregnancy: isFirstPregnancy,
                isPremium: StoreKitManager.unlockAllFeaturesForDevelopment,
                hasCompletedOnboarding: true,
                trackingMode: trackingMode,
                waterRemindersEnabled: waterEnabled,
                foodRemindersEnabled: foodEnabled
            )
            modelContext.insert(profile)

            if let startingWeight {
                modelContext.insert(DailyLog(weightValue: startingWeight))
            }
            if !StoreKitManager.unlockAllFeaturesForDevelopment {
                showPaywall = true
            }
        }

        await NotificationManager.syncDailyReminders(
            waterEnabled: waterEnabled,
            foodEnabled: foodEnabled
        )
    }
}
