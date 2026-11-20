// الخريطة الحية — Travixo Live Map
// خريطة OpenStreetMap حقيقية تفاعلية + بديل مرسوم يدوياً بدون إنترنت
// يحافظ على الأسماء التاريخية: TIColors, TIRadius, AppState, context.l, Haptics
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/demo_data.dart';
import '../data/real_hotels_data.dart';
import 'haptic.dart';
import 'package:provider/provider.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({Key? key}) : super(key: key);

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapCtrl = MapController();
  bool _offlineMode = false; // الوضع اليدوي كبديل بدون إنترنت

  // ====== الإحداثيات الحقيقية للمحافظات ======
  static const Map<String, LatLng> _provinceCoords = {
    'sanaa':     LatLng(15.3694, 44.1910),
    'aden':      LatLng(12.7855, 45.0187),
    'taiz':      LatLng(13.5795, 44.0216),
    'hadramaut': LatLng(15.5000, 48.5000),
    'hodeidah':  LatLng(14.7960, 42.9510),
    'ibb':       LatLng(13.9667, 44.1833),
    'dhmar':     LatLng(14.5550, 44.4060),
    'marib':     LatLng(15.4500, 45.3300),
    'lahj':      LatLng(13.0000, 44.9000),
    'hajjah':    LatLng(15.7000, 42.9000),
    'amran':     LatLng(15.6000, 43.9000),
    'saada':     LatLng(15.7000, 43.7000),
    'shabwah':   LatLng(15.3700, 46.3500),
    'abyan':     LatLng(13.1200, 45.6000),
  };

  // ====== لون الحالة — مطابق لشرائح الـ Legend ======
  Color _statusColor(Availability s) {
    switch (s) {
      case Availability.available:
        return TIColors.success;   // #2FA96E أخضر "متاح"
      case Availability.limited:
        return TIColors.warning;   // #F5A623 برتقالي "محدود"
      case Availability.unavailable:
        return TIColors.danger;    // #E5484D أحمر "غير متوفر"
      case Availability.comingSoon:
        return TIColors.teal;      // #14B8A6 "قريباً"
    }
  }

  // ====== عدد الفنادق الحقيقية لكل محافظة ======
  int _hotelCount(String provinceId) {
    int count = 0;
    for (final h in RealHotelsData.hotels) {
      if (h.provinceId == provinceId) count++;
    }
    return count;
  }

  // ====== فتح ورقة سفلية عند النقر على محافظة ======
  void _openProvinceSheet(Province p) {
    Haptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProvinceSheet(province: p, statusColor: _statusColor(p.status)),
    );
  }

  // ====== التكبير على محافظة ======
  void _focusProvince(Province p) {
    Haptics.light();
    final coords = _provinceCoords[p.id];
    if (coords != null) {
      _mapCtrl.move(coords, 9.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l.t('live_map'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        centerTitle: true,
        actions: [
          // زر التبديل بين الخريطة الحقيقية والوضع اليدوي
          IconButton(
            onPressed: () {
              Haptics.light();
              setState(() => _offlineMode = !_offlineMode);
            },
            tooltip: _offlineMode ? 'خريطة حقيقية' : 'وضع بدون إنترنت',
            icon: Icon(_offlineMode ? Icons.public : Icons.wifi_off),
          ),
        ],
      ),
      body: Column(
        children: [
          _legend(context),
          Expanded(
            child: _offlineMode ? _OfflineFallbackMap() : _buildRealMap(),
          ),
          _provinceChips(context),
        ],
      ),
    );
  }

  // ====== الخريطة الحقيقية — OpenStreetMap ======
  Widget _buildRealMap() {
    return FlutterMap(
      mapController: _mapCtrl,
      options: const MapOptions(
        initialCenter: LatLng(15.2, 47.5), // مركز اليمن
        initialZoom: 6.2,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travixo.travel_in_app',
          maxNativeZoom: 19,
          tileErrorBuilder: (context, error, tile) => const SizedBox.shrink(),
        ),
        // دوائر ملونة حسب حالة التوفر
        CircleLayer(
          circles: [
            for (final p in DemoData.provinces)
              if (_provinceCoords[p.id] != null)
                CircleMarker(
                  point: _provinceCoords[p.id]!,
                  radius: 16.0 + _hotelCount(p.id) * 2.5,
                  color: _statusColor(p.status).withOpacity(0.92),
                  borderColor: Colors.white,
                  borderStrokeWidth: 3.5,
                ),
          ],
        ),
        // علامات الأسماء والأعداد
        MarkerLayer(
          markers: [
            for (final p in DemoData.provinces)
              if (_provinceCoords[p.id] != null)
                Marker(
                  point: _provinceCoords[p.id]!,
                  width: 110,
                  height: 80,
                  child: GestureDetector(
                    onTap: () => _openProvinceSheet(p),
                    onLongPress: () => _focusProvince(p),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statusColor(p.status),
                            borderRadius: BorderRadius.circular(TIRadius.small),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            '${_hotelCount(p.id)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(TIRadius.small),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            p.name(context),
                            style: const TextStyle(
                              color: TIColors.navy,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ],
    );
  }

  // ====== الـ Legend — شرائح التوفر الأربع ======
  Widget _legend(BuildContext context) {
    final l = context.l;
    final items = [
      (TIColors.success, l.t('available')),
      (TIColors.warning, l.t('limited')),
      (TIColors.teal, l.t('coming_soon')),
      (TIColors.danger, l.t('unavailable')),
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: TIColors.lightCard,
        borderRadius: BorderRadius.circular(TIRadius.medium),
        boxShadow: [TravixoFX.shadow(TIColors.orange)],
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: items.map((e) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: e.$1,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                e.$2,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: TIColors.lightText,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ====== شرائح المحافظات السريعة ======
  Widget _provinceChips(BuildContext context) {
    final provinces = DemoData.provinces;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: provinces.length,
        itemBuilder: (ctx, i) {
          final p = provinces[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(p.name(context)),
              selected: false,
              onSelected: (_) {
                if (_offlineMode) {
                  _openProvinceSheet(p);
                } else {
                  _focusProvince(p);
                  _openProvinceSheet(p);
                }
              },
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              selectedColor: TIColors.orange,
              backgroundColor: TIColors.orangeSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(TIRadius.small),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================================================================
// الورقة السفلية لمحافظة — صورة + أقرب 3 فنادق + زر حجز
// ======================================================================
class _ProvinceSheet extends StatelessWidget {
  final Province province;
  final Color statusColor;

  const _ProvinceSheet({
    Key? key,
    required this.province,
    required this.statusColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final hotels = RealHotelsData.hotels
        .where((h) => h.provinceId == province.id)
        .take(3)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(TIRadius.sheet)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // مقبض السحب
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: TIColors.lightLine,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // الصورة الحقيقية للمحافظة
          ClipRRect(
            borderRadius: BorderRadius.circular(TIRadius.medium),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                province.img(),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: TIColors.orangeSoft,
                  child: const Icon(Icons.place, size: 60, color: TIColors.orange),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // الاسم + شارة الحالة
          Row(
            children: [
              Expanded(
                child: Text(
                  province.name(context),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: TIColors.lightText,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(TIRadius.small),
                ),
                child: Text(
                  _statusLabel(l),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // أقرب الفنادق
          Text(
            l.t('nearby_hotels'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: TIColors.lightText,
            ),
          ),
          const SizedBox(height: 12),

          if (hotels.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: TIColors.orangeSoft,
                borderRadius: BorderRadius.circular(TIRadius.medium),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: TIColors.orangeDeep),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l.t('no_hotels_yet'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: TIColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            ...hotels.map((h) => _hotelTile(context, h)),

          const SizedBox(height: 20),

          // زر الحجز
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Haptics.success();
                Navigator.pop(context);
              },
              child: Text(
                l.t('book_now'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l) {
    switch (province.status) {
      case Availability.available:
        return l.t('available');
      case Availability.limited:
        return l.t('limited');
      case Availability.comingSoon:
        return l.t('coming_soon');
      case Availability.unavailable:
        return l.t('unavailable');
    }
  }

  Widget _hotelTile(BuildContext context, Hotel h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TIColors.lightCard,
          borderRadius: BorderRadius.circular(TIRadius.medium),
          border: Border.all(color: TIColors.lightLine),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(TIRadius.small),
              child: SizedBox(
                width: 64,
                height: 64,
                child: Image.network(
                  h.img(),
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: TIColors.orangeSoft,
                    child: const Icon(Icons.hotel, color: TIColors.orange),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    h.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: TIColors.lightText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: TIColors.warning, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${h.rating} • ${h.reviewsCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: TIColors.lightSub,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${h.rooms.isNotEmpty ? h.rooms.first.pricePerNightYer : 0}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: TIColors.orangeDeep,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================================
// البديل بدون إنترنت — رسام خريطة مبسّط (نفس سلوك _MapPainter القديم)
// ======================================================================
class _OfflineFallbackMap extends StatelessWidget {
  const _OfflineFallbackMap({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TIColors.lightCard,
        borderRadius: BorderRadius.circular(TIRadius.medium),
      ),
      child: CustomPaint(
        painter: _MapPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = TIColors.lightLine
      ..strokeWidth = 1;

    final lineCount = 8;
    for (int i = 1; i < lineCount; i++) {
      final y = size.height * i / lineCount;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      final x = size.width * i / lineCount;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    final routePaint = Paint()
      ..color = TIColors.orange.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final route = Path();
    route.moveTo(size.width * 0.2, size.height * 0.7);
    route.lineTo(size.width * 0.4, size.height * 0.45);
    route.lineTo(size.width * 0.65, size.height * 0.5);
    route.lineTo(size.width * 0.85, size.height * 0.3);
    canvas.drawPath(route, routePaint);

    // نقاط المحافظات تقريياً
    for (final p in DemoData.provinces) {
      final dx = _relativeX(p.id) * size.width;
      final dy = _relativeY(p.id) * size.height;
      final color = _paintColor(p.status);

      canvas.drawCircle(Offset(dx, dy), 14, Paint()..color = color);
      canvas.drawCircle(
        Offset(dx, dy),
        14,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  Color _paintColor(Availability s) {
    switch (s) {
      case Availability.available:
        return TIColors.success;
      case Availability.limited:
        return TIColors.warning;
      case Availability.unavailable:
        return TIColors.danger;
      case Availability.comingSoon:
        return TIColors.teal;
    }
  }

  double _relativeX(String id) {
    const map = {
      'hajjah': 0.18, 'saada': 0.22, 'amran': 0.28, 'sanaa': 0.32,
      'hodeidah': 0.12, 'ibb': 0.35, 'taiz': 0.33, 'dhmar': 0.38,
      'lahj': 0.30, 'aden': 0.35, 'marib': 0.52, 'aljawf': 0.48,
      'shabwah': 0.62, 'hadramaut': 0.78, 'mahra': 0.92, 'abyan': 0.42,
      'hodeidah': 0.12, 'al_bayda': 0.50,
    };
    return map[id] ?? 0.5;
  }

  double _relativeY(String id) {
    const map = {
      'hajjah': 0.30, 'saada': 0.18, 'amran': 0.25, 'sanaa': 0.35,
      'hodeidah': 0.42, 'ibb': 0.55, 'taiz': 0.62, 'dhmar': 0.50,
      'lahj': 0.68, 'aden': 0.78, 'marib': 0.40, 'aljawf': 0.30,
      'shabwah': 0.48, 'hadramaut': 0.45, 'mahra': 0.30, 'abyan': 0.70,
      'al_bayda': 0.52,
    };
    return map[id] ?? 0.5;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
