// شاشة البداية السينمائية — Travixo Splash Screen
// تعرض اللوجو بحجم كبير مع حركة دخول ناعمة وخلفية متدرجة
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/app_state.dart';
import 'onboarding_screen.dart';
import 'main_shell.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // إعداد حركة الأنيميشن (تلاشي + تكبير ناعم)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 1.0, curve: Curves.elasticOut)),
    );

    _controller.forward();

    // الانتقال التلقائي بعد 2.5 ثانية
    Future.delayed(const Duration(milliseconds: 2500), _navigateToNextScreen);
  }

  void _navigateToNextScreen() {
    if (!mounted) return;
    final state = context.read<AppState>();
    final Widget nextPage = state.hasSeenOnboarding ? const MainShell() : const OnboardingScreen();
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: TravixoFX.splash, // تدرج برتقالي عمودي من app_theme
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // حاوية اللوجو بحجم كبير وظل ناعم
              Container(
                width: 240, // حجم أكبر مثل تطبيقات Direct
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'logo.png.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // بديل أنيق في حال لم يتم رفع الصورة بعد
                      return const Center(
                        child: Icon(Icons.travel_explore, size: 100, color: TIColors.orange),
                      );
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // اسم التطبيق بخط عريض وكبير
              const Text(
                'TRAVIXO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38, // حجم أكبر
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // الشعار اللفظي
              Text(
                'Your Smart Travel Partner',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
              
              const Spacer(flex: 3),
              
              // مؤشر التحميل (3 نقاط)
              Padding(
                padding: const EdgeInsets.only(bottom: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3 + (index * 0.3)),
                            shape: BoxShape.circle,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
