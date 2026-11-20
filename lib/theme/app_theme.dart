// نظام الألوان والثيمين — أحجام أكبر مثل Direct
// Travixo Theme System — Larger sizes for better visibility
import 'package:flutter/material.dart';

class TIColors {
  // ألوان الهوية الأساسية
  static const Color orange = Color(0xFFFF8C1A);
  static const Color orangeDeep = Color(0xFFC95F00);
  static const Color orangeSoft = Color(0xFFFFECD9);
  
  // الأسماء الموروثة وقيمها الجديدة
  static const Color navy = Color(0xFF201D1A);
  static const Color navyDark = Color(0xFF141210);
  static const Color gold = Color(0xFFFF8C1A);
  static const Color teal = Color(0xFFC95F00); // كان تيل أزرق — صار برتقالي عميق (لا أزرق في الهوية إطلاقاً)
  static const Color softGray = Color(0xFFF7F5F1);
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF2FA96E);
  static const Color warning = Color(0xFFF5A623);
  
  // أسطح الوضع النهاري
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = navy;
  static const Color lightSub = Color(0xFF716B63);
  static const Color lightLine = Color(0xFFE8E2D9);
  
  // أسطح الوضع الليلي
  static const Color darkCard = Color(0xFF211E1B);
  static const Color darkText = Color(0xFFF6F3EF);
  static const Color darkSub = Color(0xFFABA398);
  static const Color darkLine = Color(0xFF332F2A);
  
  // ألوان البطاقات الثماني — أسلوب Direct
  static const Color cardTrips = Color(0xFFFF8C1A);
  static const Color cardRent = Color(0xFFED7117);
  static const Color cardHotels = Color(0xFFFFA13D);
  static const Color cardPlans = Color(0xFFC95F00);
  static const Color cardResorts = Color(0xFFFFB86B);
  static const Color cardPlaces = Color(0xFFE08A00);
  static const Color cardMap = Color(0xFFD97A1F);
  static const Color cardAssistant = Color(0xFFFF9231);
  static const Color onCard = Color(0xFFFFFFFF);
}

class TIRadius {
  // أحجام أكبر للحواف
  static const double small = 16;    // أكبر من 12
  static const double medium = 22;   // أكبر من 16
  static const double large = 28;    // أكبر من 22
  static const double card = medium;
  static const double sheet = large;
  static const double l = large; // اختصار شائع في الشاشات
}

class TravixoFX {
  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [TIColors.orange, TIColors.orangeDeep],
  );
  
  static const LinearGradient splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [TIColors.orange, TIColors.orangeDeep],
  );
  
  static LinearGradient soft(Color c) => LinearGradient(
    colors: [c.withOpacity(0.75), c],
  );
  
  static BoxShadow shadow(Color c) => BoxShadow(
    color: c.withOpacity(0.18),
    blurRadius: 18,
    offset: const Offset(0, 8),
  );
}

class AppTheme {
  static ThemeData get light => build(false);
  static ThemeData get dark => build(true);

  static ThemeData build(bool isDark) {
    final bg = isDark ? TIColors.navyDark : TIColors.softGray;
    final card = isDark ? TIColors.darkCard : TIColors.lightCard;
    final text = isDark ? TIColors.darkText : TIColors.lightText;
    final sub = isDark ? TIColors.darkSub : TIColors.lightSub;
    final line = isDark ? TIColors.darkLine : TIColors.lightLine;

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: TIColors.orange,
        primary: TIColors.orange,
        onPrimary: Colors.white,
        secondary: TIColors.teal,
        surface: bg,
        error: TIColors.danger,
      ),
      scaffoldBackgroundColor: bg,
      
      // شريط التطبيق
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 22, // أكبر من 18
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: text),
      ),
      
      // البطاقات
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TIRadius.card),
        ),
      ),
      
      // الأزرار — أحجام أكبر
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TIColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60), // أكبر من 52
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18), // أكبر من 14
          ),
          textStyle: const TextStyle(
            fontSize: 18, // أكبر من 16
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TIColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 17, // أكبر من 15
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TIColors.orange,
          side: const BorderSide(color: TIColors.orange, width: 1.5),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TIColors.orange,
          textStyle: const TextStyle(
            fontSize: 16, // أكبر من 14
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      
      // حقول الإدخال
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 22, // أكبر من 18
          vertical: 18,   // أكبر من 16
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18), // أكبر من 14
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: TIColors.orange, width: 1.6),
        ),
        hintStyle: TextStyle(
          color: sub,
          fontSize: 16, // أكبر من 14
        ),
      ),
      
      // شريط التنقل السفلي
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: card,
        selectedItemColor: TIColors.orange,
        unselectedItemColor: sub,
        type: BottomNavigationBarType.fixed,
      ),
      
      // سلّم الخطوط النصي — أحجام أكبر
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: text,
          fontSize: 34, // أكبر من 28
          fontWeight: FontWeight.w900,
        ),
        headlineMedium: TextStyle(
          color: text,
          fontSize: 28, // أكبر من 24
          fontWeight: FontWeight.w800,
        ),
        titleLarge: TextStyle(
          color: text,
          fontSize: 22, // أكبر من 18
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: text,
          fontSize: 18, // أكبر من 16
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: text,
          fontSize: 17, // أكبر من 15
        ),
        bodyMedium: TextStyle(
          color: text,
          fontSize: 16, // أكبر من 14
        ),
        bodySmall: TextStyle(
          color: sub,
          fontSize: 14, // أكبر من 12
        ),
      ),
    );
  }
}
