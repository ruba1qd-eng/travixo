import 'models.dart';

/// ============================================================
///  Travixo — أفضل الأماكن في اليمن (بيانات توضيحية)
///  الملف: lib/data/places_data.dart
///  تغذي: شاشة أفضل الأماكن + الخريطة الحية + صمم خطتك
///  الأماكن حقيقية معروفة، والأوصاف والتصنيفات توضيحية
///  الصور: Unsplash مرخصة — تُستبدل بصور الشركاء عند الإطلاق
/// ============================================================

class BestPlace {
  final String id;
  final String nameAr, nameEn;
  final String descAr, descEn;
  final String provinceId;
  final String category; // culture | beach | mountain | market | nature
  final double rating;
  final double lat, lng;
  final bool unesco; // موقع عالمي (يونسكو)

  const BestPlace({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descAr,
    required this.descEn,
    required this.provinceId,
    required this.category,
    required this.rating,
    required this.lat,
    required this.lng,
    this.unesco = false,
  });

  String name(bool isArabic) => isArabic ? nameAr : nameEn;
  String desc(bool isArabic) => isArabic ? descAr : descEn;

  /// صورة المكان — صورة حقيقية للمكان نفسه، وبديل صورة المحافظة أو صورة عامة
  String img() => kPlaceImgs[id] ?? kProvinceImgs[provinceId] ?? kDemoImg;
}

