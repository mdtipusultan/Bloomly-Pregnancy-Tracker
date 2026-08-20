#!/usr/bin/env python3
"""Add missing localization keys to Localizable.xcstrings with all supported locales."""

import json
from pathlib import Path

XCSTRINGS = Path(__file__).resolve().parents[1] / "BloomlyPregnancyTracker/BloomlyPregnancyTracker/Localizable.xcstrings"

# English source strings for new keys
NEW_KEYS = {
    "app.name": "Bloomly",
    "common.back": "Back",
    "common.continue": "Continue",
    "common.ok": "OK",
    "common.log": "Log",
    "common.history": "History",
    "common.optional": "(optional)",
    "common.ongoing": "ongoing",
    "onboarding.step.welcome": "Welcome",
    "onboarding.step.journey": "Your journey",
    "onboarding.step.dates": "Key dates",
    "onboarding.step.preferences": "Preferences",
    "onboarding.welcome.title": "Your journey starts here",
    "onboarding.welcome.subtitle": "A calm, private space to track every moment — from first flutter to final countdown.",
    "onboarding.feature.privacy.title": "100% on your device",
    "onboarding.feature.privacy.subtitle": "Your data never leaves your phone",
    "onboarding.feature.guides.title": "Week-by-week guides",
    "onboarding.feature.guides.subtitle": "Baby size, tips & milestones",
    "onboarding.feature.logging.title": "Daily wellness logging",
    "onboarding.feature.logging.subtitle": "Symptoms, mood, water & more",
    "onboarding.mode.title": "What brings you here?",
    "onboarding.mode.subtitle": "We'll tailor Bloomly to your stage.",
    "onboarding.mode.pregnant.title": "I'm pregnant",
    "onboarding.mode.pregnant.subtitle": "Track weeks, baby size, kicks & milestones",
    "onboarding.mode.planning.title": "I'm planning",
    "onboarding.mode.planning.subtitle": "Cycle tracking, fertile windows & prep",
    "onboarding.dates.pregnant.title": "When did your journey begin?",
    "onboarding.dates.pregnant.subtitle": "We'll calculate your week and due date.",
    "onboarding.dates.lastPeriod": "Last period",
    "onboarding.dates.dueDate": "Due date",
    "onboarding.dates.lmpLabel": "Last menstrual period",
    "onboarding.dates.planning.title": "Track your cycle",
    "onboarding.dates.planning.subtitle": "When did your last period start? You can log more dates anytime.",
    "onboarding.dates.planning.tip": "Cycle insights appear on your Home tab",
    "onboarding.dates.lastPeriodStart": "Last period start",
    "onboarding.prefs.title": "Almost there!",
    "onboarding.prefs.subtitle": "A few quick preferences to personalize Bloomly.",
    "onboarding.prefs.firstPregnancy": "First pregnancy?",
    "onboarding.prefs.firstPregnancyToggle": "This is my first pregnancy",
    "onboarding.prefs.weightUnit": "Weight unit",
    "onboarding.prefs.startingWeight": "Starting weight",
    "onboarding.prefs.startingWeightHint": "Pre-pregnancy weight helps track healthy gain over time.",
    "onboarding.prefs.dailyReminders": "Daily reminders",
    "onboarding.prefs.notificationHint": "We'll ask for notification permission when you finish setup.",
    "onboarding.getStarted": "Get Started",
    "onboarding.stepOf %lld %lld": "Step %1$lld of %2$lld",
    "paywall.title": "Bloomly Plus",
    "paywall.subtitle": "Unlock the full wellness experience",
    "paywall.feature.symptoms": "Full symptom & weight logging",
    "paywall.feature.tools": "Wellness tools: Kegel, kick & contraction timers",
    "paywall.feature.appointments": "Appointments with reminders",
    "paywall.feature.statistics": "Statistics & history charts",
    "paywall.feature.nutrition": "Trimester-aware nutrition guide",
    "paywall.subscriptionsPlaceholder": "Subscriptions will appear when configured in App Store Connect.",
    "paywall.restore": "Restore Purchases",
    "paywall.startFree": "Start Free",
    "paywall.purchaseError": "Purchase could not be completed.",
    "bumpJournal.subtitle": "Capture your growing bump each week and watch your journey unfold.",
    "bumpJournal.photoLibrary": "Photo Library",
    "bumpJournal.camera": "Camera",
    "bumpJournal.empty.title": "No bump photos yet",
    "bumpJournal.empty.subtitle": "Add your first photo to start your visual journal.",
    "bumpJournal.savePhoto": "Save Photo",
    "bumpJournal.optionalNote": "Optional note",
    "bumpJournal.weekBump %lld": "Week %lld Bump",
    "weight.latest": "Latest",
    "weight.starting": "Starting",
    "weight.set": "Set",
    "weight.tapToAdd": "Tap to add",
    "weight.notLoggedYet": "Not logged yet",
    "weight.prePregnancy": "Pre-pregnancy",
    "weight.totalChange": "Total Change",
    "weight.sinceStarting": "Since starting weight",
    "weight.sinceLast": "Since Last",
    "weight.previousEntry": "Previous entry",
    "weight.trend": "Weight Trend",
    "weight.noWeightYet": "No weight logged yet",
    "weight.logWeight": "Log Weight",
    "weight.historyEmpty": "Your weight entries will appear here.",
    "weight.logTitle": "Log Weight",
    "weight.invalidTitle": "Invalid Weight",
    "weight.orEnterManually": "Or enter manually",
    "weight.startingWeightTip": "Tip: set your starting weight in the Weight Tracker for gain tracking.",
    "weight.startingTitle": "Starting Weight",
    "weight.startingSubtitle": "Your pre-pregnancy weight helps track healthy gain over time.",
    "weight.fieldPlaceholder": "Weight",
    "weight.guidance %lld": "Week %lld Guidance",
    "weight.sinceLastEntry %@": "%@ since last entry",
    "weight.sinceStartingWeight %@": "%@ since starting weight",
    "weight.range %@ %@": "Enter a weight between %1$@ and %2$@.",
    "weight.invalidUnit %@": "Please enter a valid weight in %@.",
    "partner.shareTitle": "Share Update",
    "partner.personalMessage": "Personal message",
    "partner.messagePlaceholder": "Can't wait to meet our little one!",
    "partner.shareImage": "Share Image",
    "partner.shareText": "Share Text Update",
    "partner.dueDatePassed": "Due date has passed — any day now!",
    "partner.forName %@": "— For %@",
    "partner.sharePreview %lld": "Bloomly Week %lld",
    "partner.shareLine %lld": "🌸 Bloomly — Week %lld",
    "babySize.sharePartner": "Share with Partner",
    "stats.weightOverTime": "Weight Over Time",
    "stats.noWeightData": "No weight data yet. Log from Home or Weight Tracker.",
    "stats.symptomFrequency": "Symptom Frequency",
    "stats.noSymptomData": "No symptom data yet",
    "stats.moodHistory": "Mood History",
    "stats.waterStreak": "Water Streak",
    "stats.current": "Current",
    "stats.best": "Best",
    "stats.prediction": "Prediction",
    "stats.gain": "Gain",
    "stats.details": "Details",
    "stats.nextPeriod": "Next Period",
    "stats.fertileWindow": "Fertile Window",
    "stats.ovulationEstimate": "Ovulation Estimate",
    "cycle.periodEnded": "Period ended",
}

