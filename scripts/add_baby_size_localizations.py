#!/usr/bin/env python3
"""Add localized baby size comparison strings to Localizable.xcstrings."""

from __future__ import annotations

import json
from pathlib import Path

XCSTRINGS = (
    Path(__file__).resolve().parents[1]
    / "BloomlyPregnancyTracker/BloomlyPregnancyTracker/Localizable.xcstrings"
)

LOCALES = [
    "en", "es", "fr", "de", "it", "pt", "ar", "hi", "bn", "ja", "ko", "zh-Hans",
    "ru", "uk", "nl", "sv", "tr", "pl", "vi", "th", "id", "ms", "he", "el", "ro",
]

ITEMS_EN = {
    "poppy_seed": "poppy seed",
    "sesame_seed": "sesame seed",
    "lentil": "lentil",
    "blueberry": "blueberry",
    "raspberry": "raspberry",
    "grape": "grape",
    "cherry": "cherry",
    "strawberry": "strawberry",
    "fig": "fig",
    "lime": "lime",
    "peach": "peach",
    "plum": "plum",
    "lemon": "lemon",
    "nectarine": "nectarine",
    "apple": "apple",
    "avocado": "avocado",
    "pear": "pear",
    "bell_pepper": "bell pepper",
    "mango": "mango",
    "banana": "banana",
    "carrot": "carrot",
    "papaya": "papaya",
    "grapefruit": "grapefruit",
    "cantaloupe": "cantaloupe",
    "cauliflower": "cauliflower",
    "head_of_lettuce": "head of lettuce",
    "rutabaga": "rutabaga",
    "eggplant": "eggplant",
    "butternut_squash": "butternut squash",
    "cabbage": "cabbage",
    "coconut": "coconut",
    "jicama": "jicama",
    "pineapple": "pineapple",
    "honeydew_melon": "honeydew melon",
    "romaine_lettuce": "romaine lettuce",
    "bunch_of_swiss_chard": "bunch of Swiss chard",
    "mini_watermelon": "mini watermelon",
    "pumpkin": "pumpkin",
    "watermelon": "watermelon",
    "small_pumpkin": "small pumpkin",
    "full_term_baby": "full-term baby",
}

