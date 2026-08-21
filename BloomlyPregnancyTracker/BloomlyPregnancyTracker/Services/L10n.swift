import Foundation

/// Locale-aware localization. Always resolves using the user's selected app language.
enum L10n {
    private static var bundleCache: [String: Bundle] = [:]

    private static var locale: Locale { LanguageManager.shared.locale }
    private static var languageID: String { LanguageManager.shared.selectedLanguageID }

    private static func bundle(for languageID: String) -> Bundle {
        if let cached = bundleCache[languageID] {
            return cached
        }

        let candidates = [
            languageID,
            languageID.replacingOccurrences(of: "-", with: "_")
        ]

        for code in candidates {
            if let path = Bundle.main.path(forResource: code, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                bundleCache[languageID] = bundle
                return bundle
            }
        }

        bundleCache[languageID] = .main
        return .main
    }

    static func resetCache() {
        bundleCache.removeAll()
    }

    static func t(_ key: String) -> String {
        let bundle = bundle(for: languageID)
        let localized = bundle.localizedString(forKey: key, value: nil, table: nil)
        if localized != key {
            return localized
        }

        return String(
            localized: String.LocalizationValue(key),
            bundle: bundle,
            locale: locale
        )
    }

    static func t(_ key: String, _ args: CVarArg...) -> String {
        String(format: t(key), locale: locale, arguments: args)
    }

    // Tabs
    static var tabHome: String { t("tab.home") }
    static var tabWeekGuide: String { t("tab.weekGuide") }
    static var tabDailyLog: String { t("tab.dailyLog") }
    static var tabTools: String { t("tab.tools") }
    static var tabProfile: String { t("tab.profile") }

    // Profile
    static var profileTitle: String { t("profile.title") }
    static var profileAccount: String { t("profile.account") }
    static var profileFeatures: String { t("profile.features") }
    static var profileSettings: String { t("profile.settings") }
    static var profileDailyReminders: String { t("profile.dailyReminders") }
    static var profilePrivacy: String { t("profile.privacy") }
    static var profileMode: String { t("profile.mode") }
    static var profilePregnant: String { t("profile.pregnant") }
    static var profilePlanning: String { t("profile.planning") }
    static var profileDueDate: String { t("profile.dueDate") }
    static var profileWeek: String { t("profile.week") }
    static var profilePremium: String { t("profile.premium") }
    static var profileBloomlyPlus: String { t("profile.bloomlyPlus") }
    static var profileFree: String { t("profile.free") }
    static var profileBumpJournal: String { t("profile.bumpJournal") }
    static var profileSharePartner: String { t("profile.sharePartner") }
    static var profileBabyNames: String { t("profile.babyNames") }
    static var profileAppointments: String { t("profile.appointments") }
    static var profileWeightTracker: String { t("profile.weightTracker") }
    static var profileNutrition: String { t("profile.nutrition") }
    static var profileStatistics: String { t("profile.statistics") }
    static var profileCycleTracker: String { t("profile.cycleTracker") }
    static var profileUpgrade: String { t("profile.upgrade") }
    static var profileSubscription: String { t("profile.subscription") }
    static var profileRestorePurchases: String { paywallRestore }
    static var profileManageSubscription: String { t("profile.manageSubscription") }
    static var profilePartnerSharing: String { t("profile.partnerSharing") }
    static var profileYourName: String { t("profile.yourName") }
    static var profilePartnerName: String { t("profile.partnerName") }
    static var profilePartnerHint: String { t("profile.partnerHint") }
    static var profilePrivacyTitle: String { t("profile.privacyTitle") }
    static var profilePrivacyBody: String { t("profile.privacyBody") }
    static var profilePrivacyWeDoNot: String { t("profile.privacyWeDoNot") }
    static var profilePrivacyFooter: String { t("profile.privacyFooter") }
    static var profileNoAppointments: String { t("profile.noAppointments") }
    static var profileNewAppointment: String { t("profile.newAppointment") }
    static var profileFavorites: String { t("profile.favorites") }
    static var profileUpcoming: String { t("profile.upcoming") }
    static var profilePast: String { t("profile.past") }
    static var profileLogPeriod: String { t("profile.logPeriod") }

