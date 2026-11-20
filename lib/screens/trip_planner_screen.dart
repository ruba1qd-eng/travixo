// ============================================================
//  Travixo — صمم خطتك (مخطط الرحلات الذكي)
//  الملف: lib/screens/trip_planner_screen.dart
//  الخطوة 4هـ: توليد برنامج رحلة يومي كامل حسب:
//  المحافظة + عدد الأيام + عدد المسافرين + الميزانية + الاهتمامات
//  يبني الخطة من بيانات التطبيق: الفنادق، السيارات، الأماكن، الرحلات
//  ويحسب التكلفة التقديرية (الليالي × سعر الغرفة + النقل + الطعام)
// ============================================================

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../data/places_data.dart';
import '../data/real_hotels_data.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'details_screens.dart';
import 'transport_booking_screen.dart';

class _DayItem {
  final IconData icon;
  final String title, details;
  const _DayItem(this.icon, this.title, this.details);
}

class _TripPlan {
  final Hotel? hotel;
  final HotelRoom? room;
  final Car? car;
  final Tour? tour;
  final List<_DayItem> days;
  final double hotelCostYer, transportCostYer, foodCostYer, totalYer;
  const _TripPlan({
    this.hotel,
    this.room,
    this.car,
    this.tour,
    required this.days,
    required this.hotelCostYer,
    required this.transportCostYer,
    required this.foodCostYer,
    required this.totalYer,
  });
}

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});
  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  String _province = 'sanaa';
  int _days = 3;
  int _travelers = 2;
  String _budget = 'mid'; // eco | mid | lux
  final Set<String> _interests = {'culture'};
  _TripPlan? _plan;
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  static const List<String> _interestKeys = ['culture', 'beach', 'mountain', 'nature'];
  static const Map<String, double> _foodPerPersonPerDay = {
    'eco': 8000,
    'mid': 15000,
    'lux': 30000,
  };

  // أنشطة بديلة حسب الاهتمامات عندما تنتهي قائمة الأماكن
  static const Map<String, Map<String, List<String>>> _fillers = {
    'ar': {
      'culture': ['زيارة المتحف والأسواق التراثية', 'جولة في الحي القديم والمعالم التاريخية'],
      'beach': ['عصر حر على الشاطئ مع عشاء مأكولات بحرية', 'جولة بحرية ورفوف للتصوير'],
      'mountain': ['جولة جبلية لمشاهدة الغروب', 'نزهة في المرتفعات وضيافة محلية'],
      'market': ['التسوق في السوق الشعبي', 'تذوق الحلويات والأكلات المحلية'],
      'nature': ['رحلة طبيعة وتصوير المناظر', 'نزهة بين المزارع والمدرجات الزراعية'],
    },
    'en': {
      'culture': ['Museum & heritage souq visit', 'Old town and landmarks walk'],
      'beach': ['Free afternoon at the beach + seafood dinner', 'Boat trip and photo stops'],
      'mountain': ['Sunset mountain excursion', 'Highlands picnic with local snacks'],
      'market': ['Local souq shopping', 'Local sweets & food tasting'],
      'nature': ['Nature trip and landscape photography', 'Walk through farms and terraces'],
    },
  };

  // ==================== بناء الخطة ====================
  _TripPlan _buildPlan() {
    final isAr = context.l.isArabic;

    // --- الفندق حسب الميزانية ---
    final hotels = getAllHotels().where((h) => h.provinceId == _province).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    Hotel? hotel = hotels.isNotEmpty ? hotels.first : null;
    HotelRoom? room;
    double hotelCost = 0;
    if (hotel != null) {
      final rooms = hotel.rooms.where((r) => r.available).toList()
        ..sort((a, b) => a.pricePerNightYer.compareTo(b.pricePerNightYer));
      if (rooms.isNotEmpty) {
        room = switch (_budget) {
          'eco' => rooms.first,
          'lux' => rooms.last,
          _ => rooms[rooms.length ~/ 2],
        };
        final nights = (_days - 1).clamp(1, 7);
        hotelCost = room.pricePerNightYer * nights;
      }
    }

    // --- السيارة حسب الميزانية ---
    final cars = kCars.where((c) => c.withDriver).toList()
      ..sort((a, b) => a.pricePerDayYer.compareTo(b.pricePerDayYer));
    Car? car = switch (_budget) {
      'eco' => cars.first,
      'lux' => cars.last,
      _ => cars[cars.length ~/ 2],
    };
    final transportCost = car.pricePerDayYer * _days;

    // --- برنامج الأيام ---
    final places = placesInProvince(_province).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final tour = kTours.where((t) => t.provinceId == _province).firstOrNull;
    int placeIdx = 0;
    int fillerIdx = 0;
    final List<String> interestPool = _interests.isEmpty
        ? ['culture', 'nature']
        : _interests.toList();

    String nextPlace() => placeIdx < places.length
        ? places[placeIdx++].name(isAr)
        : '';

    String nextFiller() {
      final cat = interestPool[fillerIdx % interestPool.length];
      final list = _fillers[isAr ? 'ar' : 'en']![cat]!;
      final text = list[(fillerIdx ~/ interestPool.length) % list.length];
      fillerIdx++;
      return text;
    }

    final items = <_DayItem>[];
    for (int d = 1; d <= _days; d++) {
      if (d == 1) {
        final first = nextPlace();
        items.add(_DayItem(
          Icons.flight_land,
          isAr ? 'اليوم 1 — الوصول والاستقرار' : 'Day 1 — Arrival & check-in',
          '${isAr ? 'استقبال من النقل/المطار ← تسجيل الوصول في' : 'Pickup from airport/transport ← check-in at'} ${hotel?.name ?? (isAr ? 'الفندق المقترح' : 'suggested hotel')}'
              ' ← ${first.isNotEmpty ? first : nextFiller()}',
        ));
      } else if (d == _days) {
        items.add(_DayItem(
          Icons.flight_takeoff,
          isAr ? 'اليوم $_days — المغادرة' : 'Day $_days — Departure',
          isAr
              ? 'إفطار في الفندق ← التسوق لشراء التذكارات ← تسجيل الخروج ← النقل إلى المطار أو نقطة الانطلاق'
              : 'Hotel breakfast ← souvenir shopping ← check-out ← transfer to airport or departure point',
        ));
      } else if (tour != null && d - 1 < tour.plan.length) {
        final td = tour.plan[d - 1];
        items.add(_DayItem(
          Icons.tour,
          '${isAr ? 'اليوم' : 'Day'} $d — ${td.title}',
          td.details,
        ));
      } else {
        final a = nextPlace();
        final b = nextPlace();
        items.add(_DayItem(
          Icons.explore,
          '${isAr ? 'اليوم' : 'Day'} $d — ${isAr ? 'استكشاف' : 'Exploration'}',
          '${a.isNotEmpty ? a : nextFiller()} ← ${b.isNotEmpty ? b : nextFiller()}',
        ));
      }
    }

    // --- التكاليف ---
    final foodCost = _foodPerPersonPerDay[_budget]! * _days * _travelers;
    final total = hotelCost + transportCost + foodCost;

    return _TripPlan(
      hotel: hotel,
      room: room,
      car: car,
      tour: tour,
      days: items,
      hotelCostYer: hotelCost,
      transportCostYer: transportCost,
      foodCostYer: foodCost,
      totalYer: total,
    );
  }

  void _generate() {
    setState(() => _plan = _buildPlan());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOut);
      }
    });
  }

  // ==================== الواجهة ====================
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isAr = l.isArabic;

    return Scaffold(
      appBar: AppBar(title: Text(l.t('planTrip'))),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(16),
        children: [
          // ===== ترويسة =====
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: TravixoFX.orange,
              borderRadius: BorderRadius.circular(TIRadius.l),
              boxShadow: [TravixoFX.shadow(TIColors.orangeDeep)],
            ),
            child: Row(children: [
              const Icon(Icons.event_note, color: Colors.white, size: 34),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.t('planTripTitle'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900)),
                      const SizedBox(height: 3),
                      Text(l.t('planTripSubtitle'),
                          style: TextStyle(
                              color: Colors.white.withOpacity(.9),
                              fontSize: 12,
                              height: 1.4)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // ===== النموذج =====
          _formCard(context, isAr),
          const SizedBox(height: 14),
          FilledButton.icon(
            icon: const Icon(Icons.auto_fix_high),
            label: Text(l.t('generatePlan')),
            onPressed: _generate,
          ),
          const SizedBox(height: 20),

          // ===== الخطة المولدة =====
          if (_plan != null) ..._planWidgets(context, _plan!, isAr),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _formCard(BuildContext context, bool isAr) {
    final l = context.l;
    final provinces = kProvinces
        .where((p) =>
            p.status == Availability.available ||
            p.status == Availability.limited)
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(TIRadius.l),
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(.4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // --- المحافظة ---
        Text(l.t('destination'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _province,
          isExpanded: true,
          decoration: const InputDecoration(
              prefixIcon: Icon(Icons.location_on_outlined)),
          items: [
            for (final p in provinces)
              DropdownMenuItem(value: p.id, child: Text(l.province(p.id))),
          ],
          onChanged: (v) => setState(() => _province = v ?? _province),
        ),
        const SizedBox(height: 14),

        // --- الأيام ---
        Row(children: [
          Text('${l.t('days')}: $_days',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          const Icon(Icons.date_range, size: 16, color: TIColors.orange),
        ]),
        Slider(
          value: _days.toDouble(),
          min: 1,
          max: 7,
          divisions: 6,
          activeColor: TIColors.orange,
          label: '$_days',
          onChanged: (v) => setState(() => _days = v.round()),
        ),

        // --- المسافرون ---
        Row(children: [
          Text('${l.t('guests')}: $_travelers',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _travelers = (_travelers - 1).clamp(1, 8)),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: TIColors.orangeSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.remove, size: 16, color: TIColors.orangeDeep),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => setState(() => _travelers = (_travelers + 1).clamp(1, 8)),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: TIColors.orangeSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 16, color: TIColors.orangeDeep),
            ),
          ),
        ]),
        const SizedBox(height: 14),

        // --- الميزانية ---
        Text(l.t('budget'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(child: _budgetChip(context, 'eco', l.t('budgetEco'))),
          const SizedBox(width: 8),
          Expanded(child: _budgetChip(context, 'mid', l.t('budgetMid'))),
          const SizedBox(width: 8),
          Expanded(child: _budgetChip(context, 'lux', l.t('budgetLux'))),
        ]),
        const SizedBox(height: 14),

        // --- الاهتمامات ---
        Text(l.t('interests'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in _interestKeys)
              FilterChip(
                selected: _interests.contains(c),
                selectedColor: TIColors.orange,
                checkmarkColor: Colors.white,
                backgroundColor: Theme.of(context).brightness == Brightness.light
                    ? TIColors.softGray
                    : TIColors.darkCard,
                label: Text(placeCategoryLabel(c, isAr),
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _interests.contains(c)
                            ? Colors.white
                            : null)),
                onSelected: (on) => setState(() {
                  on ? _interests.add(c) : _interests.remove(c);
                  if (_interests.isEmpty) _interests.add('culture');
                }),
              ),
          ],
        ),
      ]),
    );
  }

  Widget _budgetChip(BuildContext context, String value, String label) {
    final selected = _budget == value;
    return GestureDetector(
      onTap: () => setState(() => _budget = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? TIColors.orange : TIColors.orangeSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? TIColors.orangeDeep : Colors.transparent),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: selected
                      ? Colors.white
                      : TIColors.orangeDeep)),
        ),
      ),
    );
  }

  // ==================== بطاقات الخطة ====================
  List<Widget> _planWidgets(BuildContext context, _TripPlan plan, bool isAr) {
    final l = context.l;

    return [
      // --- الفندق المقترح ---
      if (plan.hotel != null && plan.room != null)
        _resultCard(
          context,
          icon: Icons.hotel,
          color: TIColors.cardHotels,
          title: l.t('hotelSuggestion'),
          lines: [
            plan.hotel!.name,
            '${plan.room!.name} — ${l.money(plan.room!.pricePerNightYer)} ${l.t('perNight')}',
            '⭐ ${plan.hotel!.rating} · ${l.province(plan.hotel!.provinceId)}',
          ],
          actionLabel: l.t('bookNow'),
          onAction: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailsScreen(
                  service: ServiceType.hotel, targetId: plan.hotel!.id))),
        ),

      // --- التنقل المقترح ---
      _resultCard(
        context,
        icon: Icons.directions_car,
        color: TIColors.cardRent,
        title: l.t('transportSuggestion'),
        lines: [
          '${plan.car!.name} — ${l.carCat(plan.car!.categoryId)}',
          '${l.money(plan.car!.pricePerDayYer)} ${l.t('perDay')} · ${plan.car!.seats} ${l.t('seats')}',
        ],
        actionLabel: l.t('bookNow'),
        onAction: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const TransportBookingScreen())),
      ),

      // --- رحلة جاهزة إن وجدت ---
      if (plan.tour != null)
        _resultCard(
          context,
          icon: Icons.tour,
          color: TIColors.cardTrips,
          title: l.t('tourAvailable'),
          lines: [
            plan.tour!.name,
            '${plan.tour!.days} ${l.t('days')} — ${l.money(plan.tour!.priceYer)}',
          ],
          actionLabel: l.t('viewTrip'),
          onAction: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => DetailsScreen(
                  service: ServiceType.tour, targetId: plan.tour!.id))),
        ),

      const SizedBox(height: 6),

      // --- البرنامج اليومي ---
      _sectionCard(context, l.t('dayPlan'), [
        for (int i = 0; i < plan.days.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Column(children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    gradient: TravixoFX.orange,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(plan.days[i].icon,
                      color: Colors.white, size: 17),
                ),
                if (i < plan.days.length - 1)
                  Container(width: 2, height: 26, color: TIColors.orangeSoft),
              ]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(plan.days[i].title,
                          style: const TextStyle(
                              fontSize: 13.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(plan.days[i].details,
                          style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: Theme.of(context).hintColor)),
                    ]),
              ),
            ]),
          ),
      ]),

      const SizedBox(height: 6),

      // --- التكلفة التقديرية ---
      _sectionCard(context, l.t('estimatedCost'), [
        _costRow(context, l.t('hotelSuggestion'), l.money(plan.hotelCostYer)),
        _costRow(context, l.t('transportSuggestion'), l.money(plan.transportCostYer)),
        _costRow(context, l.t('foodEstimate'), l.money(plan.foodCostYer)),
        const Divider(height: 18),
        Row(children: [
          Text(l.t('total'),
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900)),
          const Spacer(),
          Text(l.money(plan.totalYer),
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: TIColors.orangeDeep)),
        ]),
        const SizedBox(height: 8),
        Text(l.t('plannerNote'),
            style: const TextStyle(
                fontSize: 11, color: TIColors.lightSub, height: 1.5)),
      ]),
      const SizedBox(height: 12),
    ];
  }

  Widget _resultCard(BuildContext context,
      {required IconData icon,
      required Color color,
      required String title,
      required List<String> lines,
      required String actionLabel,
      required VoidCallback onAction}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(TIRadius.l),
        border: Border.all(color: color.withOpacity(.35), width: 1.4),
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color)),
                const SizedBox(height: 3),
                for (final line in lines)
                  Text(line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: onAction,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(actionLabel,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
    );
  }

  Widget _sectionCard(BuildContext context, String title, List<Widget> children) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(TIRadius.l),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          ...children,
        ]),
      );

  Widget _costRow(BuildContext context, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize: 13, color: Theme.of(context).hintColor)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w800)),
        ]),
      );
}