# Hand-tuned translations for major languages (fallback to English if missing)
TRANSLATIONS = {
    "es": {
        "common.back": "Atrás",
        "common.continue": "Continuar",
        "common.ok": "OK",
        "common.log": "Registrar",
        "common.history": "Historial",
        "common.optional": "(opcional)",
        "common.ongoing": "en curso",
        "onboarding.step.welcome": "Bienvenida",
        "onboarding.step.journey": "Tu camino",
        "onboarding.step.dates": "Fechas clave",
        "onboarding.step.preferences": "Preferencias",
        "onboarding.welcome.title": "Tu camino comienza aquí",
        "onboarding.welcome.subtitle": "Un espacio tranquilo y privado para seguir cada momento, desde el primer aleteo hasta la cuenta regresiva final.",
        "onboarding.getStarted": "Comenzar",
        "onboarding.back": "Atrás",
        "paywall.title": "Bloomly Plus",
        "paywall.subtitle": "Desbloquea la experiencia completa de bienestar",
        "paywall.startFree": "Empezar gratis",
        "paywall.restore": "Restaurar compras",
        "bumpJournal.subtitle": "Captura tu barriga cada semana y observa cómo avanza tu camino.",
        "bumpJournal.photoLibrary": "Fotos",
        "bumpJournal.camera": "Cámara",
        "weight.trend": "Tendencia de peso",
        "weight.logTitle": "Registrar peso",
        "partner.shareTitle": "Compartir actualización",
        "stats.current": "Actual",
        "stats.best": "Mejor",
    },
    "fr": {
        "common.back": "Retour",
        "common.continue": "Continuer",
        "common.log": "Enregistrer",
        "common.history": "Historique",
        "onboarding.getStarted": "Commencer",
        "paywall.startFree": "Commencer gratuitement",
        "paywall.restore": "Restaurer les achats",
    },
    "de": {
        "common.back": "Zurück",
        "common.continue": "Weiter",
        "common.log": "Eintragen",
        "onboarding.getStarted": "Los geht's",
        "paywall.startFree": "Kostenlos starten",
    },
}


def make_entry(value: str, lang: str) -> dict:
    translated = TRANSLATIONS.get(lang, {}).get(value_key := None, value)
    # Look up per-key translation
    return {
        "stringUnit": {
            "state": "translated" if lang != "en" else "new",
            "value": value,
        }
    }


def main():
    data = json.loads(XCSTRINGS.read_text(encoding="utf-8"))
    strings = data.setdefault("strings", {})

    # Collect locale codes from an existing fully-translated key
    template = strings.get("tab.home", {}).get("localizations", {})
    locales = list(template.keys()) or ["en"]

    for key, english in NEW_KEYS.items():
        if key in strings and strings[key].get("localizations"):
            continue

        localizations = {}
        for lang in locales:
            value = TRANSLATIONS.get(lang, {}).get(key, english)
            localizations[lang] = {
                "stringUnit": {
                    "state": "translated" if lang != "en" else "new",
                    "value": value,
                }
            }

        strings[key] = {
            "extractionState": "manual",
            "localizations": localizations,
        }

    XCSTRINGS.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Added/updated {len(NEW_KEYS)} localization keys across {len(locales)} locales.")


if __name__ == "__main__":
    main()