    // Tools
    static var toolsTitle: String { t("tools.title") }
    static var toolsKegelTimer: String { t("tools.kegelTimer") }
    static var toolsKegelSubtitle: String { t("tools.kegelSubtitle") }
    static var toolsKickCounter: String { t("tools.kickCounter") }
    static var toolsKickSubtitle: String { t("tools.kickSubtitle") }
    static var kickKicks: String { t("tools.kick.kicks") }
    static var kickTapForKick: String { t("tools.kick.tapForKick") }
    static var kickSaveSession: String { t("tools.kick.saveSession") }
    static var kickSessionTime: String { t("tools.kick.sessionTime") }
    static var kickLastKick: String { t("tools.kick.lastKick") }
    static var kickAverageInterval: String { t("tools.kick.averageInterval") }
    static var kickCountGoal: String { t("tools.kick.countGoal") }
    static var kickEncouragement: String { t("tools.kick.encouragement") }
    static var kickGoalReached: String { t("tools.kick.goalReached") }
    static var kickIdleHint: String { t("tools.kick.idleHint") }
    static var toolsContractionTimer: String { t("tools.contractionTimer") }
    static var toolsContractionSubtitle: String { t("tools.contractionSubtitle") }
    static var toolsHydration: String { t("tools.hydration") }
    static var toolsHydrationSubtitle: String { t("tools.hydrationSubtitle") }
    static var toolsWeightTracker: String { t("tools.weightTracker") }
    static var toolsWeightSubtitle: String { t("tools.weightSubtitle") }
    static var toolsWellnessGate: String { t("tools.wellnessGate") }

    // Home
    static var homeTitle: String { t("home.title") }
    static var homeDailyTip: String { t("home.dailyTip") }
    static var homeQuickLog: String { t("home.quickLog") }
    static var homeWater: String { t("home.water") }
    static var homeMood: String { t("home.mood") }
    static var homeSymptoms: String { t("home.symptoms") }
    static var homeWeight: String { t("home.weight") }
    static var homePregnancyProgress: String { t("home.pregnancyProgress") }
    static var homePlanningMode: String { t("home.planningMode") }
    static var homePlanningSubtitle: String { t("home.planningSubtitle") }
    static var homeDueDatePassed: String { t("home.dueDatePassed") }
    static var homeWaterIntake: String { t("home.waterIntake") }
    static var homeGlassesOfWater: String { t("home.glassesOfWater") }
    static var homeDailyGoalWater: String { t("home.dailyGoalWater") }
    static var homeHowFeeling: String { t("home.howFeeling") }

    // Daily Log
    static var dailyLogTitle: String { t("dailyLog.title") }
    static var dailyLogDaySummary: String { t("dailyLog.daySummary") }
    static var dailyLogNotes: String { t("dailyLog.notes") }

    // Week Guide
    static var weekGuideTitle: String { t("weekGuide.title") }
    static var weekGuideLength: String { t("weekGuide.length") }
    static var weekGuideWeight: String { t("weekGuide.weight") }
    static var weekGuideDevelopment: String { t("weekGuide.development") }
    static var weekGuideMomFeeling: String { t("weekGuide.momFeeling") }
    static var weekGuideTip: String { t("weekGuide.tip") }
    static var weekGuideAppointment: String { t("weekGuide.appointment") }

    static func weekGuideDevelopment(week: Int) -> String {
        t("weekGuide.development %lld", week)
    }

    static func weekGuideMomFeeling(week: Int) -> String {
        t("weekGuide.momFeeling %lld", week)
    }

    static var weekGuideTipText: String { t("weekGuide.tipBody") }

    static func weekGuideAppointment(for week: Int) -> String? {
        let key: String? = switch week {
        case 8: "weekGuide.appointment.firstPrenatal"
        case 12: "weekGuide.appointment.nuchal"
        case 20: "weekGuide.appointment.anatomy"
        case 24: "weekGuide.appointment.glucose"
        case 28: "weekGuide.appointment.thirdTrimester"
        case 36: "weekGuide.appointment.weeklyVisits"
        default: nil
        }
        guard let key else { return nil }
        return t(key)
    }

    static func dailyTip(id: Int) -> String {
        let key = "dailyTip.\(id)"
        let localized = t(key)
        if localized != key { return localized }
        return dailyTipFallback
    }

    static var dailyTipFallback: String { t("dailyTip.fallback") }

    // Settings
    static var settingsAppearance: String { t("settings.appearance") }
    static var settingsAppearanceSubtitle: String { t("settings.appearance.subtitle") }
    static var settingsLanguage: String { t("settings.language") }
    static var settingsLanguageFooter: String { t("settings.language.footer") }

