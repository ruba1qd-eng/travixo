// الخريطة الحية — OpenStreetMap حقيقية + بديل مرسوم بدون إنترنت
import 'dart:ui' as ui;

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
  bool _offlineMode = false;

  static const Map<String, LatLng> _coords = {
    'sanaa': LatLng(15.3694, 44.1910),
    'aden': LatLng(12.7855, 45.0187),
    'taiz': LatLng(13.5795, 44.0216),
    'hadramout': LatLng(15.5000, 48.5000),
    'hodeidah': LatLng(14.7960, 42.9510),
    'ibb': LatLng(13.9667, 44.1833),
    'dhamar': LatLng(14.5550, 44.4060),
    'marib': LatLng(15.4500, 45.3300),
    'lahij': LatLng(13.0000, 44.9000),
    'hajjah': LatLng(15.7000, 42.9000),
    'amran': LatLng(15.6000, 43.9000),
    'sadah': LatLng(15.7000, 43.7000),
    'shabwa': LatLng(15.3700, 46.3500),
    'abyan': LatLng(13.1200, 45.6000),
    'socotra': LatLng(12.5500, 53.9500),
    'mahrah': LatLng(16.2000, 52.1500),
    'jawf': LatLng(16.1500, 45.1000),
    'bayda': LatLng(13.9500, 45.5500),
    'dhale': LatLng(13.6800, 44.7500),
    'rima': LatLng(14.6000, 43.6000),
  };

  Color _statusColor(Availability s) {
    switch (s) {
      case Availability.available: return TIColors.success;
      case Availability.limited: return TIColors.warning;
      case Availability.unavailable: return TIColors.danger;
      case Availability.comingSoon: return TIColors.teal;
    }
  }

  int _hotelCount(String pid) {
    int c = 0;
    for (final h in getAllHotels()) {
      if (h.provinceId == pid) c++;
    }
    return c;
  }

  void _openSheet(Province p) {
    Haptics.light();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProvinceSheet(province: p, color: _statusColor(p.status)),
    );
  }

  void _focus(Province p) {
    Haptics.light();
    final c = _coords[p.id];
    if (c != null) _mapCtrl.move(c, 9.5);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(l.t('liveMap'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Haptics.light();
              setState(() => _offlineMode = !_offlineMode);
            },
            icon: Icon(_offlineMode ? Icons.public : Icons.wifi_off),
          ),
        ],
      ),
      body: Column(
        children: [
          _legend(l),
          Expanded(child: _offlineMode ? _OfflineFallbackMap() : _realMap()),
          _chips(l),
        ],
      ),
    );
  }

  Widget _realMap() {
    return FlutterMap(
      mapController: _mapCtrl,
      options: const MapOptions(
        initialCenter: LatLng(15.2, 47.5),
        initialZoom: 6.2,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.travixo.travel_in_app',
        ),
        CircleLayer(circles: [
          for (final p in kProvinces)
            if (_coords[p.id] != null)
              CircleMarker(
                point: _coords[p.id]!,
                radius: 16.0 + _hotelCount(p.id) * 2.5,
                color: _statusColor(p.status).withOpacity(0.92),
                borderColor: Colors.white,
                borderStrokeWidth: 3.5,
              ),
        ]),
        MarkerLayer(markers: [
          for (final p in kProvinces)
            if (_coords[p.id] != null)
              Marker(
                point: _coords[p.id]!,
                width: 110,
                height: 80,
                child: GestureDetector(
                  onTap: () => _openSheet(p),
                  onLongPress: () => _focus(p),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statusColor(p.status),
                          borderRadius: BorderRadius.circular(TIRadius.small),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text('${_hotelCount(p.id)}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(TIRadius.small),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2))
                          ],
                        ),
                        child: Text(context.l.province(p.id),
                            style: const TextStyle(
                                color: TIColors.navy,
                                fontSize: 12,
                                fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),
        ]),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Text(
              '© OpenStreetMap contributors',
              style: TextStyle(
                fontSize: 9,
                color: Colors.black87,
                backgroundColor: Colors.white.withOpacity(.85),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _legend(AppLocalizations l) {
    final items = [
      (TIColors.success, l.t('available')),
      (TIColors.warning, l.t('limited')),
      (TIColors.teal, l.t('comingSoon')),
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
        children: items
            .map((e) => Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(color: e.$1, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(e.$2,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: TIColors.lightText)),
                ]))
            .toList(),
      ),
    );
  }

  Widget _chips(AppLocalizations l) {
    final ps = kProvinces;
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: ps.length,
        itemBuilder: (ctx, i) {
          final p = ps[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(l.province(p.id)),
              selected: false,
              onSelected: (_) {
                if (!_offlineMode) _focus(p);
                _openSheet(p);
              },
              labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              selectedColor: TIColors.orange,
              backgroundColor: TIColors.orangeSoft,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(TIRadius.small)),
            ),
          );
        },
      ),
    );
  }
}