# Per-language item translations (key = sizeImage id)
ITEMS: dict[str, dict[str, str]] = {
    "bn": {
        "poppy_seed": "পোস্তো বীজ", "sesame_seed": "তিল", "lentil": "মসুর ডাল",
        "blueberry": "ব্লুবেরি", "raspberry": "রাস্পবেরি", "grape": "আঙুর",
        "cherry": "চেরি", "strawberry": "স্ট্রবেরি", "fig": "ডুমুর",
        "lime": "পাতি লেবু", "peach": "পীচ", "plum": "প্লাম",
        "lemon": "লেবু", "nectarine": "নেকটারিন", "apple": "আপেল",
        "avocado": "অ্যাভোকাডো", "pear": "নাশপাতি", "bell_pepper": "ক্যাপসিকাম",
        "mango": "আম", "banana": "কলা", "carrot": "গাজর", "papaya": "পেঁপে",
        "grapefruit": "জাম্বুরা", "cantaloupe": "খরবুজা", "cauliflower": "ফুলকপি",
        "head_of_lettuce": "লেটুস", "rutabaga": "শালগম", "eggplant": "বেগুন",
        "butternut_squash": "কুমড়ো", "cabbage": "বাঁধাকপি", "coconut": "নারকেল",
        "jicama": "জিকামা", "pineapple": "আনারস", "honeydew_melon": "মধু খরবুজা",
        "romaine_lettuce": "রোমেন লেটুস", "bunch_of_swiss_chard": "স্বিস চার্ড",
        "mini_watermelon": "ছোট তরমুজ", "pumpkin": "কুমড়ো", "watermelon": "তরমুজ",
        "small_pumpkin": "ছোট কুমড়ো", "full_term_baby": "পূর্ণসময়ের শিশু",
    },
    "hi": {
        "poppy_seed": "पोस्ता का बीज", "sesame_seed": "तिल", "lentil": "मसूर",
        "blueberry": "ब्लूबेरी", "raspberry": "रास्पबेरी", "grape": "अंगूर",
        "cherry": "चेरी", "strawberry": "स्ट्रॉबेरी", "fig": "अंजीर",
        "lime": "नींबू", "peach": "आड़ू", "plum": "बेर",
        "lemon": "नींबू", "nectarine": "नेक्टरीन", "apple": "सेब",
        "avocado": "एवोकाडो", "pear": "नाशपाती", "bell_pepper": "शिमला मिर्च",
        "mango": "आम", "banana": "केला", "carrot": "गाजर", "papaya": "पपीता",
        "grapefruit": "चकोतरा", "cantaloupe": "खरबूजा", "cauliflower": "फूलगोभी",
        "head_of_lettuce": "सलाद पत्ता", "rutabaga": "शलजम", "eggplant": "बैंगन",
        "butternut_squash": "कद्दू", "cabbage": "पत्तागोभी", "coconut": "नारियल",
        "jicama": "जिकामा", "pineapple": "अनानास", "honeydew_melon": "खरबूजा",
        "romaine_lettuce": "रोमaine लेट्यूस", "bunch_of_swiss_chard": "Swiss chard",
        "mini_watermelon": "छोटा तरबूज", "pumpkin": "कद्दू", "watermelon": "तरबूज",
        "small_pumpkin": "छोटा कद्दू", "full_term_baby": "पूरा विकसित बच्चा",
    },
    "es": {
        "poppy_seed": "semilla de amapola", "sesame_seed": "semilla de sésamo", "lentil": "lenteja",
        "blueberry": "arándano", "raspberry": "frambuesa", "grape": "uva",
        "cherry": "cereza", "strawberry": "fresa", "fig": "higo",
        "lime": "lima", "peach": "melocotón", "plum": "ciruela",
        "lemon": "limón", "nectarine": "nectarina", "apple": "manzana",
        "avocado": "aguacate", "pear": "pera", "bell_pepper": "pimiento",
        "mango": "mango", "banana": "plátano", "carrot": "zanahoria", "papaya": "papaya",
        "grapefruit": "toronja", "cantaloupe": "melón", "cauliflower": "coliflor",
        "head_of_lettuce": "lechuga", "rutabaga": "nabo", "eggplant": "berenjena",
        "butternut_squash": "calabaza", "cabbage": "repollo", "coconut": "coco",
        "jicama": "jícama", "pineapple": "piña", "honeydew_melon": "melón verde",
        "romaine_lettuce": "lechuga romana", "bunch_of_swiss_chard": "acelga",
        "mini_watermelon": "mini sandía", "pumpkin": "calabaza", "watermelon": "sandía",
        "small_pumpkin": "calabaza pequeña", "full_term_baby": "bebé a término",
    },
    "fr": {
        "poppy_seed": "graine de pavot", "sesame_seed": "graine de sésame", "lentil": "lentille",
        "blueberry": "myrtille", "raspberry": "framboise", "grape": "raisin",
        "cherry": "cerise", "strawberry": "fraise", "fig": "figue",
        "lime": "citron vert", "peach": "pêche", "plum": "prune",
        "lemon": "citron", "nectarine": "nectarine", "apple": "pomme",
        "avocado": "avocat", "pear": "poire", "bell_pepper": "poivron",
        "mango": "mangue", "banana": "banane", "carrot": "carotte", "papaya": "papaye",
        "grapefruit": "pamplemousse", "cantaloupe": "melon", "cauliflower": "chou-fleur",
        "head_of_lettuce": "laitue", "rutabaga": "rutabaga", "eggplant": "aubergine",
        "butternut_squash": "courge", "cabbage": "chou", "coconut": "noix de coco",
        "jicama": "jicama", "pineapple": "ananas", "honeydew_melon": "melon miel",
        "romaine_lettuce": "laitue romaine", "bunch_of_swiss_chard": "blette",
        "mini_watermelon": "mini pastèque", "pumpkin": "citrouille", "watermelon": "pastèque",
        "small_pumpkin": "petite citrouille", "full_term_baby": "bébé à terme",
    },
    "de": {
        "poppy_seed": "Mohnsamen", "sesame_seed": "Sesamsamen", "lentil": "Linse",
        "blueberry": "Blaubeere", "raspberry": "Himbeere", "grape": "Traube",
        "cherry": "Kirsche", "strawberry": "Erdbeere", "fig": "Feige",
        "lime": "Limette", "peach": "Pfirsich", "plum": "Pflaume",
        "lemon": "Zitrone", "nectarine": "Nektarine", "apple": "Apfel",
        "avocado": "Avocado", "pear": "Birne", "bell_pepper": "Paprika",
        "mango": "Mango", "banana": "Banane", "carrot": "Karotte", "papaya": "Papaya",
        "grapefruit": "Grapefruit", "cantaloupe": "Cantaloupe-Melone", "cauliflower": "Blumenkohl",
        "head_of_lettuce": "Kopfsalat", "rutabaga": "Steckrübe", "eggplant": "Aubergine",
        "butternut_squash": "Butternusskürbis", "cabbage": "Kohl", "coconut": "Kokosnuss",
        "jicama": "Jicama", "pineapple": "Ananas", "honeydew_melon": "Honigmelone",
        "romaine_lettuce": "Römischer Salat", "bunch_of_swiss_chard": "Mangold",
        "mini_watermelon": "Mini-Wassermelone", "pumpkin": "Kürbis", "watermelon": "Wassermelone",
        "small_pumpkin": "kleiner Kürbis", "full_term_baby": "ausgetragenes Baby",
    },
    "ar": {
        "poppy_seed": "بذرة خشخاش", "sesame_seed": "بذرة سمسم", "lentil": "عدس",
        "blueberry": "توت أزرق", "raspberry": "توت", "grape": "عنب",
        "cherry": "كرز", "strawberry": "فراولة", "fig": "تين",
        "lime": "لime", "peach": "خوخ", "plum": "برقوق",
        "lemon": "ليمون", "nectarine": "nectarine", "apple": "تفاحة",
        "avocado": "أفocado", "pear": "كمثرى", "bell_pepper": "فلفل رومي",
        "mango": "مانgo", "banana": "موز", "carrot": "جزر", "papaya": "بapaya",
        "grapefruit": "جريپfruit", "cantaloupe": "شمام", "cauliflower": "قرنبيط",
        "head_of_lettuce": "خس", "rutabaga": "لفت", "eggplant": "باذنجان",
        "butternut_squash": "قرع", "cabbage": "ملفوف", "coconut": "جوز هند",
        "jicama": "jicama", "pineapple": "أnanas", "honeydew_melon": "شمام",
        "romaine_lettuce": "خس روماني", "bunch_of_swiss_chard": "سلق",
        "mini_watermelon": "بطيخ صغير", "pumpkin": "يقطين", "watermelon": "بطيخ",
        "small_pumpkin": "يقطين صغير", "full_term_baby": "رضيع مكتمل النمو",
    },
    "ja": {
        "poppy_seed": "ポピーの種", "sesame_seed": "ゴマ", "lentil": "レンズ豆",
        "blueberry": "ブルーベリー", "raspberry": "ラズベリー", "grape": "ブドウ",
        "cherry": "サクランボ", "strawberry": "イチゴ", "fig": "イチジク",
        "lime": "ライム", "peach": "モモ", "plum": "スモモ",
        "lemon": "レモン", "nectarine": "ネクタリン", "apple": "リンゴ",
        "avocado": "アボカド", "pear": "ナシ", "bell_pepper": "ピーマン",
        "mango": "マンゴー", "banana": "バナナ", "carrot": "ニンジン", "papaya": "パパイヤ",
        "grapefruit": "グrapefruit", "cantaloupe": "メロン", "cauliflower": "カリフラワー",
        "head_of_lettuce": "レタス", "rutabaga": "ルタバガ", "eggplant": "ナス",
        "butternut_squash": "カボチャ", "cabbage": "キャベツ", "coconut": "ココナッツ",
        "jicama": "ヒカマ", "pineapple": "パイナップル", "honeydew_melon": "メロン",
        "romaine_lettuce": "ロメインレタス", "bunch_of_swiss_chard": "フダンソウ",
        "mini_watermelon": "ミニスイカ", "pumpkin": "カボチャ", "watermelon": "スイカ",
        "small_pumpkin": "小さなカボチャ", "full_term_baby": "足月の赤ちゃん",
    },
    "ko": {
        "poppy_seed": "양귀비 씨", "sesame_seed": "참깨", "lentil": "렌틸콩",
        "blueberry": "블루berry", "raspberry": "라즈베리", "grape": "포도",
        "cherry": "체리", "strawberry": "딸기", "fig": "무화과",
        "lime": "라임", "peach": "복숭아", "plum": "자두",
        "lemon": "레mon", "nectarine": "넥tarine", "apple": "사과",
        "avocado": "아보카도", "pear": "배", "bell_pepper": "피망",
        "mango": "망고", "banana": "바나나", "carrot": "당근", "papaya": "파파야",
        "grapefruit": "자몽", "cantaloupe": "멜론", "cauliflower": "콜iflower",
        "head_of_lettuce": "상추", "rutabaga": "순무", "eggplant": "가지",
        "butternut_squash": "호박", "cabbage": "양배추", "coconut": "코코nut",
        "jicama": "jicama", "pineapple": "파인애플", "honeydew_melon": "허니듀 멜론",
        "romaine_lettuce": "로메인 상추", "bunch_of_swiss_chard": "근대",
        "mini_watermelon": "미니 수박", "pumpkin": "호박", "watermelon": "수박",
        "small_pumpkin": "작은 호박", "full_term_baby": "만삭 아기",
    },
    "zh-Hans": {
        "poppy_seed": "罂粟籽", "sesame_seed": "芝麻", "lentil": "扁豆",
        "blueberry": "蓝莓", "raspberry": "覆盆子", "grape": "葡萄",
        "cherry": "樱桃", "strawberry": "草莓", "fig": "无花果",
        "lime": "青柠", "peach": "桃子", "plum": "李子",
        "lemon": "柠檬", "nectarine": "油桃", "apple": "苹果",
        "avocado": "牛油果", "pear": "梨", "bell_pepper": "甜椒",
        "mango": "芒果", "banana": "香蕉", "carrot": "胡萝卜", "papaya": "木瓜",
        "grapefruit": "葡萄柚", "cantaloupe": "哈密瓜", "cauliflower": "花椰菜",
        "head_of_lettuce": "生菜", "rutabaga": "芜菁", "eggplant": "茄子",
        "butternut_squash": "南瓜", "cabbage": "卷心菜", "coconut": "椰子",
        "jicama": "豆薯", "pineapple": "菠萝", "honeydew_melon": "蜜瓜",
        "romaine_lettuce": "罗马生菜", "bunch_of_swiss_chard": "瑞士甜菜",
        "mini_watermelon": "小西瓜", "pumpkin": "南瓜", "watermelon": "西瓜",
        "small_pumpkin": "小南瓜", "full_term_baby": "足月宝宝",
    },
    "ru": {
        "poppy_seed": "семя мака", "sesame_seed": "кунжут", "lentil": "чечевица",
        "blueberry": "черника", "raspberry": "малина", "grape": "виноград",
        "cherry": "вишня", "strawberry": "клубника", "fig": "инжир",
        "lime": "лайм", "peach": "персик", "plum": "слива",
        "lemon": "лимон", "nectarine": "нектарин", "apple": "яблоко",
        "avocado": "авокадо", "pear": "груша", "bell_pepper": "болгарский перец",
        "mango": "манго", "banana": "банан", "carrot": "морковь", "papaya": "папайя",
        "grapefruit": "грейпфрут", "cantaloupe": "дыня", "cauliflower": "цветная капуста",
        "head_of_lettuce": "салат", "rutabaga": "брюква", "eggplant": "баклажан",
        "butternut_squash": "тыква", "cabbage": "капуста", "coconut": "кокос",
        "jicama": "хикама", "pineapple": "ананас", "honeydew_melon": "медовая дыня",
        "romaine_lettuce": "салат рomaine", "bunch_of_swiss_chard": "мангольд",
        "mini_watermelon": "мини-арбуз", "pumpkin": "тыква", "watermelon": "арбуз",
        "small_pumpkin": "маленькая тыква", "full_term_baby": "доношенный малыш",
    },
}

