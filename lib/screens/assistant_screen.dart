// ============================================================
//  Travixo — المساعد الذكي
//  الملف: lib/screens/assistant_screen.dart
//  الخطوة 4د: مساعد محادثة يعمل بالكامل بدون إنترنت
//  - محرك نوايا بالكلمات المفتاحية (عربي + إنجليزي)
//  - يجيب ببيانات حقيقية من التطبيق: أرخص فندق، أسعار الرحلات،
//    المسافات بين المحافظات (Haversine) واقتراح خطط
//  - أزرار إجراءات سريعة تفتح الشاشات مباشرة
// ============================================================

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../data/places_data.dart';
import '../data/real_hotels_data.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'best_places_screen.dart';
import 'details_screens.dart';
import 'live_map_screen.dart';
import 'transport_booking_screen.dart';
import 'trip_planner_screen.dart';

/// أسماء شائعة للمحافظات يكتبها المستخدمون (عربي + إنجليزي)
const Map<String, List<String>> kProvinceAliases = {
  'sanaa': ['صنعاء', 'صنعا', 'sanaa', 'sana'],
  'aden': ['عدن', 'aden'],
  'taiz': ['تعز', 'taiz'],
  'hadramout': ['حضرموت', 'مكلا', 'شبام', 'سيئون', 'hadramout', 'mukalla', 'shibam'],
  'hodeidah': ['الحديدة', 'Hديدة', 'hodeidah', 'hodeida'],
  'ibb': ['إب', 'ibb'],
  'dhamar': ['ذمار', 'dhamar'],
  'marib': ['مأرب', 'مارب', 'marib'],
  'socotra': ['سقطرى', 'سقطره', 'socotra', 'سقوترا'],
  'hajjah': ['حجة', 'hajjah'],
  'lahij': ['لحج', 'lahij'],
};

class _Action {
  final IconData icon;
  final String label;
  final Widget Function(BuildContext) screen;
  const _Action(this.icon, this.label, this.screen);
}

