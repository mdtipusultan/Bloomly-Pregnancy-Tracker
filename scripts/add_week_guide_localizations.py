#!/usr/bin/env python3
"""Add week guide and daily tip localizations to Localizable.xcstrings."""

from __future__ import annotations

import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
XCSTRINGS = (
    SCRIPT_DIR.parent
    / "BloomlyPregnancyTracker/BloomlyPregnancyTracker/Localizable.xcstrings"
)
LANG_DIR = SCRIPT_DIR / "lang_data" / "week_guide"

from _week_guide_translation_data import FOOTER_EN, FOOTER_KEY, KEYS, LOCALES  # noqa: E402


def load_translations() -> dict[str, dict[str, str]]:
    """Load per-locale translations from JSON files; English comes from KEYS."""
    translations: dict[str, dict[str, str]] = {"en": dict(KEYS)}
    for lang in LOCALES:
        if lang == "en":
            continue
        path = LANG_DIR / f"{lang}.json"
        if not path.exists():
            raise FileNotFoundError(f"Missing translation file: {path}")
        with path.open(encoding="utf-8") as handle:
            data = json.load(handle)
        translations[lang] = data
    return translations


def make_entry(value: str, lang: str) -> dict:
    return {
        "stringUnit": {
            "state": "translated" if lang != "en" else "new",
            "value": value,
        }
    }


def upsert_key(
    strings: dict,
    key: str,
    english: str,
    translations: dict[str, dict[str, str]],
) -> None:
    localizations = {}
    for lang in LOCALES:
        value = translations.get(lang, {}).get(key, english)
        localizations[lang] = make_entry(value, lang)
    strings[key] = {
        "extractionState": "manual",
        "localizations": localizations,
    }


def upsert_footer(strings: dict, translations: dict[str, dict[str, str]]) -> None:
    entry = strings.get(FOOTER_KEY, {})
    localizations = entry.setdefault("localizations", {})
    for lang in LOCALES:
        value = translations.get(lang, {}).get(FOOTER_KEY, FOOTER_EN)
        localizations[lang] = make_entry(value, lang)
    entry["extractionState"] = "manual"
    strings[FOOTER_KEY] = entry


def main() -> None:
    translations = load_translations()

    # Inject footer strings into each locale map for upsert_footer.
    footer_by_lang = {
        "en": FOOTER_EN,
        "es": "Los cambios de idioma se aplican en toda la app, incluidas las guías semanales y los consejos diarios.",
        "fr": "Les changements de langue s'appliquent dans toute l'application, y compris les guides hebdomadaires et les conseils quotidiens.",
        "de": "Sprachänderungen gelten in der gesamten App, einschließlich Wochenführern und Tagestipps.",
        "it": "Le modifiche alla lingua si applicano in tutta l'app, incluse le guide settimanali e i consigli giornalieri.",
        "pt": "As alterações de idioma aplicam-se em toda a app, incluindo guias semanais e dicas diárias.",
        "ar": "تُطبَّق تغييرات اللغة في جميع أنحاء التطبيق، بما في ذلك أدلة الأسابيع والنصائح اليومية.",
        "hi": "भाषा परिवर्तन पूरे ऐप में लागू होते हैं, जिसमें सप्ताह गाइड और दैनिक सुझाव शामिल हैं।",
        "bn": "ভাষা পরিবর্তন পুরো অ্যাপে প্রযোজ্য, যার মধ্যে সপ্তাহ গাইড এবং দৈনিক টিপস অন্তর্ভুক্ত।",
        "ja": "言語の変更は、アプリ全体に適用され、週ごとのガイドと毎日のヒントも含まれます。",
        "ko": "언어 변경은 주간 가이드와 일일 팁을 포함하여 앱 전체에 적용됩니다.",
        "zh-Hans": "语言更改适用于整个应用，包括每周指南和每日提示。",
        "ru": "Изменения языка применяются во всём приложении, включая недельные руководства и ежедневные советы.",
        "uk": "Зміни мови застосовуються в усьому додатку, включно з тижневими гідами та щоденними порадами.",
        "nl": "Taalswijzigingen gelden in de hele app, inclusief weekgidsen en dagelijkse tips.",
        "sv": "Språkändringar gäller i hela appen, inklusive veckoguider och dagliga tips.",
        "tr": "Dil değişiklikleri, haftalık rehberler ve günlük ipuçları dahil olmak üzere uygulamanın tamamında geçerlidir.",
        "pl": "Zmiany języka obowiązują w całej aplikacji, w tym przewodniki tygodniowe i codzienne wskazówki.",
        "vi": "Thay đổi ngôn ngữ áp dụng trên toàn bộ ứng dụng, bao gồm hướng dẫn theo tuần và mẹo hàng ngày.",
        "th": "การเปลี่ยนภาษามีผลทั่วทั้งแอป รวมถึงคู่มือรายสัปดาห์และเคล็ดลับประจำวัน",
        "id": "Perubahan bahasa berlaku di seluruh aplikasi, termasuk panduan mingguan dan tips harian.",
        "ms": "Perubahan bahasa terpakai di seluruh aplikasi, termasuk panduan minggu dan tip harian.",
        "he": "שינויי שפה חלים על כל האפליקציה, כולל מדריכים שבועיים וטיפים יומיים.",
        "el": "Οι αλλαγές γλώσσας ισχύουν σε όλη την εφαρμογή, συμπεριλαμβανομένων των εβδομαδιαίων οδηγών και των ημερήσιων συμβουλών.",
        "ro": "Modificările de limbă se aplică în întreaga aplicație, inclusiv ghidurile săptămânale și sfaturile zilnice.",
    }
    for lang, footer in footer_by_lang.items():
        translations.setdefault(lang, {})[FOOTER_KEY] = footer

    data = json.loads(XCSTRINGS.read_text(encoding="utf-8"))
    strings = data.setdefault("strings", {})

    added = 0
    for key, english in KEYS.items():
        upsert_key(strings, key, english, translations)
        added += 1

    upsert_footer(strings, translations)

    XCSTRINGS.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    dev_key = "weekGuide.development %lld"
    tip_key = "dailyTip.1"
    print(f"Added/updated {added} keys + footer across {len(LOCALES)} locales.")
    print(f"Sample bn [{dev_key}]: {translations['bn'][dev_key]}")
    print(f"Sample bn [{tip_key}]: {translations['bn'][tip_key]}")


if __name__ == "__main__":
    main()
