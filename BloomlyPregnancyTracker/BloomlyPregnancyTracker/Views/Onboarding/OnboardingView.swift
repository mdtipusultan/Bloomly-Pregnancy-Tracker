import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var showPaywall: Bool

    @State private var step = 0
    @State private var trackingMode = "pregnant"
    @State private var dateInputMethod = "lmp"
    @State private var selectedDate = Date()
    @State private var isFirstPregnancy = true
    @State private var weightUnit = "kg"

    var body: some View {
        ZStack {
            BloomlyTheme.backgroundGradient.ignoresSafeArea()
            VStack(spacing: 24) {
                header
                TabView(selection: $step) {
                    welcomeStep.tag(0)
                    modeStep.tag(1)
                    dateStep.tag(2)
                    personalStep.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut, value: step)

                navigationButtons
            }
            .padding()
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Bloomly")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(BloomlyTheme.blushDark)
            Text("Your pregnancy, beautifully tracked")
                .font(.subheadline)
                .foregroundStyle(BloomlyTheme.textSecondary)
            ProgressView(value: Double(step + 1), total: 4)
                .tint(BloomlyTheme.sage)
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(BloomlyTheme.blushDark)
            Text("Welcome to Bloomly")
                .font(.title2.bold())
            Text("A warm, private space to track your pregnancy journey. Everything stays on your device.")
                .multilineTextAlignment(.center)
                .foregroundStyle(BloomlyTheme.textSecondary)
            Spacer()
        }
        .bloomlyCard()
    }

    private var modeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What brings you here?")
                .font(.title3.bold())
            modeButton("I'm pregnant", icon: "figure.and.child.holdinghands", mode: "pregnant")
            modeButton("I'm planning", icon: "calendar.badge.clock", mode: "planning")
            Spacer()
        }
        .bloomlyCard()
    }

    private func modeButton(_ title: String, icon: String, mode: String) -> some View {
        Button {
            trackingMode = mode
            if step == 2 { clampSelectedDateToPregnancyRange() }
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(trackingMode == mode ? .white : BloomlyTheme.sageDark)
                Text(title)
                    .font(.headline)
                Spacer()
                if trackingMode == mode {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .padding()
            .background(trackingMode == mode ? BloomlyTheme.sage : BloomlyTheme.creamDark)
            .foregroundStyle(trackingMode == mode ? .white : BloomlyTheme.textPrimary)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var dateStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            if trackingMode == "pregnant" {
                Text("When did your journey begin?")
                    .font(.title3.bold())
                Picker("Input method", selection: $dateInputMethod) {
                    Text("Last period date").tag("lmp")
                    Text("Due date").tag("due")
                }
                .pickerStyle(.segmented)
                DatePicker(
                    dateInputMethod == "lmp" ? "Last menstrual period" : "Due date",
                    selection: pregnancyDateSelection,
                    in: pregnancyDateRange,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .id(dateInputMethod)
                .onChange(of: dateInputMethod) { clampSelectedDateToPregnancyRange() }
            } else {
                Text("Track your cycle")
                    .font(.title3.bold())
                Text("You can log period dates from the Daily Log and Profile tabs.")
                    .foregroundStyle(BloomlyTheme.textSecondary)
                DatePicker("Last period start", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
            }
            Spacer()
        }
        .bloomlyCard()
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

    private var personalStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("A few preferences")
                .font(.title3.bold())
            if trackingMode == "pregnant" {
                Toggle("This is my first pregnancy", isOn: $isFirstPregnancy)
            }
            Picker("Weight unit", selection: $weightUnit) {
                Text("Kilograms (kg)").tag("kg")
                Text("Pounds (lbs)").tag("lbs")
            }
            .pickerStyle(.segmented)
            Spacer()
        }
        .bloomlyCard()
    }

    private var navigationButtons: some View {
        HStack {
            if step > 0 {
                Button("Back") { step -= 1 }
                    .foregroundStyle(BloomlyTheme.textSecondary)
            }
            Spacer()
            Button(step < 3 ? "Continue" : "Get Started") {
                if step < 3 {
                    step += 1
                } else {
                    completeOnboarding()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(BloomlyTheme.sageDark)
        }
    }

    private func completeOnboarding() {
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

        let profile = UserProfile(
            lastMenstrualPeriod: lmp,
            dueDate: due,
            weightUnit: weightUnit,
            isFirstPregnancy: isFirstPregnancy,
            hasCompletedOnboarding: true,
            trackingMode: trackingMode
        )
        modelContext.insert(profile)
        showPaywall = true
    }
}
