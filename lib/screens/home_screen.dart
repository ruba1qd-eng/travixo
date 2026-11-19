// ============================================================
//  Travixo — الشاشة الرئيسية الجديدة
//  الملف: lib/screens/home_screen.dart
//  الخطوة 3: إعادة تصميم بأسلوب البطاقات الملونة الثمانية
//  - عروض بتدرج Travixo البرتقالي + شارة الخصم
//  - خدمات سريعة (نقل مع سائق / نقل المطار)
//  - شبكة البطاقات الملونة: رحلات، تأجير، فنادق، صمم خطتك،
//    منتجات ومنتجعات، أفضل الأماكن، الخريطة الحية، المساعد الذكي
//  - نفس منطق التنقل القديم محفوظ + الشاشات الأربع الجديدة
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/demo_data.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'assistant_screen.dart';
import 'best_places_screen.dart';
import 'details_screens.dart';
import 'live_map_screen.dart';
import 'search_screen.dart';
import 'transport_booking_screen.dart';
import 'trip_planner_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 68,
        title: Row(children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: TIColors.orangeSoft,
            child: Text(
              user?.firstName.isNotEmpty == true
                  ? user!.firstName[0].toUpperCase()
                  : 'T',
              style: const TextStyle(
                  color: TIColors.orangeDeep, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${l.t('hello')} ${user?.fullName ?? ''}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis),
                if (user != null)
                  Text('${user.age} ${l.t('years')}',
                      style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ]),
        actions: [
          PopupMenuButton<String>(
            onSelected: state.setCurrency,
            icon: Text(state.currency,
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: TIColors.gold,
                    fontSize: 13)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'YER', child: Text('YER')),
              PopupMenuItem(value: 'USD', child: Text('USD')),
              PopupMenuItem(value: 'SAR', child: Text('SAR')),
            ],
          ),
          Stack(children: [
            IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none)),
            if (state.notifications.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: TIColors.danger, shape: BoxShape.circle),
                ),
              ),
          ]),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== البحث — يفتح شاشة البحث الشامل =====
          GestureDetector(
            onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(.4)),
              ),
              child: Row(children: [
                const Icon(Icons.search, color: TIColors.gold),
                const SizedBox(width: 10),
                Text(l.t('searchHint'),
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ===== العروض المميزة — تدرج Travixo =====
          _sectionHeader(l.t('featuredOffers')),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: PageView.builder(
              itemCount: kOffers.length,
              controller: PageController(viewportFraction: .88),
              itemBuilder: (_, i) {
                final o = kOffers[i];
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => DetailsScreen(
                          service: o.service, targetId: o.targetId))),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: TravixoFX.orange,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: TravixoFX.shadow(TIColors.orangeDeep),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(children: [
                          Expanded(
                            child: Text(o.title,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('-${o.discountPercent}%',
                                style: const TextStyle(
                                    color: TIColors.orangeDeep,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900)),
                          ),
                        ]),
                        const SizedBox(height: 6),
                        Text(o.subtitle,
                            style: TextStyle(
                                color: Colors.white.withOpacity(.85),
                                fontSize: 12)),
                        const SizedBox(height: 10),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: TIColors.orangeDeep,
                                minimumSize: const Size(0, 38),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                              ),
                              onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => DetailsScreen(
                                          service: o.service,
                                          targetId: o.targetId))),
                              child: Text(l.t('bookNow'))),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // ===== خدمات سريعة =====
          _sectionHeader(l.t('quickActions')),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: _quickCard(context, Icons.directions_car, l.t('localRide'),
                  TravixoFX.orange, () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const TransportBookingScreen()))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickCard(context, Icons.flight_takeoff, l.t('airport'),
                  TravixoFX.soft(TIColors.cardHotels),
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DetailsScreen(
                          service: ServiceType.airport,
                          targetId: 'list')))),
            ),
          ]),
          const SizedBox(height: 22),

          // ===== الخدمات — البطاقات الملونة الثمانية =====
          _sectionHeader(l.t('services')),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              _coloredCard(context, Icons.tour, l.t('tours'),
                  TIColors.cardTrips,
                  () => _openList(context, ServiceType.tour)),
              _coloredCard(context, Icons.car_rental, l.t('rentCar'),
                  TIColors.cardRent,
                  () => _openList(context, ServiceType.rentCar)),
              _coloredCard(context, Icons.hotel, l.t('hotels'),
                  TIColors.cardHotels,
                  () => _openList(context, ServiceType.hotel)),
              _coloredCard(context, Icons.event_note, l.t('planTrip'),
                  TIColors.cardPlans,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TripPlannerScreen()))),
              _coloredCard(context, Icons.storefront, l.t('resorts'),
                  TIColors.cardResorts,
                  () => _openList(context, ServiceType.package)),
              _coloredCard(context, Icons.explore, l.t('bestPlaces'),
                  TIColors.cardPlaces,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BestPlacesScreen()))),
              _coloredCard(context, Icons.location_on, l.t('liveMap'),
                  TIColors.cardMap,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LiveMapScreen()))),
              _coloredCard(context, Icons.auto_awesome, l.t('aiAssistant'),
                  TIColors.cardAssistant,
                  () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AssistantScreen()))),
            ],
          ),
          const SizedBox(height: 22),

          // ===== المحافظات =====
          _sectionHeader(l.t('provinces')),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: kProvinces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final p = kProvinces[i];
                final (color, label) = switch (p.status) {
                  Availability.available => (TIColors.success, l.t('available')),
                  Availability.limited => (TIColors.warning, l.t('limited')),
                  Availability.comingSoon => (TIColors.teal, l.t('comingSoon')),
                  Availability.unavailable => (TIColors.danger, l.t('unavailable')),
                };
                return Container(
                  width: 120,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(.4)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.province(p.id),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withOpacity(.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(label,
                            style: TextStyle(fontSize: 10, color: color)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 22),

          // ===== مقترح لك =====
          _sectionHeader(l.t('recommended')),
          const SizedBox(height: 10),
          ...kHotels.take(3).map((h) => GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DetailsScreen(
                        service: ServiceType.hotel, targetId: h.id))),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Theme.of(context).dividerColor.withOpacity(.4)),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                          hotelImg(h.provinceId, h.id.hashCode.abs()),
                          width: 74,
                          height: 74,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 74,
                              height: 74,
                              color: TIColors.orangeSoft,
                              child: const Icon(Icons.hotel,
                                  color: TIColors.orangeDeep))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text(l.province(h.provinceId),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).hintColor)),
                            const SizedBox(height: 6),
                            Row(children: [
                              const Icon(Icons.star,
                                  size: 15, color: TIColors.gold),
                              const SizedBox(width: 3),
                              Text('${h.rating}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700)),
                              if (!h.verified) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: TIColors.warning.withOpacity(.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(l.t('demoDataBadge'),
                                      style: const TextStyle(fontSize: 9)),
                                ),
                              ],
                            ]),
                          ]),
                    ),
                    Text(l.money(h.rooms.first.pricePerNightYer),
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: TIColors.orangeDeep)),
                  ]),
                ),
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _openList(BuildContext context, ServiceType type) =>
      Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => DetailsScreen(service: type, targetId: 'list')));

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      );

  // بطاقة خدمة سريعة عريضة
  Widget _quickCard(BuildContext context, IconData icon, String label,
      LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: TIRadius.card,
          boxShadow: TravixoFX.shadow(TIColors.orangeDeep),
        ),
        child: Row(children: [
          Icon(icon, color: TIColors.onCard, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: TIColors.onCard,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800)),
          ),
          const Icon(Icons.chevron_right, color: TIColors.onCard, size: 20),
        ]),
      ),
    );
  }

  // بطاقة ملونة من الثمانية
  Widget _coloredCard(BuildContext context, IconData icon, String label,
      Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: TravixoFX.soft(color),
          borderRadius: TIRadius.card,
          boxShadow: TravixoFX.shadow(color),
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.22),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: TIColors.onCard, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: TIColors.onCard,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.25)),
          ),
          const Icon(Icons.chevron_right,
              color: TIColors.onCard, size: 18),
        ]),
      ),
    );
  }
}
