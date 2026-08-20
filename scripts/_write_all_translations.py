#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Generate _build_translation_data.py with complete TRANSLATIONS dict."""

import json
import pprint
from pathlib import Path

ROOT = Path(__file__).resolve().parent
KEYS = json.loads(Path("/tmp/bloomly_keys.json").read_text(encoding="utf-8"))
FORMAT_ONLY = {
    "%@ – %@": "%1$@ – %2$@",
    "%@ · %@": "%1$@ · %2$@",
    "%@ (%@)": "%1$@ (%2$@)",
    "%@ %@": "%1$@ %2$@",
    "%@: %@": "%1$@: %2$@",
}

BN = json.loads((ROOT / "lang_data/bn.json").read_text(encoding="utf-8"))
BN.update({
    "bumpJournal.subtitle": "প্রতি সপ্তাহে আপনার বাড়তে থাকা বাম্প ধরুন এবং আপনার যাত্রা দেখুন।",
    "home.planningSubtitle": "আপনার চক্র ট্র্যাক করুন এবং যাত্রার জন্য প্রস্তুত হন।",
    "home.waterIntake": "পানি গ্রহণ",
    "language.arabic": "আরবি",
    "language.russian": "রাশিয়ান",
    "language.swedish": "সুয়েডীয়",
    "onboarding.dates.pregnant.title": "আপনার যাত্রা কখন শুরু হয়েছিল?",
    "onboarding.mode.planning.subtitle": "চক্র ট্র্যাকিং, উর্বর উইন্ডো এবং প্রস্তুতি",
    "onboarding.mode.subtitle": "আমরা Bloomly আপনার পর্যায় অনুযায়ী সাজিয়ে দেব।",
    "onboarding.step.journey": "আপনার যাত্রা",
    "onboarding.welcome.title": "আপনার যাত্রা এখানে শুরু",
    "tab.home": "হোম",
    "profile.title": "প্রোফাইল",
    "home.title": "হোম",
    "settings.language": "ভাষা",
    "language.bengali": "বাংলা",
})

# Load per-language JSON sources (created alongside this script)
LANG_CODES = ("bn", "el", "he", "id", "ms", "ro", "sv", "th", "uk", "vi")
SOURCES = ROOT / "lang_sources"
PAYLOAD = {"bn": BN}
for code in LANG_CODES:
    if code == "bn":
        continue
    path = SOURCES / f"{code}.json"
    PAYLOAD[code] = json.loads(path.read_text(encoding="utf-8"))

for code, data in PAYLOAD.items():
    missing = set(KEYS) - set(data)
    if missing:
        raise SystemExit(f"{code} missing {len(missing)} keys")
    if len(data) != 292:
        raise SystemExit(f"{code} has {len(data)} keys")

HEADER = '''#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Build translation JSON files for Bloomly localization (292 keys × 10 languages)."""

import json
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
LANG_DATA_DIR = SCRIPT_DIR / "lang_data"
ENGLISH_KEYS_PATH = Path("/tmp/bloomly_keys.json")

FORMAT_ONLY = {
    "%@ – %@": "%1$@ – %2$@",
    "%@ · %@": "%1$@ · %2$@",
    "%@ (%@)": "%1$@ (%2$@)",
    "%@ %@": "%1$@ %2$@",
    "%@: %@": "%1$@: %2$@",
}

TRANSLATIONS = '''

FOOTER = '''

def main() -> None:
    english_keys = json.loads(ENGLISH_KEYS_PATH.read_text(encoding="utf-8"))
    expected = len(english_keys)

    LANG_DATA_DIR.mkdir(parents=True, exist_ok=True)

    for lang, translations in TRANSLATIONS.items():
        missing = set(english_keys) - set(translations)
        extra = set(translations) - set(english_keys)
        if missing:
            raise SystemExit(f"{lang}: missing {len(missing)} keys: {sorted(missing)[:5]}...")
        if extra:
            raise SystemExit(f"{lang}: extra {len(extra)} keys: {sorted(extra)[:5]}...")
        if len(translations) != expected:
            raise SystemExit(f"{lang}: expected {expected} keys, got {len(translations)}")

        out_path = LANG_DATA_DIR / f"{lang}.json"
        out_path.write_text(
            json.dumps(dict(sorted(translations.items())), ensure_ascii=False, indent=2) + "\\n",
            encoding="utf-8",
        )
        print(f"{lang}: {len(translations)} keys -> {out_path.relative_to(SCRIPT_DIR.parent)}")


if __name__ == "__main__":
    main()
'''

out = HEADER + pprint.pformat(PAYLOAD, width=120, sort_dicts=False) + FOOTER
(ROOT / "_build_translation_data.py").write_text(out, encoding="utf-8")
print("Generated _build_translation_data.py")
