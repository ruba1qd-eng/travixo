// الشاشة الرئيسية — Travixo Home Screen
// بطاقات أكبر وأوضح مثل تصميم Direct
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/demo_data.dart';
import '../data/real_hotels_data.dart';
import '../screens/haptic.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // الترويسة الترحيبية
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
              decoration: const BoxDecoration(
                gradient: TravixoFX.orange,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.t('welcome'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.firstName ?? l.t('guest'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26, // أكبر من 22
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Haptics.light();
                      // فتح الإشعارات
                    },
                    child: Container(
                      width: 48, // أكبر من 42
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24, // أكبر من 22
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // قسم البطاقات الثماني
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('services'),
                    style: TextStyle(
                      color: TIColors.lightText,
                      fontSize: 22, // أكبر من 18
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 14, // أكبر من 12
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1, // أكبر من 0.95
                    children: [
                      _ServiceCard(
                        color: TIColors.cardTrips,
                        icon: Icons.flight_takeoff,
                        title: l.t('trips'),
                        onTap: () {
                          Haptics.light();
                          // فتح شاشة الرحلات
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardRent,
                        icon: Icons.directions_car_filled,
                        title: l.t('car_rental'),
                        onTap: () {
                          Haptics.light();
                          // فتح شاشة السيارات
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardHotels,
                        icon: Icons.hotel,
                        title: l.t('hotels'),
                        onTap: () {
                          Haptics.light();
                          // فتح شاشة الفنادق
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardPlans,
                        icon: Icons.map,
                        title: l.t('trip_planner'),
                        onTap: () {
                          Haptics.light();
                          // فتح مخطط الرحلات
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardResorts,
                        icon: Icons.spa,
                        title: l.t('resorts'),
                        onTap: () {
                          Haptics.light();
                          // فتح شاشة المنتجعات
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardPlaces,
                        icon: Icons.place,
                        title: l.t('best_places'),
                        onTap: () {
                          Haptics.light();
                          // فتح أفضل الأماكن
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardMap,
                        icon: Icons.map_outlined,
                        title: l.t('live_map'),
                        onTap: () {
                          Haptics.light();
                          // فتح الخريطة الحية
                        },
                      ),
                      _ServiceCard(
                        color: TIColors.cardAssistant,
                        icon: Icons.smart_toy,
                        title: l.t('assistant'),
                        onTap: () {
                          Haptics.light();
                          // فتح المساعد الذكي
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // قسم العروض
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('offers'),
                    style: TextStyle(
                      color: TIColors.lightText,
                      fontSize: 22, // أكبر من 18
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140, // أكبر من 120
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: DemoData.offers.length,
                      itemBuilder: (ctx, i) {
                        final offer = DemoData.offers[i];
                        return GestureDetector(
                          onTap: () {
                            Haptics.light();
                            // فتح تفاصيل العرض
                          },
                          child: Container(
                            width: 280, // أكبر من 240
                            margin: const EdgeInsets.only(left: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: TravixoFX.soft(TIColors.orange),
                              borderRadius: BorderRadius.circular(18), // أكبر من 14
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${offer.discountPercent}% ${l.t('discount')}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  offer.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // أكبر من 14
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer.subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // قسم الفنادق القريبة
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('nearby_hotels'),
                    style: TextStyle(
                      color: TIColors.lightText,
                      fontSize: 22, // أكبر من 18
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200, // أكبر من 180
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: RealHotelsData.hotels.length > 6 ? 6 : RealHotelsData.hotels.length,
                      itemBuilder: (ctx, i) {
                        final hotel = RealHotelsData.hotels[i];
                        return GestureDetector(
                          onTap: () {
                            Haptics.light();
                            // فتح تفاصيل الفندق
                          },
                          child: Container(
                            width: 260, // أكبر من 220
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: TIColors.lightCard,
                              borderRadius: BorderRadius.circular(16), // أكبر من 12
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    hotel.img(),
                                    width: double.infinity,
                                    height: 120, // أكبر من 100
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 120,
                                        color: TIColors.orangeSoft,
                                        child: const Icon(
                                          Icons.hotel,
                                          color: TIColors.orange,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        hotel.name,
                                        style: const TextStyle(
                                          fontSize: 15, // أكبر من 13
                                          fontWeight: FontWeight.w700,
                                          color: TIColors.lightText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: TIColors.warning,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${hotel.rating}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: TIColors.lightSub,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // قسم الأماكن المقترحة
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.t('suggested_places'),
                    style: TextStyle(
                      color: TIColors.lightText,
                      fontSize: 22, // أكبر من 18
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200, // أكبر من 180
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: DemoData.bestPlaces.length > 6 ? 6 : DemoData.bestPlaces.length,
                      itemBuilder: (ctx, i) {
                        final place = DemoData.bestPlaces[i];
                        return GestureDetector(
                          onTap: () {
                            Haptics.light();
                            // فتح تفاصيل المكان
                          },
                          child: Container(
                            width: 260, // أكبر من 220
                            margin: const EdgeInsets.only(left: 12),
                            decoration: BoxDecoration(
                              color: TIColors.lightCard,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    place.img(),
                                    width: double.infinity,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 120,
                                        color: TIColors.orangeSoft,
                                        child: const Icon(
                                          Icons.place,
                                          color: TIColors.orange,
                                          size: 40,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        place.name(context),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: TIColors.lightText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.star,
                                            color: TIColors.warning,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${place.rating}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: TIColors.lightSub,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 100), // مساحة للشريط السفلي
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: TravixoFX.soft(color),
          borderRadius: BorderRadius.circular(18), // أكبر من 14
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 44, // أكبر من 36
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15, // أكبر من 13
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