class _Msg {
  final bool me;
  final String text;
  final List<_Action> actions;
  const _Msg(this.me, this.text, {this.actions = const []});
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});
  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  bool _typing = false;
  final List<_Msg> _msgs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _welcome());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _add(_Msg m) {
    setState(() => _msgs.add(m));
    _toBottom();
  }

  void _welcome() {
    final l = context.l;
    _add(_Msg(false, l.t('assistantHello'), actions: _quickActions()));
  }

  List<_Action> _quickActions() {
    final l = context.l;
    return [
      _Action(Icons.hotel, l.t('hotels'),
          (_) => const DetailsScreen(service: ServiceType.hotel, targetId: 'list')),
      _Action(Icons.map, l.t('tours'),
          (_) => const DetailsScreen(service: ServiceType.tour, targetId: 'list')),
      _Action(Icons.directions_car, l.t('localRide'), (_) => const TransportBookingScreen()),
      _Action(Icons.event_note, l.t('planTrip'), (_) => const TripPlannerScreen()),
      _Action(Icons.explore, l.t('bestPlaces'), (_) => const BestPlacesScreen()),
      _Action(Icons.location_on, l.t('liveMap'), (_) => const LiveMapScreen()),
    ];
  }

  // ==================== إرسال ومعالجة ====================
  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _typing) return;
    _ctrl.clear();
    _add(_Msg(true, text));
    _reply(text);
  }

  Future<void> _reply(String input) async {
    final l = context.l;
    final isAr = l.isArabic;
    setState(() => _typing = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _typing = false);

    final q = input.toLowerCase();
    final pid = _detectProvince(q);

    // 1) تحية
    if (_has(q, ['مرحبا', 'مرحبتين', 'السلام', 'هلا', 'أهلا', 'اهلا', 'hi', 'hello', 'salam'])) {
      _add(_Msg(false,
          isAr ? 'أهلاً بك في Travixo 👋 كيف أساعدك في رحلتك؟ جرب: «أرخص فندق في عدن» أو «رحلات حضرموت».'
               : 'Welcome to Travixo 👋 How can I help? Try: "cheapest hotel in Aden" or "Hadramout tours".',
          actions: _quickActions()));
      return;
    }

    // 2) شكر
    if (_has(q, ['شكرا', 'شكراً', 'thanks', 'thank you'])) {
      _add(_Msg(false,
          isAr ? 'العفو 🌟 رحلة سعيدة! أنا هنا في أي وقت.'
               : 'You are welcome 🌟 Have a great trip! I am here anytime.'));
      return;
    }

    // 3) محافظة محددة → بطاقة معلومات
    if (pid != null) {
      _add(_provinceInfo(pid));
      return;
    }

    // 4) أرخص / أفضل فندق
    if (_has(q, ['أرخص', 'ارخص', 'رخيص', 'cheap', 'cheapest']) &&
        _has(q, ['فندق', 'فنادق', 'hotel', 'سكن', 'نوم', 'room'])) {
      _add(_cheapestHotel());
      return;
    }
    if (_has(q, ['أفضل', 'افضل', 'best', 'توب', 'top']) &&
        _has(q, ['فندق', 'فنادق', 'hotel'])) {
      _add(_bestHotel());
      return;
    }

    // 5) فنادق عامة
    if (_has(q, ['فندق', 'فنادق', 'hotel', 'سكن', 'إقامة', 'اقامة', 'نوم'])) {
      _add(_Msg(false,
          isAr ? 'لدينا فنادق موثوقة في صنعاء وعدن وتعز وحضرموت والمأرب وغيرها 🏨 ما المحافظة التي تخطط لها؟ أو افتح القائمة مباشرة:'
               : 'We have trusted hotels in Sanaa, Aden, Taiz, Hadramout, Marib and more 🏨 Which province? Or open the list:',
          actions: [
            _Action(Icons.hotel, l.t('hotels'),
                (_) => const DetailsScreen(service: ServiceType.hotel, targetId: 'list')),
            _Action(Icons.explore, l.t('bestPlaces'), (_) => const BestPlacesScreen()),
          ]));
      return;
    }

    // 6) سيارات / نقل
    if (_has(q, ['سيارة', 'سيارات', 'car', 'تأجير', 'تاجير', 'rent', 'نقل', 'سائق', 'drive', 'ride', 'مطار', 'airport'])) {
      final airport = _has(q, ['مطار', 'airport']);
      _add(_Msg(false,
          airport
              ? (isAr ? 'نقل المطار متاح مع سيارات VIP وعادية 🚘 قدّم طلبك مع مكان الانطلاق والوقت:'
                      : 'Airport transfer is available with VIP and standard cars 🚘 Book with pickup and time:')
              : (isAr ? 'نوفر نقل مع سائق وتأجير بدون سائق في معظم المحافظات 🚗 اختر ما يناسبك:'
                      : 'We offer chauffeured rides and self-drive rentals 🚗 Choose what suits you:'),
          actions: [
            if (!airport)
              _Action(Icons.directions_car, l.t('rentCar'),
                  (_) => const DetailsScreen(service: ServiceType.rentCar, targetId: 'list')),
            _Action(Icons.local_taxi,
                airport ? l.t('airport') : l.t('localRide'),
                (_) => const TransportBookingScreen()),
          ]));
      return;
    }

    // 7) رحلات وباقات
    if (_has(q, ['رحلة', 'رحلات', 'tour', 'package', 'باقة', 'باقات', 'برنامج', 'جولة'])) {
      _add(_toursReply());
      return;
    }

    // 8) الخطة
    if (_has(q, ['خطة', 'خطتي', 'خطه', 'plan', 'planner', 'برنامج رحلة', 'trip'])) {
      _add(_Msg(false,
          isAr ? 'صمم خطتك بنفسك: اختر المحافظة وعدد الأيام والميزانية واهتماماتك، وسأولّد لك برنامجاً يومياً كاملاً مع التكلفة التقديرية 📅'
               : 'Build your own plan: choose province, days, budget and interests, and I will generate a full daily program with estimated cost 📅',
          actions: [
            _Action(Icons.event_note, l.t('planTrip'), (_) => const TripPlannerScreen()),
          ]));
      return;
    }

    // 9) الخريطة والأماكن
    if (_has(q, ['خريطة', 'map', 'مكان', 'أماكن', 'اماكن', 'place', 'وجهة', 'مقصد'])) {
      _add(_Msg(false,
          isAr ? 'اكتشف اليمن على الخريطة الحية أو تصفح أفضل الأماكن المميزة 🗺️'
               : 'Explore Yemen on the live map or browse the best places 🗺️',
          actions: [
            _Action(Icons.location_on, l.t('liveMap'), (_) => const LiveMapScreen()),
            _Action(Icons.explore, l.t('bestPlaces'), (_) => const BestPlacesScreen()),
          ]));
      return;
    }

    // 10) أسعار عامة
    if (_has(q, ['سعر', 'اسعار', 'أسعار', 'price', 'كم', 'cost', 'تكلفة'])) {
      _add(_pricesSummary());
      return;
    }

    // 11) مساعدة
    if (_has(q, ['مساعدة', 'ساعدني', 'help', 'كيف', 'ايش', 'وش', 'ماذا'])) {
      _add(_Msg(false,
          isAr ? 'أقدر أساعدك في: 🏨 الفنادق وأسعارها — 🚗 السيارات والنقل — 🧭 الرحلات الجاهزة — 📅 صمم خطتك — 🗺️ الخريطة والأماكن. جرب سؤالاً مثل: «أرخص فندق» أو «رحلات حضرموت».'
               : 'I can help with: 🏨 hotels & prices — 🚗 cars & transport — 🧭 ready tours — 📅 trip planner — 🗺️ map & places. Try: "cheapest hotel" or "Hadramout tours".',
          actions: _quickActions()));
      return;
    }

    // 12) لم أفهم — اقتراحات
    _add(_Msg(false,
        isAr ? 'لم أفهم السؤال تماماً 🤔 لكن يمكنني مساعدتك في الفنادق والسيارات والرحلات وخطط السفر. اختر من الأزرار أو اسألني مباشرة.'
             : 'I did not fully get that 🤔 But I can help with hotels, cars, tours and trip plans. Pick a button or ask directly.',
        actions: _quickActions()));
  }

  bool _has(String q, List<String> keys) => keys.any(q.contains);

  String? _detectProvince(String q) {
    for (final entry in kProvinceAliases.entries) {
      if (entry.value.any(q.contains)) return entry.key;
    }
    return null;
  }

  // ==================== ردود ذكية ببيانات التطبيق ====================
  _Msg _provinceInfo(String pid) {
    final l = context.l;
    final isAr = l.isArabic;
    final prov = kProvinces.firstWhere((p) => p.id == pid);
    final hotels = getAllHotels().where((h) => h.provinceId == pid).toList();
    final places = placesInProvince(pid);
    final status = switch (prov.status) {
      Availability.available => isAr ? 'متاح للحجز' : 'available for booking',
      Availability.limited => isAr ? 'توفر محدود' : 'limited availability',
      Availability.comingSoon => isAr ? 'قريباً' : 'coming soon',
      Availability.unavailable => isAr ? 'غير متوفر حالياً' : 'currently unavailable',
    };
    final km = pid == 'sanaa' ? 0.0 : distanceKm('sanaa', pid);
    final distLine = pid == 'sanaa'
        ? ''
        : '\n${isAr ? 'المسافة تقريباً من صنعاء' : 'Approx. distance from Sanaa'}: ${km.toStringAsFixed(0)} ${l.t('km')} (~${l.duration(travelMinutes(km))})';

    final topPlace = places.isNotEmpty
        ? places.reduce((a, b) => a.rating > b.rating ? a : b)
        : null;
    final placeLine = topPlace == null
        ? ''
        : '\n${isAr ? 'أبرز معلم' : 'Top attraction'}: ${topPlace.name(isAr)} ⭐${topPlace.rating}';

    return _Msg(false,
        '📍 ${l.province(pid)} — $status.$distLine$placeLine\n${hotels.isEmpty ? (isAr ? 'لا توجد فنادق مسجلة بعد في هذه المحافظة.' : 'No hotels listed here yet.') : '${isAr ? 'لدينا' : 'We have'} ${hotels.length} ${isAr ? 'فندق' : 'hotel(s)'} ${isAr ? 'في هذه المحافظة بأبدأ من' : 'starting from'} ${l.money(_minHotelPrice(hotels))}.'}',
        actions: [
          if (hotels.isNotEmpty)
            _Action(Icons.hotel, l.t('hotels'), (_) => const DetailsScreen(
                service: ServiceType.hotel, targetId: 'list')),
          if (places.isNotEmpty)
            _Action(Icons.explore, l.t('bestPlaces'),
                (_) => BestPlacesScreen(initialProvince: pid)),
          _Action(Icons.event_note, l.t('planTrip'), (_) => const TripPlannerScreen()),
        ]);
  }

  double _minHotelPrice(List<Hotel> hotels) => hotels.isEmpty
      ? 0
      : hotels
          .map((h) => h.rooms.first.pricePerNightYer)
          .reduce((a, b) => a < b ? a : b);

  _Msg _cheapestHotel() {
    final l = context.l;
    final isAr = l.isArabic;
    final all = getAllHotels().toList()
      ..sort((a, b) => a.rooms.first.pricePerNightYer
          .compareTo(b.rooms.first.pricePerNightYer));
    final h = all.first;
    final room = h.rooms.first;
    return _Msg(false,
        isAr
            ? 'أرخص غرفة متوفرة الآن 🏨: «${room.name}» في ${h.name} — ${l.province(h.provinceId)} — ${l.money(room.pricePerNightYer)} لليلة ⭐${h.rating}'
            : 'Cheapest available room 🏨: "${room.name}" at ${h.name} — ${l.province(h.provinceId)} — ${l.money(room.pricePerNightYer)} per night ⭐${h.rating}',
        actions: [
          _Action(Icons.visibility, l.t('bookNow'),
              (_) => DetailsScreen(service: ServiceType.hotel, targetId: h.id)),
          _Action(Icons.hotel, l.t('hotels'),
              (_) => const DetailsScreen(service: ServiceType.hotel, targetId: 'list')),
        ]);
  }

  _Msg _bestHotel() {
    final l = context.l;
    final isAr = l.isArabic;
    final all = getAllHotels().toList()..sort((a, b) => b.rating.compareTo(a.rating));
    final h = all.first;
    return _Msg(false,
        isAr
            ? 'الأعلى تقييماً حالياً 🌟: ${h.name} — ${l.province(h.provinceId)} — ⭐${h.rating} من ${h.reviewsCount} ${isAr ? 'تقييم' : 'reviews'} — من ${l.money(h.rooms.first.pricePerNightYer)} لليلة'
            : 'Highest rated right now 🌟: ${h.name} — ${l.province(h.provinceId)} — ⭐${h.rating} from ${h.reviewsCount} reviews — from ${l.money(h.rooms.first.pricePerNightYer)} per night',
        actions: [
          _Action(Icons.visibility, l.t('bookNow'),
              (_) => DetailsScreen(service: ServiceType.hotel, targetId: h.id)),
        ]);
  }

  _Msg _toursReply() {
    final l = context.l;
    final isAr = l.isArabic;
    final lines = kTours
        .map((t) => '• ${t.name} — ${t.days} ${l.t('days')} — ${l.money(t.priceYer)}')
        .join('\n');
    return _Msg(false,
        isAr
            ? 'هذه رحلاتنا الجاهزة الأكثر طلباً 🧭:\n$lines\n\nأو صمم خطتك الخاصة حسب ميزانيتك:'
            : 'Our most requested tours 🧭:\n$lines\n\nOr build your own plan:',
        actions: [
          _Action(Icons.map, l.t('tours'),
              (_) => const DetailsScreen(service: ServiceType.tour, targetId: 'list')),
          _Action(Icons.event_note, l.t('planTrip'), (_) => const TripPlannerScreen()),
        ]);
  }

  _Msg _pricesSummary() {
    final l = context.l;
    final isAr = l.isArabic;
    final all = getAllHotels().toList()
      ..sort((a, b) => a.rooms.first.pricePerNightYer
          .compareTo(b.rooms.first.pricePerNightYer));
    final minP = all.first.rooms.first.pricePerNightYer;
    final minCar = kCars
        .map((c) => c.pricePerDayYer)
        .reduce((a, b) => a < b ? a : b);
    final minTour = kTours.map((t) => t.priceYer).reduce((a, b) => a < b ? a : b);
    return _Msg(false,
        isAr
            ? 'ملخص الأسعار التقديرية 💰:\n• الغرف تبدأ من ${l.money(minP)} لليلة\n• السيارات من ${l.money(minCar)} لليوم\n• الرحلات الجاهزة من ${l.money(minTour)}\n\nالأسعار تجريبية وتتحدد النهائية عند الحجز.'
            : 'Estimated price summary 💰:\n• Rooms from ${l.money(minP)} / night\n• Cars from ${l.money(minCar)} / day\n• Ready tours from ${l.money(minTour)}\n\nPrices are demo estimates; final price at booking.',
        actions: [
          _Action(Icons.hotel, l.t('hotels'),
              (_) => const DetailsScreen(service: ServiceType.hotel, targetId: 'list')),
          _Action(Icons.directions_car, l.t('rentCar'),
              (_) => const DetailsScreen(service: ServiceType.rentCar, targetId: 'list')),
        ]);
  }

  // ==================== الواجهة ====================
  @override
  Widget build(BuildContext context) {
    final l = context.l;

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              gradient: TravixoFX.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.t('aiAssistant'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
            Row(children: [
              Container(width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: TIColors.success, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(l.t('assistantOnline'),
                  style: const TextStyle(
                      fontSize: 10, color: TIColors.success)),
            ]),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(14),
            itemCount: _msgs.length + (_typing ? 1 : 0),
            itemBuilder: (_, i) {
              if (_typing && i == _msgs.length) return _typingBubble();
              return _bubble(_msgs[i]);
            },
          ),
        ),

        // ===== شريط الإدخال =====
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).dividerColor.withOpacity(.4))),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: l.t('assistantPlaceholder'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: TravixoFX.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _typingBubble() => Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(.4)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _dot(), const SizedBox(width: 4), _dot(), const SizedBox(width: 4), _dot(),
          ]),
        ),
      );

  Widget _dot() => Container(
        width: 7,
        height: 7,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: TIColors.orange.withOpacity(.85),
          shape: BoxShape.circle,
        ),
      );

  Widget _bubble(_Msg m) {
    if (m.me) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .78),
          decoration: const BoxDecoration(
            gradient: TravixoFX.orange,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(m.text,
              style: const TextStyle(color: Colors.white, fontSize: 13.5,
                  height: 1.45)),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * .82),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(.4)),
          ),
          child: Text(m.text,
              style: const TextStyle(fontSize: 13.5, height: 1.5)),
        ),
      ),
      if (m.actions.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: m.actions
                .map((a) => ActionChip(
                      backgroundColor: TIColors.orangeSoft,
                      avatar: Icon(a.icon, size: 15, color: TIColors.orangeDeep),
                      label: Text(a.label,
                          style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: TIColors.orangeDeep)),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (c) => a.screen(c))),
                    ))
                .toList(),
          ),
        ),
    ]);
  }
}
