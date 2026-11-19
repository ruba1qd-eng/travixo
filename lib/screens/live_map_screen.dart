// ============================================================
//  Travixo — الخريطة الحية
//  الملف: lib/screens/live_map_screen.dart
//  الخطوة 4ب: خريطة توضيحية لليمن بدون أي مكتبة خارجية
//  - إحداثيات المحافظات من kProvinceCoords (demo_data.dart)
//  - لون الدبوس حسب حالة التوفر (متاح / محدود / قريباً / غير متوفر)
//  - اضغط أي محافظة → لوحة سفلية بالفنادق والأماكن المميزة
//  ملاحظة: سقطرى جزيرة بعيدة فتُعرض كبطاقة مستقلة أسفل الخريطة
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

class LiveMapScreen extends StatelessWidget {
  const LiveMapScreen({super.key});

  // حدود الخريطة — الجزء الرئيسي من اليمن (بدون سقطرى)
  static const double _minLat = 12.4, _maxLat = 17.3;
  static const double _minLng = 42.3, _maxLng = 50.7;

  // طرق رئيسية توضيحية بين المدن الكبرى (تُرسم بخطوط متقطعة)
  static const List<List<String>> _routes = [
    ['sanaa', 'aden'],
    ['sanaa', 'hodeidah'],
    ['sanaa', 'marib'],
    ['marib', 'hadramout'],
    ['taiz', 'aden'],
    ['sanaa', 'taiz'],
  ];

  /// إسقاط إحداثية إلى نسبة من مساحة الخريطة (0..1)
  static double _fx(double lng) =>
      ((lng - _minLng) / (_maxLng - _minLng)).clamp(0.05, 0.95).toDouble();
  static double _fy(double lat) =>
      (1 - (lat - _minLat) / (_maxLat - _minLat)).clamp(0.06, 0.94).toDouble();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isAr = l.isArabic;
    final mainland =
        kProvinces.where((p) => p.id != 'socotra').toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('liveMap'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== مفتاح الخريطة =====
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(TIRadius.m),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(.4)),
            ),
            child: Wrap(
              spacing: 14,
              runSpacing: 6,
              children: [
                _legend(context, TIColors.success, l.t('available')),
                _legend(context, TIColors.warning, l.t('limited')),
                _legend(context, TIColors.teal, l.t('comingSoon')),
                _legend(context, TIColors.danger, l.t('unavailable')),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ===== الخريطة =====
          AspectRatio(
            aspectRatio: 1.75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TIRadius.l),
              child: Container(
                color: Theme.of(context).cardColor,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 3,
                  child: LayoutBuilder(builder: (context, box) {
                    final w = box.maxWidth, h = box.maxHeight;
                    return Stack(children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _MapPainter(
                            context: context,
                            routes: _routes
                                .map((r) => r
                                    .map((id) => Offset(
                                        _fx(kProvinceCoords[id]![1]),
                                        _fy(kProvinceCoords[id]![0])))
                                    .toList())
                                .toList(),
                          ),
                        ),
                      ),
                      for (final p in mainland) _pin(context, p, w, h, isAr),
                    ]);
                  }),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(l.t('mapApproxNote'),
              style: TextStyle(
                  fontSize: 10.5, color: Theme.of(context).hintColor),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),

          // ===== سقطرى — بطاقة مستقلة (بعيدة عن الحدود الرئيسية) =====
          _socotraCard(context, isAr),
          const SizedBox(height: 16),

          // ===== ملخص سريع =====
          _sectionTitle(context, l.t('hotels')),
          const SizedBox(height: 8),
          ...getAllHotels().where((h) => h.rating >= 4.5).take(4).map(
                (h) => _hotelRow(context, h),
              ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _legend(BuildContext context, Color color, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      );

  Widget _sectionTitle(BuildContext context, String title) => Text(title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));

  // ==================== دبوس المحافظة ====================
  Widget _pin(BuildContext context, Province p, double w, double h, bool isAr) {
    final l = context.l;
    final c = kProvinceCoords[p.id]!;
    final color = switch (p.status) {
      Availability.available => TIColors.success,
      Availability.limited => TIColors.warning,
      Availability.comingSoon => TIColors.teal,
      Availability.unavailable => TIColors.danger,
    };
    final hotelsCount =
        getAllHotels().where((x) => x.provinceId == p.id).length;
    final left = _fx(c[1]) * w - 26;
    final top = _fy(c[0]) * h - 16;

    return Positioned(
      left: left,
      top: top,
      width: 52,
      child: GestureDetector(
        onTap: () => _openProvince(context, p),
        child: Column(children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                    color: color.withOpacity(.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Center(
              child: Text('$hotelsCount',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(.5)),
            ),
            child: Text(
              l.province(p.id),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      ),
    );
  }

  // ==================== لوحة المحافظة السفلية ====================
  void _openProvince(BuildContext context, Province p) {
    final l = context.l;
    final isAr = l.isArabic;
    final color = switch (p.status) {
      Availability.available => TIColors.success,
      Availability.limited => TIColors.warning,
      Availability.comingSoon => TIColors.teal,
      Availability.unavailable => TIColors.danger,
    };
    final hotels =
        getAllHotels().where((x) => x.provinceId == p.id).toList();
    final places = placesInProvince(p.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TIRadius.l)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment:
            CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: Text(l.province(p.id),
                  style: const TextStyle(
                      fontSize: 19, fontWeight: FontWeight.w900)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                switch (p.status) {
                  Availability.available => l.t('available'),
                  Availability.limited => l.t('limited'),
                  Availability.comingSoon => l.t('comingSoon'),
                  Availability.unavailable => l.t('unavailable'),
                },
                style: TextStyle(fontSize: 11, color: color, fontWeight:
                    FontWeight.w700),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Text('${hotels.length} ${l.t('hotels')} · ${places.length} ${l.t('bestPlaces')}',
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
          const SizedBox(height: 12),

          if (places.isNotEmpty) ...[
            Text(l.t('bestPlaces'),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: places
                  .take(4)
                  .map((pl) => Chip(
                        visualDensity: VisualDensity.compact,
                        avatar: pl.unesco
                            ? const Icon(Icons.workspace_premium,
                                size: 14, color: TIColors.gold)
                            : const Icon(Icons.place, size: 14),
                        label: Text(pl.name(isAr),
                            style: const TextStyle(fontSize: 11)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),
          ],

          if (hotels.isNotEmpty) ...[
            Text(l.t('hotels'),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            ...hotels.take(3).map((h) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(h.img(),
                        width: 46, height: 46, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                            width: 46,
                            height: 46,
                            color: TIColors.orangeSoft,
                            child: const Icon(Icons.hotel,
                                color: TIColors.orangeDeep, size: 20))),
                  ),
                  title: Text(h.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                  subtitle: Row(children: [
                    const Icon(Icons.star, size: 12, color: TIColors.gold),
                    const SizedBox(width: 3),
                    Text('${h.rating}',
                        style: const TextStyle(fontSize: 11)),
                  ]),
                  trailing: Text(l.money(h.rooms.first.pricePerNightYer),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: TIColors.orangeDeep)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DetailsScreen(
                            service: ServiceType.hotel, targetId: h.id)));
                  },
                )),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(l.t('soon'),
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
            ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: hotels.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const DetailsScreen(
                                service: ServiceType.hotel,
                                targetId: 'list')));
                      },
                child: Text(l.t('hotels'), maxLines: 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: places.isEmpty
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => BestPlacesScreen(
                                initialProvince: p.id)));
                      },
                child: Text(l.t('bestPlaces'), maxLines: 1),
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _socotraCard(BuildContext context, bool isAr) {
    final l = context.l;
    final p = kProvinces.firstWhere((x) => x.id == 'socotra');
    final places = placesInProvince('socotra');
    return GestureDetector(
      onTap: () => _openProvince(context, p),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: TravixoFX.soft(TIColors.cardMap),
          borderRadius: TIRadius.card,
          boxShadow: TravixoFX.shadow(TIColors.cardMap),
        ),
        child: Row(children: [
          const Icon(Icons.travel_explore, color: TIColors.onCard, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.province('socotra'),
                      style: const TextStyle(
                          color: TIColors.onCard,
                          fontWeight: FontWeight.w900,
                          fontSize: 15)),
                  Text('${places.length} ${l.t('bestPlaces')} · ${l.t('comingSoon')}',
                      style: TextStyle(
                          color: TIColors.onCard.withOpacity(.85),
                          fontSize: 11.5)),
                ]),
          ),
          const Icon(Icons.chevron_right, color: TIColors.onCard),
        ]),
      ),
    );
  }

  Widget _hotelRow(BuildContext context, Hotel h) {
    final l = context.l;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) =>
              DetailsScreen(service: ServiceType.hotel, targetId: h.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).dividerColor.withOpacity(.4)),
        ),
        child: Row(children: [
          const Icon(Icons.location_on, color: TIColors.gold, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(h.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          const Icon(Icons.star, size: 13, color: TIColors.gold),
          const SizedBox(width: 3),
          Text('${h.rating}',
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(l.money(h.rooms.first.pricePerNightYer),
              style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: TIColors.orangeDeep)),
        ]),
      ),
    );
  }
}

