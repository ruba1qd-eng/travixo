// ============================================================
//  Travixo — شاشة أفضل الأماكن
//  الملف: lib/screens/best_places_screen.dart
//  الخطوة 4ج: أجمل وجهات اليمن مع فلترة حسب النوع والمحافظة
//  البيانات من lib/data/places_data.dart
// ============================================================

import 'package:flutter/material.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../data/places_data.dart';
import '../data/real_hotels_data.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import 'details_screens.dart';
import 'live_map_screen.dart';

class BestPlacesScreen extends StatefulWidget {
  /// تُمرَّر من الخريطة الحية لعرض أماكن محافظة محددة مباشرة
  final String? initialProvince;
  const BestPlacesScreen({super.key, this.initialProvince});

  @override
  State<BestPlacesScreen> createState() => _BestPlacesScreenState();
}

class _BestPlacesScreenState extends State<BestPlacesScreen> {
  String? _province; // null = كل المحافظات
  String? _cat; // null = كل الأنواع

  @override
  void initState() {
    super.initState();
    _province = widget.initialProvince;
  }

  static const List<String> _cats = ['culture', 'beach', 'mountain', 'nature'];

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final isAr = l.isArabic;

    final items = kBestPlaces
        .where((p) => _province == null || p.provinceId == _province)
        .where((p) => _cat == null || p.category == _cat)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l.t('bestPlaces'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== فلتر المحافظات (يظهر فقط عند فتح الشاشة عامة) =====
          if (widget.initialProvince == null)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _chip(context, null, l.t('all')),
                  for (final id in kProvinces
                      .map((p) => p.id)
                      .where((id) => placesInProvince(id).isNotEmpty))
                    _chip(context, id, l.province(id)),
                ],
              ),
            ),
          if (widget.initialProvince == null) const SizedBox(height: 10),

          // ===== فلتر الأنواع =====
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final c in _cats)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(placeCategoryLabel(c, isAr),
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _cat == c ? Colors.white : null)),
                      selected: _cat == c,
                      selectedColor: TIColors.orange,
                      backgroundColor: Theme.of(context).cardColor,
                      onSelected: (_) => setState(() => _cat = _cat == c ? null : c),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ===== النتائج =====
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: Text(l.t('noResults'),
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ),
            )
          else
            ...items.map((p) => _placeCard(context, p, isAr)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String? id, String label) {
    final selected = _province == id;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: ChoiceChip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : null)),
        selected: selected,
        selectedColor: TIColors.orange,
        backgroundColor: Theme.of(context).cardColor,
        onSelected: (_) => setState(() => _province = id),
      ),
    );
  }

  // ==================== بطاقة المكان ====================
  Widget _placeCard(BuildContext context, BestPlace p, bool isAr) {
    final l = context.l;
    final catColor = switch (p.category) {
      'culture' => TIColors.cardTrips,
      'beach' => TIColors.cardMap,
      'mountain' => TIColors.cardRent,
      _ => TIColors.cardPlaces,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(TIRadius.l),
        border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(.4)),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black.withOpacity(.05)
                : Colors.black.withOpacity(.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ==== الصورة + الشارات ====
        Stack(children: [
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Image.network(p.img(),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                    color: catColor.withOpacity(.2),
                    child: Icon(Icons.landscape,
                        color: catColor, size: 44))),
          ),
          PositionedDirectional(
            top: 10,
            start: 10,
            child: Row(children: [
              if (p.unesco)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: TIColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(children: [
                    const Icon(Icons.workspace_premium,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('UNESCO',
                        style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ]),
                ),
            ]),
          ),
          PositionedDirectional(
            top: 10,
            end: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                const Icon(Icons.star, size: 12, color: TIColors.gold),
                const SizedBox(width: 3),
                Text('${p.rating}',
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ]),
            ),
          ),
        ]),

        // ==== النصوص ====
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Text(p.name(isAr),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: catColor.withOpacity(.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(placeCategoryLabel(p.category, isAr),
                        style: TextStyle(
                            fontSize: 10, color: catColor,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 3),
                Row(children: [
                  const Icon(Icons.location_on, size: 13, color: TIColors.orange),
                  const SizedBox(width: 3),
                  Text(l.province(p.provinceId),
                      style: TextStyle(
                          fontSize: 12, color: Theme.of(context).hintColor)),
                ]),
                const SizedBox(height: 8),
                Text(p.desc(isAr),
                    style: TextStyle(
                        fontSize: 12.5,
                        height: 1.55,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withOpacity(.85)),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 12),

                // ==== الأزرار ====
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.map, size: 16),
                      label: Text(l.t('openMap'), maxLines: 1),
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const LiveMapScreen())),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.hotel, size: 16),
                      label: Text(l.t('hotelsNearby'), maxLines: 1),
                      onPressed: () => _openProvinceHotels(context, p),
                    ),
                  ),
                ]),
              ]),
        ),
      ]),
    );
  }

  // ==================== لوحة فنادق المحافظة ====================
  void _openProvinceHotels(BuildContext context, BestPlace p) {
    final l = context.l;
    final hotels =
        getAllHotels().where((h) => h.provinceId == p.provinceId).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(TIRadius.l)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          Text(
            '${l.t('hotels')} — ${l.province(p.provinceId)}',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          if (hotels.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l.t('soon'),
                  style: TextStyle(
                      fontSize: 13, color: Theme.of(context).hintColor)),
            )
          else
            ...hotels.take(5).map((h) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                        h.img(),
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
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
                  trailing: Text(
                      l.money(h.rooms.first.pricePerNightYer),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: TIColors.orangeDeep)),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DetailsScreen(
                            service: ServiceType.hotel,
                            targetId: h.id)));
                  },
                )),
        ]),
      ),
    );
  }
}