    // Splash
    static var splashTagline: String { t("splash.tagline") }

    // Common
    static var commonCancel: String { t("common.cancel") }
    static var commonSave: String { t("common.save") }
    static var commonUpgrade: String { t("common.upgrade") }
    static var commonDate: String { t("common.date") }
    static var commonStart: String { t("common.start") }
    static var commonReset: String { t("common.reset") }
    static var commonResume: String { t("common.resume") }
    static var commonDone: String { t("common.done") }
    static var commonPause: String { t("common.pause") }
    static var commonGender: String { t("common.gender") }
    static var commonLetter: String { t("common.letter") }
    static var commonStyle: String { t("common.style") }
    static var commonDetails: String { t("common.details") }
    static var commonLogged: String { t("common.logged") }
    static var commonSeverity: String { t("common.severity") }

    static func daysUntilDue(_ days: Int) -> String {
        t("home.daysUntilDue %lld", days)
    }

    static func weekNumber(_ week: Int) -> String {
        t("common.weekNumber %lld", week)
    }

    static func weekOfTotal(_ week: Int) -> String {
        t("home.weekOfTotal %lld", week)
    }

    static func premiumFeature(_ feature: String) -> String {
        t("common.premiumFeature %@", feature)
    }

    static func kegelSetOf(_ set: Int) -> String { t("tools.kegel.setOf %lld", set) }
    static func kegelRepOf(_ rep: Int) -> String { t("tools.kegel.repOf %lld", rep) }
    static func contractionDuration(_ time: String) -> String { t("tools.contraction.duration %@", time) }
    static func contractionInterval(_ time: String) -> String { t("tools.contraction.interval %@", time) }
    static var contractionHint: String { t("tools.contraction.hint") }
    static var contractionLastDuration: String { t("tools.contraction.lastDuration") }
    static var contractionAverageInterval: String { t("tools.contraction.averageInterval") }
    static var hydrationGoalReached: String { t("tools.hydration.goalReached") }
    static var hydrationTapHint: String { t("tools.hydration.tapHint") }

    // Baby size
    private static let babySizeUsesAnArticle: Set<String> = ["apple", "avocado", "eggplant"]

    static func babySizeItem(_ sizeImage: String) -> String {
        let key = "babySize.item.\(sizeImage)"
        let localized = t(key)
        if localized != key { return localized }
        return sizeImage.replacingOccurrences(of: "_", with: " ")
    }

    static func babySizeComparison(sizeImage: String) -> String {
        if sizeImage == "full_term_baby" {
            return t("babySize.comparisonFullTerm")
        }
        let item = babySizeItem(sizeImage)
        let templateKey = babySizeUsesAnArticle.contains(sizeImage)
            ? "babySize.comparisonAn %@"
            : "babySize.comparisonA %@"
        return t(templateKey, item)
    }

    static var babySizeGrowingEveryDay: String { t("babySize.growingEveryDay") }

    // Common extras
    static var commonBack: String { t("common.back") }
    static var commonContinue: String { t("common.continue") }
    static var commonOK: String { t("common.ok") }
    static var commonLog: String { t("common.log") }
    static var commonHistory: String { t("common.history") }
    static var commonOptional: String { t("common.optional") }
    static var commonOngoing: String { t("common.ongoing") }
    static var appName: String { t("app.name") }