const List<BestPlace> kBestPlaces = [
  // ===== صنعاء =====
  BestPlace(
    id: 'p1', nameAr: 'صنعاء القديمة', nameEn: 'Old Sanaa',
    descAr: 'أقدم مدن العالم المأهولة باستمرار، ببيوتها الطينية المزخرفة وأسواقها التراثية مثل سوق الملح.',
    descEn: 'One of the oldest continuously inhabited cities, with decorated tower-houses and heritage souqs like Souq Al-Milh.',
    provinceId: 'sanaa', category: 'culture', rating: 4.9,
    lat: 15.3489, lng: 44.2062, unesco: true,
  ),
  BestPlace(
    id: 'p2', nameAr: 'دار الحجر', nameEn: 'Dar al-Hajar',
    descAr: 'قصر صخري شهير مبني فوق صخرة ضخمة في وادي ظهر، من أبرز معالم اليمن المصورة.',
    descEn: 'The famous rock palace built atop a giant boulder in Wadi Dhar — Yemen\'s most iconic landmark.',
    provinceId: 'sanaa', category: 'culture', rating: 4.8,
    lat: 15.2854, lng: 44.1322,
  ),
  // ===== عدن =====
  BestPlace(
    id: 'p3', nameAr: 'سيرة عدن (بن Aden)', nameEn: 'Sira Fortress & Big Ben of Aden',
    descAr: 'قلعة تاريخية فوق جبل سيرة تطل على ميناء عدن، وبجانبها ساعة عدن الشهيرة المشابهة لبيغ بن.',
    descEn: 'Historic fortress overlooking Aden port, next to the famous Aden clock tower inspired by Big Ben.',
    provinceId: 'aden', category: 'culture', rating: 4.7,
    lat: 12.7870, lng: 45.0330,
  ),
  BestPlace(
    id: 'p4', nameAr: 'شواطئ عدن — خور مقسام', nameEn: 'Aden Beaches — Khormaksar',
    descAr: 'شاطئ جميل على البحر العربي مناسب للعائلات، مع إطلالة ساحرة على المدينة من البحر.',
    descEn: 'A family-friendly beach on the Arabian Sea with beautiful city views from the water.',
    provinceId: 'aden', category: 'beach', rating: 4.5,
    lat: 12.7960, lng: 45.0105,
  ),
  // ===== حضرموت =====
  BestPlace(
    id: 'p5', nameAr: 'شبام حضرموت', nameEn: 'Shibam Hadramout',
    descAr: 'مدينة الأبراج الطينية — أقدم مدينة ناطحات سحاب في العالم، مدرجة في قائمة اليونسكو.',
    descEn: 'The mudbrick skyscraper city — the world\'s oldest vertical city, a UNESCO World Heritage site.',
    provinceId: 'hadramout', category: 'culture', rating: 4.9,
    lat: 15.9311, lng: 48.6295, unesco: true,
  ),
  BestPlace(
    id: 'p6', nameAr: 'وادي دوعن', nameEn: 'Wadi Doan',
    descAr: 'أجمل أودية حضرموت: قرى معلقة على الجروف، مزارع النخيل، ومبانٍ طينية عالية.',
    descEn: 'The most beautiful of Hadramout valleys: cliff-hanging villages, palm farms and tall mudbrick houses.',
    provinceId: 'hadramout', category: 'nature', rating: 4.8,
    lat: 15.4833, lng: 48.8667,
  ),
  BestPlace(
    id: 'p7', nameAr: 'كورنيش المكلا', nameEn: 'Mukalla Corniche',
    descAr: 'واجهة بحرية حديثة على بحر العرب مع مطاعم أسماك طازجة وأجواء مسائية جميلة.',
    descEn: 'A modern seafront on the Arabian Sea with fresh seafood restaurants and lovely evening vibes.',
    provinceId: 'hadramout', category: 'beach', rating: 4.6,
    lat: 14.5350, lng: 49.1280,
  ),
  // ===== تعز =====
  BestPlace(
    id: 'p8', nameAr: 'جبل صبر', nameEn: 'Jabal Sabr',
    descAr: 'أعلى قمم تعز بإطلالة بانورامية على المدينة والساحل، ومقصد للمتنزهين صباحاً ومساءً.',
    descEn: 'Taiz\'s highest peak with panoramic city and coast views — a favorite hiking spot.',
    provinceId: 'taiz', category: 'mountain', rating: 4.7,
    lat: 13.5430, lng: 44.0000,
  ),
  BestPlace(
    id: 'p9', nameAr: 'الجامع الكبير — تعز', nameEn: 'Al-Ashrafiya Mosque',
    descAr: 'جامع الأشرفية التاريخي بقبته الجميلة ومئذنتيه، تحفة معمارية من الدولة الطاهرية.',
    descEn: 'The historic Ashrafiya mosque with its beautiful dome and minarets — a Tahirid architectural gem.',
    provinceId: 'taiz', category: 'culture', rating: 4.4,
    lat: 13.5760, lng: 44.0250,
  ),
  // ===== مأرب =====
  BestPlace(
    id: 'p10', nameAr: 'سد مأرب القديم', nameEn: 'Ancient Marib Dam',
    descAr: 'بقايا أعظم هندسة ري في الجزيرة العربية قديماً، ذكره القرآن، مع أبواب السد الأثرية.',
    descEn: 'Remains of the greatest ancient irrigation engineering in Arabia, mentioned in the Quran.',
    provinceId: 'marib', category: 'culture', rating: 4.6,
    lat: 15.4300, lng: 45.3200,
  ),
  BestPlace(
    id: 'p11', nameAr: 'أوام — مأرب', nameEn: 'Awam Temple (Mahram Bilqis)',
    descAr: 'معبد أوام الشهير المخصص لعبادة الإله المقتبس، موقع أثري سبأي عظيم قرب مأرب.',
    descEn: 'The famous Sabaean temple dedicated to the god Almaqah, near Marib.',
    provinceId: 'marib', category: 'culture', rating: 4.5,
    lat: 15.4000, lng: 45.3500,
  ),
  // ===== سقطرى =====
  BestPlace(
    id: 'p12', nameAr: 'شجرة دم الأخوين — سقطرى', nameEn: 'Dragon Blood Trees — Socotra',
    descAr: 'أشهر شجرة في العالم بمظلتها الفريدة، لا توجد طبيعياً إلا في سقطرى — موقع يونسكو.',
    descEn: 'The world\'s most iconic tree with its umbrella shape, found naturally only in Socotra — UNESCO site.',
    provinceId: 'socotra', category: 'nature', rating: 5.0,
    lat: 12.5456, lng: 53.9556, unesco: true,
  ),
  BestPlace(
    id: 'p13', nameAr: 'شاطئ قلنسية — سقطرى', nameEn: 'Qalansiyah Beach',
    descAr: 'شاطئ بفيروزي نقي ورمال بيضاء مع ديتل (جزر صغيرة) — من أجمل شواطئ العالم.',
    descEn: 'Crystal turquoise water and white sand with Detwah lagoon — among the world\'s best beaches.',
    provinceId: 'socotra', category: 'beach', rating: 4.9,
    lat: 12.6167, lng: 53.9500,
  ),
  // ===== إب =====
  BestPlace(
    id: 'p14', nameAr: 'مدينة إب الخضراء', nameEn: 'Green Highlands of Ibb',
    descAr: 'مدينة الشعراء: طبيعة خضراء طول العام، مدرجات زراعية وشلالات وضباب صباحي ساحر.',
    descEn: 'The poets\' city: year-round greenery, terraced farms, waterfalls and magical morning mist.',
    provinceId: 'ibb', category: 'mountain', rating: 4.5,
    lat: 13.9662, lng: 44.1847,
  ),
  // ===== الحديدة =====
  BestPlace(
    id: 'p15', nameAr: 'شواطئ الحديدة — الخوخة', nameEn: 'Red Sea Coast — Al Khawkhah',
    descAr: 'ساحل البحر الأحمر بمغروسه وأجواء بكر، ومنطقة لصيد الأسماك التقليدي.',
    descEn: 'Untouched Red Sea coastline with traditional fishing villages.',
    provinceId: 'hodeidah', category: 'beach', rating: 4.2,
    lat: 13.9630, lng: 42.9700,
  ),
  BestPlace(
    id: 'p16', nameAr: 'جبل برع — الحديدة', nameEn: 'Jabal Bura',
    descAr: 'محمية طبيعية بغابات عالية فوق الحديدة، من أنعم مناخات الساحل اليمني.',
    descEn: 'A nature reserve with highland forests above Hodeidah — the mildest climate on the coast.',
    provinceId: 'hodeidah', category: 'mountain', rating: 4.3,
    lat: 14.8500, lng: 43.4000,
  ),
  // ===== ذمار =====
  BestPlace(
    id: 'p17', nameAr: 'حوض ذمار التاريخي', nameEn: 'Historic Dhamar',
    descAr: 'مدينة ذمار العاليك التاريخية ومنابع الماء القديمة وسط هضبة خضراء.',
    descEn: 'The historic city of Dhamar Ali Yahrib with ancient water springs on a green plateau.',
    provinceId: 'dhamar', category: 'culture', rating: 4.2,
    lat: 14.5686, lng: 44.1972,
  ),
  // ===== حجة =====
  BestPlace(
    id: 'p18', nameAr: 'شاهرة حجة', nameEn: 'Shaharah Bridge',
    descAr: 'جسر شاهرة الحجري الشهير المبني عام 17م فوق هاوية — أعجوبة الهندسة اليمنية القديمة.',
    descEn: 'The famous 17th-century stone bridge built over a cliff — a marvel of old Yemeni engineering.',
    provinceId: 'hajjah', category: 'culture', rating: 4.6,
    lat: 15.8500, lng: 43.7500,
  ),
];

/// تصنيفات الأماكن — تُستخدم في الفلاتر والخطة
const Map<String, List<String>> kPlaceCategories = {
  'ar': ['culture', 'beach', 'mountain', 'market', 'nature'],
  'en': ['culture', 'beach', 'mountain', 'market', 'nature'],
};

String placeCategoryLabel(String cat, bool isArabic) => switch (cat) {
      'culture' => isArabic ? 'ثقافة وتاريخ' : 'Culture & History',
      'beach' => isArabic ? 'شواطئ' : 'Beaches',
      'mountain' => isArabic ? 'جبال وطبيعة' : 'Mountains',
      'market' => isArabic ? 'أسواق' : 'Markets',
      _ => isArabic ? 'طبيعة' : 'Nature',
    };

/// أفضل الأماكن في محافظة محددة
List<BestPlace> placesInProvince(String provinceId) =>
    kBestPlaces.where((p) => p.provinceId == provinceId).toList();