class _ProvinceSheet extends StatelessWidget {
  final Province province;
  final Color color;
  const _ProvinceSheet({Key? key, required this.province, required this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final hotels = getAllHotels()
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
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                  color: TIColors.lightLine, borderRadius: BorderRadius.circular(3)),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(TIRadius.medium),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(province.img(),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      color: TIColors.orangeSoft,
                      child: const Icon(Icons.place, size: 60, color: TIColors.orange))),
            ),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: Text(l.province(province.id),
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: TIColors.lightText)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(TIRadius.small)),
              child: Text(_statusLabel(l),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
            ),
          ]),
          const SizedBox(height: 20),
          Text(l.t('hotelsNearby'),
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: TIColors.lightText)),
          const SizedBox(height: 12),
          if (hotels.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: TIColors.orangeSoft,
                  borderRadius: BorderRadius.circular(TIRadius.medium)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: TIColors.orangeDeep),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(l.t('soon'),
                        style: const TextStyle(fontSize: 14, color: TIColors.navy))),
              ]),
            )
          else
            ...hotels.map((h) => _tile(context, h)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                Haptics.success();
                Navigator.pop(context);
              },
              child: Text(l.t('bookNow'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppLocalizations l) {
    switch (province.status) {
      case Availability.available: return l.t('available');
      case Availability.limited: return l.t('limited');
      case Availability.comingSoon: return l.t('comingSoon');
      case Availability.unavailable: return l.t('unavailable');
    }
  }

  Widget _tile(BuildContext context, Hotel h) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: TIColors.lightCard,
          borderRadius: BorderRadius.circular(TIRadius.medium),
          border: Border.all(color: TIColors.lightLine),
        ),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(TIRadius.small),
            child: SizedBox(
              width: 64,
              height: 64,
              child: Image.network(h.img(),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      color: TIColors.orangeSoft,
                      child: const Icon(Icons.hotel, color: TIColors.orange))),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(h.name,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: TIColors.lightText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.star, color: TIColors.warning, size: 14),
                const SizedBox(width: 4),
                Text('${h.rating} • ${h.reviewsCount}',
                    style: const TextStyle(fontSize: 12, color: TIColors.lightSub)),
              ]),
            ]),
          ),
          const SizedBox(width: 8),
          Text(
            h.rooms.isNotEmpty ? '${h.rooms.first.pricePerNightYer}' : '0',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w900, color: TIColors.orangeDeep),
          ),
        ]),
      ),
    );
  }
}

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
      child: CustomPaint(painter: _MapPainter(), child: const SizedBox.expand()),
    );
  }
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = TIColors.lightLine
      ..strokeWidth = 1;
    for (int i = 1; i < 8; i++) {
      final y = size.height * i / 8;
      final x = size.width * i / 8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    final route = Paint()
      ..color = TIColors.orange.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final p = ui.Path();
    p.moveTo(size.width * 0.2, size.height * 0.7);
    p.lineTo(size.width * 0.4, size.height * 0.45);
    p.lineTo(size.width * 0.65, size.height * 0.5);
    p.lineTo(size.width * 0.85, size.height * 0.3);
    canvas.drawPath(p, route);
    for (final prov in kProvinces) {
      final dx = _rx(prov.id) * size.width;
      final dy = _ry(prov.id) * size.height;
      final c = _pc(prov.status);
      canvas.drawCircle(Offset(dx, dy), 14, Paint()..color = c);
      canvas.drawCircle(
          Offset(dx, dy), 14, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  Color _pc(Availability s) {
    switch (s) {
      case Availability.available: return TIColors.success;
      case Availability.limited: return TIColors.warning;
      case Availability.unavailable: return TIColors.danger;
      case Availability.comingSoon: return TIColors.teal;
    }
  }

  double _rx(String id) {
    const m = {
      'hajjah': 0.18, 'sadah': 0.22, 'amran': 0.28, 'sanaa': 0.32,
      'hodeidah': 0.12, 'ibb': 0.35, 'taiz': 0.33, 'dhamar': 0.38,
      'lahij': 0.30, 'aden': 0.35, 'marib': 0.52, 'jawf': 0.48,
      'shabwa': 0.62, 'hadramout': 0.78, 'mahrah': 0.92, 'abyan': 0.42,
      'bayda': 0.50, 'dhale': 0.45, 'rima': 0.25, 'socotra': 0.95,
    };
    return m[id] ?? 0.5;
  }

  double _ry(String id) {
    const m = {
      'hajjah': 0.30, 'sadah': 0.18, 'amran': 0.25, 'sanaa': 0.35,
      'hodeidah': 0.42, 'ibb': 0.55, 'taiz': 0.62, 'dhamar': 0.50,
      'lahij': 0.68, 'aden': 0.78, 'marib': 0.40, 'jawf': 0.30,
      'shabwa': 0.48, 'hadramout': 0.45, 'mahrah': 0.30, 'abyan': 0.70,
      'bayda': 0.52, 'dhale': 0.60, 'rima': 0.35, 'socotra': 0.85,
    };
    return m[id] ?? 0.5;
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