    // Onboarding
    static var onboardingStepWelcome: String { t("onboarding.step.welcome") }
    static var onboardingStepJourney: String { t("onboarding.step.journey") }
    static var onboardingStepDates: String { t("onboarding.step.dates") }
    static var onboardingStepPreferences: String { t("onboarding.step.preferences") }
    static var onboardingWelcomeTitle: String { t("onboarding.welcome.title") }
    static var onboardingWelcomeSubtitle: String { t("onboarding.welcome.subtitle") }
    static var onboardingFeaturePrivacyTitle: String { t("onboarding.feature.privacy.title") }
    static var onboardingFeaturePrivacySubtitle: String { t("onboarding.feature.privacy.subtitle") }
    static var onboardingFeatureGuidesTitle: String { t("onboarding.feature.guides.title") }
    static var onboardingFeatureGuidesSubtitle: String { t("onboarding.feature.guides.subtitle") }
    static var onboardingFeatureLoggingTitle: String { t("onboarding.feature.logging.title") }
    static var onboardingFeatureLoggingSubtitle: String { t("onboarding.feature.logging.subtitle") }
    static var onboardingModeTitle: String { t("onboarding.mode.title") }
    static var onboardingModeSubtitle: String { t("onboarding.mode.subtitle") }
    static var onboardingModePregnantTitle: String { t("onboarding.mode.pregnant.title") }
    static var onboardingModePregnantSubtitle: String { t("onboarding.mode.pregnant.subtitle") }
    static var onboardingModePlanningTitle: String { t("onboarding.mode.planning.title") }
    static var onboardingModePlanningSubtitle: String { t("onboarding.mode.planning.subtitle") }
    static var onboardingDatesPregnantTitle: String { t("onboarding.dates.pregnant.title") }
    static var onboardingDatesPregnantSubtitle: String { t("onboarding.dates.pregnant.subtitle") }
    static var onboardingDatesLastPeriod: String { t("onboarding.dates.lastPeriod") }
    static var onboardingDatesDueDate: String { t("onboarding.dates.dueDate") }
    static var onboardingDatesLMPLabel: String { t("onboarding.dates.lmpLabel") }
    static var onboardingDatesPlanningTitle: String { t("onboarding.dates.planning.title") }
    static var onboardingDatesPlanningSubtitle: String { t("onboarding.dates.planning.subtitle") }
    static var onboardingDatesPlanningTip: String { t("onboarding.dates.planning.tip") }
    static var onboardingDatesLastPeriodStart: String { t("onboarding.dates.lastPeriodStart") }
    static var onboardingPrefsTitle: String { t("onboarding.prefs.title") }
    static var onboardingPrefsSubtitle: String { t("onboarding.prefs.subtitle") }
    static var onboardingPrefsFirstPregnancy: String { t("onboarding.prefs.firstPregnancy") }
    static var onboardingPrefsFirstPregnancyToggle: String { t("onboarding.prefs.firstPregnancyToggle") }
    static var onboardingPrefsWeightUnit: String { t("onboarding.prefs.weightUnit") }
    static var onboardingPrefsStartingWeight: String { t("onboarding.prefs.startingWeight") }
    static var onboardingPrefsStartingWeightHint: String { t("onboarding.prefs.startingWeightHint") }
    static var onboardingPrefsDailyReminders: String { t("onboarding.prefs.dailyReminders") }
    static var onboardingPrefsNotificationHint: String { t("onboarding.prefs.notificationHint") }
    static var onboardingGetStarted: String { t("onboarding.getStarted") }

    static func onboardingStepOf(current: Int, total: Int) -> String {
        t("onboarding.stepOf %lld %lld", current, total)
    }

    // Paywall
    static var paywallTitle: String { t("paywall.title") }
    static var paywallSubtitle: String { t("paywall.subtitle") }
    static var paywallHeroCare: String { t("paywall.heroCare") }
    static var paywallBestValue: String { t("paywall.bestValue") }
    static var paywallPurchased: String { t("paywall.purchased") }
    static var paywallPerMonth: String { t("paywall.perMonth") }
    static var paywallPerYear: String { t("paywall.perYear") }
    static var paywallOneTime: String { t("paywall.oneTime") }
    static var paywallLegal: String { t("paywall.legal") }
    static var paywallFeatureSymptoms: String { t("paywall.feature.symptoms") }
    static var paywallFeatureTools: String { t("paywall.feature.tools") }
    static var paywallFeatureAppointments: String { t("paywall.feature.appointments") }
    static var paywallFeatureStatistics: String { t("paywall.feature.statistics") }
    static var paywallFeatureNutrition: String { t("paywall.feature.nutrition") }
    static var paywallSubscriptionsPlaceholder: String { t("paywall.subscriptionsPlaceholder") }
    static var paywallRestore: String { t("paywall.restore") }
    static var paywallStartFree: String { t("paywall.startFree") }
    static var paywallPurchaseError: String { t("paywall.purchaseError") }

    static func paywallContinuePrice(_ price: String) -> String {
        t("paywall.continuePrice %@", price)
    }

    static func paywallSavePercent(_ percent: Int) -> String {
        t("paywall.savePercent %lld", percent)
    }