TEMPLATES = {
    "en": {
        "a": "Your baby is the size of a %@",
        "an": "Your baby is the size of an %@",
        "full": "Your baby is the size of a full-term baby",
        "growing": "Growing every day",
    },
    "bn": {
        "a": "আপনার শিশুর আকার একটি %@ এর মতো",
        "an": "আপনার শিশুর আকার একটি %@ এর মতো",
        "full": "আপনার শিশুর আকার একটি পূর্ণসময়ের শিশুর মতো",
        "growing": "প্রতিদিন বড় হচ্ছে",
    },
    "hi": {
        "a": "आपका बच्चा एक %@ जितना बड़ा है",
        "an": "आपका बच्चा एक %@ जितना बड़ा है",
        "full": "आपका बच्चा पूर्ण विकसित बच्चे जितना बड़ा है",
        "growing": "हर दिन बढ़ रहा है",
    },
    "es": {
        "a": "Tu bebé tiene el tamaño de un %@",
        "an": "Tu bebé tiene el tamaño de un %@",
        "full": "Tu bebé tiene el tamaño de un bebé a término",
        "growing": "Crece cada día",
    },
    "fr": {
        "a": "Votre bébé a la taille d'un %@",
        "an": "Votre bébé a la taille d'un %@",
        "full": "Votre bébé a la taille d'un bébé à terme",
        "growing": "Grandit chaque jour",
    },
    "de": {
        "a": "Dein Baby ist so groß wie ein %@",
        "an": "Dein Baby ist so groß wie ein %@",
        "full": "Dein Baby ist so groß wie ein ausgetragenes Baby",
        "growing": "Wächst jeden Tag",
    },
    "ar": {
        "a": "حجم طفلك مثل %@",
        "an": "حجم طفلك مثل %@",
        "full": "حجم طفلك مثل رضيع مكتمل النمو",
        "growing": "ينمو كل يوم",
    },
    "ja": {
        "a": "赤ちゃんは%@くらいの大きさです",
        "an": "赤ちゃんは%@くらいの大きさです",
        "full": "赤ちゃんは足月の赤ちゃんくらいの大きさです",
        "growing": "毎日成長中",
    },
    "ko": {
        "a": "아기는 %@ 크기예요",
        "an": "아기는 %@ 크기예요",
        "full": "아기는 만삭 아기 크기예요",
        "growing": "매일 자라고 있어요",
    },
    "zh-Hans": {
        "a": "您的宝宝有一个%@那么大",
        "an": "您的宝宝有一个%@那么大",
        "full": "您的宝宝有一个足月宝宝那么大",
        "growing": "每天都在成长",
    },
    "ru": {
        "a": "Ваш малыш размером с %@",
        "an": "Ваш малыш размером с %@",
        "full": "Ваш малыш размером с доношенного малыша",
        "growing": "Растёт каждый день",
    },
    "it": {
        "a": "Il tuo bambino è grande come un %@",
        "an": "Il tuo bambino è grande come un %@",
        "full": "Il tuo bambino è grande come un bambino a termine",
        "growing": "Cresce ogni giorno",
    },
    "pt": {
        "a": "Seu bebê tem o tamanho de um %@",
        "an": "Seu bebê tem o tamanho de um %@",
        "full": "Seu bebê tem o tamanho de um bebê a termo",
        "growing": "Crescendo a cada dia",
    },
    "tr": {
        "a": "Bebeğiniz bir %@ kadar",
        "an": "Bebeğiniz bir %@ kadar",
        "full": "Bebeğiniz tam gelişmiş bir bebek kadar",
        "growing": "Her gün büyüyor",
    },
    "pl": {
        "a": "Twoje dziecko ma rozmiar %@",
        "an": "Twoje dziecko ma rozmiar %@",
        "full": "Twoje dziecko ma rozmiar niemowlęcia urodzonego o terminie",
        "growing": "Rośnie każdego dnia",
    },
    "nl": {
        "a": "Je baby is zo groot als een %@",
        "an": "Je baby is zo groot als een %@",
        "full": "Je baby is zo groot als een voldragen baby",
        "growing": "Groeit elke dag",
    },
    "uk": {
        "a": "Ваша дитина розміром з %@",
        "an": "Ваша дитина розміром з %@",
        "full": "Ваша дитина розміром з доношеної дитини",
        "growing": "Росте щодня",
    },
    "vi": {
        "a": "Em bé của bạn có kích thước bằng một %@",
        "an": "Em bé của bạn có kích thước bằng một %@",
        "full": "Em bé của bạn có kích thước bằng một em bé đủ tháng",
        "growing": "Lớn lên mỗi ngày",
    },
    "th": {
        "a": "ลูกของคุณมีขนาดเท่า%@",
        "an": "ลูกของคุณมีขนาดเท่า%@",
        "full": "ลูกของคุณมีขนาดเท่าทารกครบกำหนด",
        "growing": "เติบโตทุกวัน",
    },
    "id": {
        "a": "Bayi Anda seukuran %@",
        "an": "Bayi Anda seukuran %@",
        "full": "Bayi Anda seukuran bayi cukup bulan",
        "growing": "Tumbuh setiap hari",
    },
    "ms": {
        "a": "Bayi anda sebesar %@",
        "an": "Bayi anda sebesar %@",
        "full": "Bayi anda sebesar bayi cukup bulan",
        "growing": "Berkembang setiap hari",
    },
    "he": {
        "a": "התינוק/ת בגודל של %@",
        "an": "התינוק/ת בגודל של %@",
        "full": "התינוק/ת בגודל של תינוק שנולד במועד",
        "growing": "גדל/ה כל יום",
    },
    "el": {
        "a": "Το μωρό σας έχει μέγεθος %@",
        "an": "Το μωρό σας έχει μέγεθος %@",
        "full": "Το μωρό σας έχει μέγεθος ενός ώριμου μωρού",
        "growing": "Μεγαλώνει κάθε μέρα",
    },
    "ro": {
        "a": "Bebelușul tău are mărimea unui %@",
        "an": "Bebelușul tău are mărimea unui %@",
        "full": "Bebelușul tău are mărimea unui bebeluș la termen",
        "growing": "Crește în fiecare zi",
    },
    "sv": {
        "a": "Din baby är stor som en %@",
        "an": "Din baby är stor som en %@",
        "full": "Din baby är stor som ett fullgånget barn",
        "growing": "Växer varje dag",
    },
}


