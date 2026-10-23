import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 12;
  static const double l = 16;
  static const double xl = 24;
}

abstract final class AppRadius {
  static const double m = 12;
}

abstract final class AppThemes {
  static ThemeData get light => _theme(Brightness.light);

  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: isLight ? const Color(0xFFC2410C) : const Color(0xFFD46A4A),
      brightness: brightness,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: isLight ? const Color(0xFFC2410C) : const Color(0xFFD46A4A),
      onPrimary: isLight ? const Color(0xFFFFF8F5) : const Color(0xFF2A120C),
      surface: isLight ? const Color(0xFFF7F7F6) : const Color(0xFF141413),
      onSurface: isLight ? const Color(0xFF171717) : const Color(0xFFE8E6E1),
      onSurfaceVariant: isLight
          ? const Color(0xFF5C5C5C)
          : const Color(0xFFB7B3AC),
      outline: isLight ? const Color(0xFFE6E6E4) : const Color(0xFF3A3834),
      outlineVariant: isLight
          ? const Color(0xFFE6E6E4)
          : const Color(0xFF3A3834),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: _textTheme(scheme.onSurface),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: scheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
          statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outline, thickness: 1),
      iconTheme: IconThemeData(color: scheme.onSurface),
    );
  }

  static TextTheme _textTheme(Color color) {
    TextStyle style({
      required double size,
      required double height,
      FontWeight weight = FontWeight.w400,
      double letterSpacing = 0,
    }) {
      return TextStyle(
        color: color,
        fontSize: size,
        height: height,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      headlineMedium: style(
        size: 28,
        height: 1.2,
        weight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      titleLarge: style(size: 22, height: 1.25, weight: FontWeight.w600),
      titleMedium: style(size: 16, height: 1.3, weight: FontWeight.w600),
      bodyLarge: style(size: 16, height: 1.5),
      bodyMedium: style(size: 14, height: 1.45),
      labelLarge: style(size: 14, height: 1.3, weight: FontWeight.w600),
      labelMedium: style(size: 12, height: 1.3, weight: FontWeight.w500),
    );
  }
}