// ============================================================
// الرسام: شبكة الخريطة + الطرق المتقطعة بين المدن
// ============================================================
class _MapPainter extends CustomPainter {
  final BuildContext context;
  final List<List<Offset>> routes;
  _MapPainter({required this.context, required this.routes});

  @override
  void paint(Canvas canvas, Size size) {
    final theme = Theme.of(context);
    final line = theme.dividerColor.withOpacity(.55);

    // ==== الشبكة ====
    final grid = Paint()
      ..color = line
      ..strokeWidth = 0.8;
    const steps = 8;
    for (int i = 1; i < steps; i++) {
      final dx = size.width * i / steps;
      final dy = size.height * i / steps;
      canvas.drawLine(Offset(dx, 0), Offset(dx, size.height), grid);
      canvas.drawLine(Offset(0, dy), Offset(size.width, dy), grid);
    }

    // ==== الطرق المتقطعة ====
    final road = Paint()
      ..color = TIColors.orange.withOpacity(.5)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const dash = 7.0, gap = 5.0;
    for (final route in routes) {
      if (route.length < 2) continue;
      for (int i = 0; i < route.length - 1; i++) {
        final a = Offset(route[i].dx * size.width, route[i].dy * size.height);
        final b =
            Offset(route[i + 1].dx * size.width, route[i + 1].dy * size.height);
        _dashedLine(canvas, road, a, b, dash, gap);
      }
    }
  }

  void _dashedLine(Canvas canvas, Paint paint, Offset a, Offset b,
      double dash, double gap) {
    final dist = (b - a).distance;
    if (dist == 0) return;
    final dir = (b - a) / dist;
    double t = 0;
    while (t < dist) {
      final end = (t + dash).clamp(0.0, dist).toDouble();
      canvas.drawLine(a + dir * t, a + dir * end, paint);
      t = end + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => false;
}
