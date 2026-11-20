// الشاشة الرئيسية — Travixo Home Screen (النسخة البصرية المطوّرة)
// بطاقات بصور حقيقية + حركات دخول متتالية + ترويسة حية متدرجة — بأسلوب دايركت
// كل التنقلات والوظائف السابقة محفوظة كما هي
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import '../l10n/app_localizations.dart';
import '../data/models.dart';
import '../data/demo_data.dart';
import '../data/real_hotels_data.dart';
import '../data/places_data.dart';
import '../screens/haptic.dart';
import 'assistant_screen.dart';
import 'best_places_screen.dart';
import 'details_screens.dart';
import 'live_map_screen.dart';
import 'trip_planner_screen.dart';
import 'package:provider/provider.dart';

/// صور الأقسام الثمانية — من نفس مصدر صور التطبيق الموثوق
const String _kImgTrips =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/f660398bf9b4.jpg';
const String _kImgCar =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/0d1bbf462dc6.jpg';
const String _kImgHotels =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/13baf2d5e4f1.jpg';
const String _kImgPlanner =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/af507c4c471a.jpg';
const String _kImgResorts =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/24a4bf91a967.jpg';
const String _kImgPlaces =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/4a023bca5193.jpg';
const String _kImgMap =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/af98170f9e25.webp';
const String _kImgAssistant =
    'https://z-cdn.chatglm.cn/image-search-mcp/images-ppt/bb2758586cdf.jpg';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // حركة الدخول المتتالية (تُشغَّل مرة عند فتح الشاشة)
  late final AnimationController _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  // حركة الطفو المستمرة (لطيفة — للڤان وشارة الخصم)
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
    lowerBound: -1,
    upperBound: 1,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _in.dispose();
    _float.dispose();
    super.dispose();
  }

  /// منحنى دخول متأخر لكل عنصر
  CurvedAnimation _stagger(double start, {double span = 0.30}) =>
      CurvedAnimation(
        parent: _in,
        curve: Interval(
          start,
          (start + span).clamp(0.0, 1.0).toDouble(),
          curve: Curves.easeOutCubic,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final state = context.watch<AppState>();
    final user = state.user;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // الترويسة الترحيبية المتحركة
          SliverToBoxAdapter(child: _hdr(l, user)),
          // الأقسام الثمانية بصور حقيقية
          SliverToBoxAdapter(child: _services(l, context)),
          // العروض الحصرية
          SliverToBoxAdapter(child: _offers(l, context)),
          // الفنادق القريبة
          SliverToBoxAdapter(child: _hotels(l, context)),
          // الأماكن المقترحة
          SliverToBoxAdapter(child: _places(l, context)),
          // مساحة للشريط السفلي
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  // ============================================================
  // الترويسة — تدرج برتقالي بحواف دائرية + زخارف + ڤان تطفو بلطف
  // ============================================================
  Widget _hdr(AppLocalizations l, AppUser? user) {
    return Container(
      decoration: BoxDecoration(
        gradient: TravixoFX.orange,
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [TravixoFX.shadow(TIColors.orangeDeep)],
      ),
      child: ClipRRect(
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(30)),
        child: Stack(
          children: [
            // زخارف دوائر شفافة
            Positioned(
              right: -50,
              top: -60,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              right: 120,
              top: 20,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.10),
                ),
              ),
            ),
            Positioned(
              left: -35,
              bottom: -25,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07),
                ),
              ),
            ),
            // مركبة ڤان تطفو بلطف أعلى الترويسة — رمز خدمة النقل للمطار (بدون طائرات)
            Positioned(
              left: 22,
              top: 0,
              child: AnimatedBuilder(
                animation: _float,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _float.value * 6),
                  child: child,
                ),
                child: Icon(
                  Icons.airport_shuttle,
                  size: 52,
                  color: Colors.white.withOpacity(0.30),
                ),
              ),
            ),
            // المحتوى: الترحيب + زر الإشعارات (نفس المنطق السابق)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 62, 20, 30),
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
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Haptics.light();
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(22)),
                        ),
                        builder: (_) => SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.t('notifications'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: TIColors.lightText,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if ((AppState.instance?.notifications ??
                                        const <String>[])
                                    .isEmpty)
                                  Text(
                                    l.t('noNotifications'),
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: TIColors.lightSub,
                                    ),
                                  )
                                else
                                  ...AppState.instance!.notifications.map(
                                    (n) => Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.notifications_active,
                                            color: TIColors.orange,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              n,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: TIColors.lightText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // عنوان قسم موحّد: مربع أيقونة + نص عريض
  // ============================================================
  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: TIColors.orangeSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: TIColors.orange, size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: TIColors.lightText,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // الأقسام الثمانية — بطاقات بصور حقيقية وتداخل متدرج
  // ============================================================
  Widget _services(AppLocalizations l, BuildContext context) {
    Widget card(
      int i, {
      required IconData icon,
      required Color color,
      required String title,
      required String img,
      required VoidCallback onTap,
    }) {
      return _ServiceCard(
        icon: icon,
        color: color,
        title: title,
        img: img,
        onTap: onTap,
        anim: _stagger(0.10 + i * 0.05),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l.t('services'), Icons.grid_view),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.02,
            children: [
              card(
                0,
                icon: Icons.tour,
                color: TIColors.cardTrips,
                title: l.t('trips'),
                img: _kImgTrips,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DetailsScreen(
                          service: ServiceType.tour, targetId: 'list')));
                },
              ),
              card(
                1,
                icon: Icons.directions_car_filled,
                color: TIColors.cardRent,
                title: l.t('car_rental'),
                img: _kImgCar,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DetailsScreen(
                          service: ServiceType.rentCar, targetId: 'list')));
                },
              ),
              card(
                2,
                icon: Icons.hotel,
                color: TIColors.cardHotels,
                title: l.t('hotels'),
                img: _kImgHotels,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const DetailsScreen(
                          service: ServiceType.hotel, targetId: 'list')));
                },
              ),
              card(
                3,
                icon: Icons.map,
                color: TIColors.cardPlans,
                title: l.t('trip_planner'),
                img: _kImgPlanner,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const TripPlannerScreen()));
                },
              ),
              card(
                4,
                icon: Icons.spa,
                color: TIColors.cardResorts,
                title: l.t('resorts'),
                img: _kImgResorts,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BestPlacesScreen()));
                },
              ),
              card(
                5,
                icon: Icons.place,
                color: TIColors.cardPlaces,
                title: l.t('best_places'),
                img: _kImgPlaces,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const BestPlacesScreen()));
                },
              ),
              card(
                6,
                icon: Icons.map_outlined,
                color: TIColors.cardMap,
                title: l.t('liveMap'),
                img: _kImgMap,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LiveMapScreen()));
                },
              ),
              card(
                7,
                icon: Icons.smart_toy,
                color: TIColors.cardAssistant,
                title: l.t('assistant'),
                img: _kImgAssistant,
                onTap: () {
                  Haptics.light();
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const AssistantScreen()));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // العروض — بطاقات متدرجة + أيقونة خدمة كبيرة + شارة خصم نابضة
  // ============================================================
  IconData _offerIcon(ServiceType s) {
    switch (s) {
      case ServiceType.hotel:
        return Icons.hotel;
      case ServiceType.tour:
        return Icons.tour;
      case ServiceType.rentCar:
        return Icons.directions_car_filled;
      case ServiceType.airport:
        return Icons.airport_shuttle;
      default:
        return Icons.local_offer;
    }
  }

  Widget _offers(AppLocalizations l, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l.t('offers'), Icons.local_offer),
          const SizedBox(height: 14),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kOffers.length,
              itemBuilder: (ctx, i) {
                final offer = kOffers[i];
                return _Pressable(
                  onTap: () {
                    Haptics.light();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DetailsScreen(
                            service: offer.service,
                            targetId: offer.targetId)));
                  },
                  child: _Stagger(
                    anim: _stagger(0.28 + i * 0.05),
                    child: Container(
                      width: 285,
                      margin: const EdgeInsetsDirectional.only(end: 12),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(TIRadius.card),
                        boxShadow: [TravixoFX.shadow(TIColors.orange)],
                      ),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(TIRadius.card),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: TravixoFX.soft(TIColors.orange),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // أيقونة الخدمة الكبيرة كزخرفة
                              PositionedDirectional(
                                end: -18,
                                bottom: -18,
                                child: Icon(
                                  _offerIcon(offer.service),
                                  size: 110,
                                  color:
                                      Colors.white.withOpacity(0.14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    // شارة الخصم النابضة
                                    AnimatedBuilder(
                                      animation: _float,
                                      builder: (context, child) =>
                                          Transform.scale(
                                        scale: 1.0 +
                                            0.05 *
                                                (0.5 + 0.5 * _float.value),
                                        child: child,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            horizontal: 10,
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.30),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                        ),
                                        child: Text(
                                          '${offer.discountPercent}% ${l.t('discount')}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      offer.title,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      offer.subtitle,
                                      style: TextStyle(
                                        color: Colors.white
                                            .withOpacity(0.92),
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // الفنادق القريبة — صورة + شارة تقييم عائمة + حركة عند اللمس
  // ============================================================
  Widget _hotels(AppLocalizations l, BuildContext context) {
    final hotels = getAllHotels();
    final count = hotels.length > 6 ? 6 : hotels.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l.t('nearby_hotels'), Icons.hotel),
          const SizedBox(height: 14),
          SizedBox(
            height: 205,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemBuilder: (ctx, i) {
                final hotel = hotels[i];
                return _Pressable(
                  onTap: () {
                    Haptics.light();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => DetailsScreen(
                            service: ServiceType.hotel,
                            targetId: hotel.id)));
                  },
                  child: _Stagger(
                    anim: _stagger(0.40 + i * 0.05),
                    child: _hotelCard(hotel),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _hotelCard(Hotel hotel) {
    return Container(
      width: 265,
      margin: const EdgeInsetsDirectional.only(end: 12),
      decoration: BoxDecoration(
        color: TIColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  hotel.img(),
                  width: double.infinity,
                  height: 132,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 132,
                      color: TIColors.orangeSoft,
                      child: const Icon(
                        Icons.hotel,
                        color: TIColors.orange,
                        size: 36,
                      ),
                    );
                  },
                ),
                // شارة التقييم العائمة
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: TIColors.warning, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          '${hotel.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: TIColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                hotel.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: TIColors.lightText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الأماكن المقترحة — نفس أسلوب الفنادق
  // ============================================================
  Widget _places(AppLocalizations l, BuildContext context) {
    final count = kBestPlaces.length > 6 ? 6 : kBestPlaces.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(l.t('suggested_places'), Icons.place),
          const SizedBox(height: 14),
          SizedBox(
            height: 205,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              itemBuilder: (ctx, i) {
                final place = kBestPlaces[i];
                return _Pressable(
                  onTap: () {
                    Haptics.light();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => BestPlacesScreen(
                            initialProvince: place.provinceId)));
                  },
                  child: _Stagger(
                    anim: _stagger(0.50 + i * 0.05),
                    child: _placeCard(place, l),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeCard(BestPlace place, AppLocalizations l) {
    return Container(
      width: 265,
      margin: const EdgeInsetsDirectional.only(end: 12),
      decoration: BoxDecoration(
        color: TIColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  place.img(),
                  width: double.infinity,
                  height: 132,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 132,
                      color: TIColors.orangeSoft,
                      child: const Icon(
                        Icons.place,
                        color: TIColors.orange,
                        size: 36,
                      ),
                    );
                  },
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star,
                            color: TIColors.warning, size: 13),
                        const SizedBox(width: 3),
                        Text(
                          '${place.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: TIColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                place.name(l.isArabic),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: TIColors.lightText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// بطاقة قسم — صورة حقيقية + تظليل + حركة دخول + انكماش عند اللمس
// ============================================================
class _ServiceCard extends StatefulWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String img;
  final Animation<double> anim;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.color,
    required this.icon,
    required this.title,
    required this.img,
    required this.anim,
    required this.onTap,
  });

  @override
  State<_ServiceCard> createState() => _ServiceCardState();
}

class _ServiceCardState extends State<_ServiceCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.anim,
      builder: (context, child) {
        final double v = widget.anim.value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 36 * (1 - v)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 130),
          curve: Curves.easeOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(TIRadius.medium),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(TIRadius.medium),
              child: Container(
                decoration: BoxDecoration(
                  gradient: TravixoFX.soft(widget.color),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // خلفية احتياطية: أيقونة كبيرة قبل تحميل الصورة أو عند فشلها
                    Center(
                      child: Icon(
                        widget.icon,
                        color: Colors.white.withOpacity(0.85),
                        size: 46,
                      ),
                    ),
                    // الصورة
                    Positioned.fill(
                      child: Image.network(
                        widget.img,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                    // تظليل سفلي لنص واضح
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.60),
                            Colors.black.withOpacity(0.12),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.42, 1.0],
                        ),
                      ),
                    ),
                    // الأيقونة والاسم أسفل البطاقة
                    PositionedDirectional(
                      bottom: 12,
                      start: 12,
                      end: 12,
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.25),
                            ),
                            child: Icon(widget.icon,
                                color: Colors.white, size: 19),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // سهم صغير أعلى الطرف
                    PositionedDirectional(
                      top: 10,
                      end: 10,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.22),
                        ),
                        child: const Icon(
                          Icons.north_east,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// غلاف دخول متتالي — شفافية + انزلاق لأعلى
// ============================================================
class _Stagger extends StatelessWidget {
  final Animation<double> anim;
  final Widget child;

  const _Stagger({required this.anim, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final double v = anim.value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, 34 * (1 - v)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ============================================================
// غلاف لمس — انكماش خفيف عند الضغط
// ============================================================
class _Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Pressable({required this.child, required this.onTap});

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      child: AnimatedScale(
        scale: _down ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
