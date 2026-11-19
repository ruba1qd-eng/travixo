
// ============================================================
//  Travixo — نظام الألوان والثيم (النهاري + الليلي)
//  الملف: lib/theme/app_theme.dart
//  الخطوة 1: تحويل الهوية إلى Travixo البرتقالية
//  ملاحظة مهمة: نفس أسماء الكلاسات القديمة محفوظة
//  (TIColors / AppTheme) حتى تستمر كل الشاشات بالعمل بدون أي تغيير
// ============================================================

import 'package:flutter/material.dart';

class TIColors {
  TIColors._();

  // ==== هوية Travixo البرتقالية ====
  static const Color orange = Color(0xFFFF8C1A);
  static const Color orangeDeep = Color(0xFFC95F00);
  static const Color orangeSoft = Color(0xFFFFECD9);

  // ==== الأسماء الأصلية المحفوظة — بقيم الهوية الجديدة ====
  static const Color navy = Color(0xFF201D1A); // كان كحلي — صار فحمي دافئ للنصوص
  static const Color navyDark = Color(0xFF141210); // خلفية الوضع الليلي
  static const Color gold = Color(0xFFFF8C1A); // كان ذهبي — صار برتقال Travixo
  static const Color teal = Color(0xFF14B8A6); // لون مساعد ثانوي
  static const Color softGray = Color(0xFFF7F5F1); // خلفية نهارية كريمية
  static const Color danger = Color(0xFFE5484D);
  static const Color success = Color(0xFF2FA96E);
  static const Color warning = Color(0xFFF5A623);

  // ==== أسطح الوضع النهاري ====
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = navy;
  static const Color lightSub = Color(0xFF716B63);
  static const Color lightLine = Color(0xFFE8E2D9);

  // ==== أسطح الوضع الليلي ====
  static const Color darkCard = Color(0xFF211E1B);
  static const Color darkText = Color(0xFFF6F3EF);
  static const Color darkSub = Color(0xFFABA398);
  static const Color darkLine = Color(0xFF332F2A);

  // ==== ألوان بطاقات الأقسام — أسلوب Direct الملون ====
  static const Color cardTrips = Color(0xFFFF8C1A);     // الرحلات
  static const Color cardRent = Color(0xFFED7117);      // تأجير السيارات
  static const Color cardHotels = Color(0xFFFFA13D);    // الفنادق
  static const Color cardPlans = Color(0xFFC95F00);     // صمم خطتك
  static const Color cardResorts = Color(0xFFFFB86B);   // المنتجات والمنتجعات
  static const Color cardPlaces = Color(0xFFE08A00);    // أفضل الأماكن
  static const Color cardMap = Color(0xFFD97A1F);       // الخريطة الحية
  static const Color cardAssistant = Color(0xFFFF9231); // المساعد الذكي

  // لون النص فوق البطاقات الملونة — أبيض دائماً في الوضعين
  static const Color onCard = Color(0xFFFFFFFF);
}

// ------------------------------------------------------------
// مؤثرات جاهزة: تدرجات + ظلال نستخدمها في السبلاش والبطاقات
// ------------------------------------------------------------
class TravixoFX {
  TravixoFX._();

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

  static LinearGradient soft(Color base) => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [base, base.withOpacity(0.75)],
      );

  static List<BoxShadow> shadow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.18),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}

class TIRadius {
  TIRadius._();
  static const double s = 12;
  static const double m = 16;
  static const double l = 22;
  static const BorderRadius card = BorderRadius.all(Radius.circular(m));
  static const BorderRadius sheet =
      BorderRadius.vertical(top: Radius.circular(l));
}

// ------------------------------------------------------------
// الثيمان — نفس واجهة ملفك القديم تماماً (AppTheme.light / AppTheme.dark)
// ------------------------------------------------------------
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool isLight = brightness == Brightness.light;

    final Color bg = isLight ? TIColors.softGray : TIColors.navyDark;
    final Color card = isLight ? TIColors.lightCard : TIColors.darkCard;
    final Color text = isLight ? TIColors.lightText : TIColors.darkText;
    final Color sub = isLight ? TIColors.lightSub : TIColors.darkSub;
    final Color line = isLight ? TIColors.lightLine : TIColors.darkLine;

    final ColorScheme cs = ColorScheme.fromSeed(
      seedColor: TIColors.orange,
      brightness: brightness,
    ).copyWith(
      primary: TIColors.orange,
      onPrimary: Colors.white,
      secondary: TIColors.teal,
      surface: card,
      onSurface: text,
      error: TIColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: cs,
      scaffoldBackgroundColor: bg,
      dividerColor: line,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: text,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: text),
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      iconTheme: IconThemeData(color: sub),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TIColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TIColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: TIColors.orange,
          side: const BorderSide(color: TIColors.orange, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TIColors.orange,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: sub, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TIColors.orange, width: 1.6),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isLight ? TIColors.navy : TIColors.darkCard,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: TextTheme(
        headlineLarge:
            TextStyle(color: text, fontSize: 28, fontWeight: FontWeight.w900),
        headlineMedium:
            TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.w800),
        titleLarge:
            TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800),
        titleMedium:
            TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: text, fontSize: 15),
        bodyMedium: TextStyle(color: text, fontSize: 14),
        bodySmall: TextStyle(color: sub, fontSize: 12),
      ),
    );
  }
}
