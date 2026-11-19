// ============================================================
//  Travixo — شاشة البداية السينمائية
//  الملف: lib/screens/splash_screen.dart
//  الخطوة 2: سبلاش بأسلوب Direct — الطريق يرسم نفسه + السيارة
//  ملاحظة: منطق التنقل القديم محفوظ حرفياً بدون أي تغيير
// ============================================================

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'auth_screens.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  Timer? _timer;

  late final AnimationController _road =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  late final AnimationController _car =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));
  late final AnimationController _letters =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  late final AnimationController _tag =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  late final Animation<double> _roadAnim =
      CurvedAnimation(parent: _road, curve: Curves.easeInOut);
  late final Animation<double> _carMove = CurvedAnimation(
      parent: _car,
      curve: const Interval(0.0, 0.88, curve: Curves.easeInOutCubic));
  late final Animation<double> _carIn = CurvedAnimation(
      parent: _car, curve: const Interval(0.0, 0.10, curve: Curves.easeOut));
  late final Animation<double> _tagAnim =
      CurvedAnimation(parent: _tag, curve: Curves.easeOut);

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 4500), _go);
    _road.forward();
    _car.forward(delay: const Duration(milliseconds: 300));
    _letters.forward(delay: const Duration(milliseconds: 900));
    _tag.forward(delay: const Duration(milliseconds: 2700));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _road.dispose();
    _car.dispose();
    _letters.dispose();
    _tag.dispose();
    super.dispose();
  }

  // ===== منطق التنقل الأصلي — محفوظ كما هو =====
  void _go() {
    if (!mounted) return;
    _timer?.cancel();
    final user = context.read<AppState>().user;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => user == null
          ? const UserTypeScreen()
          : (user.role == 'developer'
              ? const DeveloperLoginScreen()
              : const OnboardingScreen()),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bool isAr = context.read<AppState>().isRTL;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: TravixoFX.splash),
        child: SafeArea(
          child: Stack(
            children: [
              // ===== الطريق + السيارة =====
              Positioned.fill(
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_roadAnim, _carMove, _carIn]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _RoadPainter(
                        roadT: _roadAnim.value,
                        carT: _carMove.value,
                        carAlpha: _carIn.value,
                      ),
                    );
                  },
                ),
              ),

              // ===== الشعار + الأحرف =====
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // شارة السيارة البيضاء
                    AnimatedBuilder(
                      animation: _letters,
                      builder: (context, _) {
                        final double t = const Interval(0.0, 0.22,
                                curve: Curves.easeOutBack)
                            .transform(_letters.value);
                        return Opacity(
                          opacity: t.clamp(0.0, 1.0),
                          child: Transform.scale(
                            scale: t.clamp(0.0, 1.15),
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.directions_car,
                                  color: TIColors.orange, size: 42),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    // TRAVIXO — حرفاً حرفاً
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0;
                              i < 'TRAVIXO'.length;
                              i++)
                            _letter('TRAVIXO'[i], i, 'TRAVIXO'.length),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // العبارة التعريفية
                    AnimatedBuilder(
                      animation: _tagAnim,
                      builder: (context, _) {
                        return Opacity(
                          opacity: _tagAnim.value,
                          child: Transform.translate(
                            offset:
                                Offset(0, (1 - _tagAnim.value) * 14),
                            child: Text(
                              isAr
                                  ? 'رفيقك الذكي في السفر'
                                  : 'Your smart travel partner',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ===== زر التخطي =====
              PositionedDirectional(
                top: 8,
                start: 8,
                child: TextButton(
                  onPressed: _go,
                  child: Text(
                    isAr ? 'تخطي' : 'Skip',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // ===== مؤشر تحميل صغير =====
              Positioned(
                bottom: 26,
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // حرف واحد يظهر بعد انزلاق من الأعلى
  Widget _letter(String ch, int i, int n) {
    final double begin = i * 0.55 / n;
    return AnimatedBuilder(
      animation: _letters,
      builder: (context, _) {
        final double t = Interval(begin, (begin + 0.45).clamp(0.0, 1.0),
                curve: Curves.easeOutBack)
            .transform(_letters.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 26),
            child: Text(
              ch,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// الرسام: طريق منحني يرسم نفسه + خط منقّط + سيارة تسوق وتتوقف
// ============================================================
class _RoadPainter extends CustomPainter {
  final double roadT;   // تقدم رسم الطريق 0..1
  final double carT;    // تقدم حركة السيارة 0..1
  final double carAlpha; // ظهور السيارة

  _RoadPainter({
    required this.roadT,
    required this.carT,
    required this.carAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // مسار الطريق: يدخل من يمين الشاشة ويتقوس ويسار الشاشة
    final Path road = Path()
      ..moveTo(size.width * 1.25, size.height * 0.70)
      ..cubicTo(
          size.width * 0.88,
          size.height * 0.55,
          size.width * 0.64,
          size.height * 0.80,
          size.width * 0.44,
          size.height * 0.64)
      ..cubicTo(
          size.width * 0.26,
          size.height * 0.50,
          size.width * 0.12,
          size.height * 0.64,
          size.width * -0.20,
          size.height * 0.56);

    final PathMetric metric = road.computeMetrics(forceClosed: false).first;
    final double shown = metric.length * roadT.clamp(0.0, 1.0);

    // 1) جسم الطريق — أبيض شفاف فوق البرتقالي
    final Paint roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.38)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(metric.extractPath(0, shown), roadPaint);

    // 2) الخط المنقط الأبيض في وسط الطريق
    final Paint dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (double d = 14; d < shown; d += 30) {
      final double segEnd = math.min(d + 15, shown);
      canvas.drawPath(metric.extractPath(d, segEnd), dashPaint);
    }

    // 3) السيارة البيضاء — تتساق على المسار وتتوقف قرب النهاية
    if (carAlpha > 0 && carT > 0) {
      final double f = (carT * 0.90).clamp(0.0, 1.0);
      final Tangent? tan = metric.getTangentForFraction(f);
      if (tan != null) {
        canvas.save();
        canvas.translate(tan.position.dx, tan.position.dy);
        canvas.rotate(tan.angle);
        _paintCar(canvas);
        canvas.restore();
      }
    }
  }

  void _paintCar(Canvas canvas) {
    final Paint shadow = Paint()..color = Colors.black.withOpacity(0.15);
    canvas.drawOval(
        const Rect.fromCenter(
            center: Offset(0, 16), width: 58, height: 12),
        shadow);

    final Paint white = Paint()..color = Colors.white;
    final Paint glass = Paint()..color = TIColors.orangeSoft;
    final Paint dark = Paint()..color = TIColors.navyDark;

    // جسم السيارة
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          const Rect.fromLTWH(-30, -6, 60, 20),
          topLeft: const Radius.circular(9),
          topRight: const Radius.circular(9),
          bottomLeft: const Radius.circular(9),
          bottomRight: const Radius.circular(9),
        ),
        white);

    // سقف السيارة
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-16, -20, 34, 18),
            const Radius.circular(8)),
        white);

    // زجاج السيارة
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(-12, -16, 12, 10),
            const Radius.circular(4)),
        glass);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            const Rect.fromLTWH(3, -16, 14, 10),
            const Radius.circular(4)),
        glass);

    // العجلات
    canvas.drawCircle(const Offset(-17, 14), 7, dark);
    canvas.drawCircle(const Offset(17, 14), 7, dark);
    canvas.drawCircle(const Offset(-17, 14), 3, white);
    canvas.drawCircle(const Offset(17, 14), 3, white);
  }

  @override
  bool shouldRepaint(covariant _RoadPainter old) {
    return old.roadT != roadT ||
        old.carT != carT ||
        old.carAlpha != carAlpha;
  }
}