def item_name(lang: str, item_id: str) -> str:
    if lang in ITEMS and item_id in ITEMS[lang]:
        return ITEMS[lang][item_id]
    if lang != "en" and "en" in ITEMS and item_id in ITEMS["en"]:
        return ITEMS["en"][item_id]
    return ITEMS_EN[item_id]


def template_for(lang: str) -> dict[str, str]:
    if lang in TEMPLATES:
        return TEMPLATES[lang]
    return TEMPLATES["en"]


def make_entry(value: str, lang: str) -> dict:
    return {
        "stringUnit": {
            "state": "translated" if lang != "en" else "new",
            "value": value,
        }
    }


def upsert_key(strings: dict, key: str, english: str, translations: dict[str, str]) -> None:
    localizations = {}
    for lang in LOCALES:
        localizations[lang] = make_entry(translations.get(lang, english), lang)
    strings[key] = {
        "extractionState": "manual",
        "localizations": localizations,
    }


def main() -> None:
    data = json.loads(XCSTRINGS.read_text(encoding="utf-8"))
    strings = data.setdefault("strings", {})

    tmpl_en = template_for("en")
    upsert_key(strings, "babySize.comparisonA %@", tmpl_en["a"], {
        lang: template_for(lang)["a"] for lang in LOCALES
    })
    upsert_key(strings, "babySize.comparisonAn %@", tmpl_en["an"], {
        lang: template_for(lang)["an"] for lang in LOCALES
    })
    upsert_key(strings, "babySize.comparisonFullTerm", tmpl_en["full"], {
        lang: template_for(lang)["full"] for lang in LOCALES
    })
    upsert_key(strings, "babySize.growingEveryDay", tmpl_en["growing"], {
        lang: template_for(lang)["growing"] for lang in LOCALES
    })

    for item_id, english in ITEMS_EN.items():
        key = f"babySize.item.{item_id}"
        upsert_key(strings, key, english, {
            lang: item_name(lang, item_id) for lang in LOCALES
        })

    XCSTRINGS.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Added baby size keys: 4 templates + {len(ITEMS_EN)} items × {len(LOCALES)} locales")


if __name__ == "__main__":
    main()