    // Bump Journal
    static var bumpJournalSubtitle: String { t("bumpJournal.subtitle") }
    static var bumpJournalPhotoLibrary: String { t("bumpJournal.photoLibrary") }
    static var bumpJournalCamera: String { t("bumpJournal.camera") }
    static var bumpJournalEmptyTitle: String { t("bumpJournal.empty.title") }
    static var bumpJournalEmptySubtitle: String { t("bumpJournal.empty.subtitle") }
    static var bumpJournalSavePhoto: String { t("bumpJournal.savePhoto") }
    static var bumpJournalOptionalNote: String { t("bumpJournal.optionalNote") }

    static func bumpJournalWeekBump(_ week: Int) -> String { t("bumpJournal.weekBump %lld", week) }

    // Weight
    static var weightLatest: String { t("weight.latest") }
    static var weightStarting: String { t("weight.starting") }
    static var weightSet: String { t("weight.set") }
    static var weightNotLoggedYet: String { t("weight.notLoggedYet") }
    static var weightPrePregnancy: String { t("weight.prePregnancy") }
    static var weightTotalChange: String { t("weight.totalChange") }
    static var weightSinceStarting: String { t("weight.sinceStarting") }
    static var weightSinceLast: String { t("weight.sinceLast") }
    static var weightPreviousEntry: String { t("weight.previousEntry") }
    static var weightTrend: String { t("weight.trend") }
    static var weightNoWeightYet: String { t("weight.noWeightYet") }
    static var weightLogWeight: String { t("weight.logWeight") }
    static var weightHistoryEmpty: String { t("weight.historyEmpty") }
    static var weightLogTitle: String { t("weight.logTitle") }
    static var weightInvalidTitle: String { t("weight.invalidTitle") }
    static var weightOrEnterManually: String { t("weight.orEnterManually") }
    static var weightStartingWeightTip: String { t("weight.startingWeightTip") }
    static var weightStartingTitle: String { t("weight.startingTitle") }
    static var weightStartingSubtitle: String { t("weight.startingSubtitle") }
    static var weightFieldPlaceholder: String { t("weight.fieldPlaceholder") }

    static func weightGuidance(_ week: Int) -> String { t("weight.guidance %lld", week) }
    static func weightSinceLastEntry(_ change: String) -> String { t("weight.sinceLastEntry %@", change) }
    static func weightSinceStartingWeight(_ change: String) -> String { t("weight.sinceStartingWeight %@", change) }
    static func weightRange(_ min: String, _ max: String) -> String { t("weight.range %@ %@", min, max) }
    static func weightInvalidUnit(_ unit: String) -> String { t("weight.invalidUnit %@", unit) }

    // Partner share
    static var partnerShareTitle: String { t("partner.shareTitle") }
    static var partnerPersonalMessage: String { t("partner.personalMessage") }
    static var partnerMessagePlaceholder: String { t("partner.messagePlaceholder") }
    static var partnerShareImage: String { t("partner.shareImage") }
    static var partnerShareText: String { t("partner.shareText") }
    static var partnerDueDatePassed: String { t("partner.dueDatePassed") }
    static var babySizeSharePartner: String { t("babySize.sharePartner") }

    static func partnerForName(_ name: String) -> String { t("partner.forName %@", name) }
    static func partnerSharePreview(_ week: Int) -> String { t("partner.sharePreview %lld", week) }
    static func partnerShareLine(_ week: Int) -> String { t("partner.shareLine %lld", week) }

    // Statistics
    static var statsWeightOverTime: String { t("stats.weightOverTime") }
    static var statsNoWeightData: String { t("stats.noWeightData") }
    static var statsSymptomFrequency: String { t("stats.symptomFrequency") }
    static var statsNoSymptomData: String { t("stats.noSymptomData") }
    static var statsMoodHistory: String { t("stats.moodHistory") }
    static var statsWaterStreak: String { t("stats.waterStreak") }
    static var statsCurrent: String { t("stats.current") }
    static var statsBest: String { t("stats.best") }
    static var statsPrediction: String { t("stats.prediction") }
    static var statsGain: String { t("stats.gain") }
    static var statsDetails: String { t("stats.details") }
    static var statsNextPeriod: String { t("stats.nextPeriod") }
    static var statsFertileWindow: String { t("stats.fertileWindow") }
    static var statsOvulationEstimate: String { t("stats.ovulationEstimate") }
    static var cyclePeriodEnded: String { t("cycle.periodEnded") }
}
