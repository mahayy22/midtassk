import 'package:flutter/material.dart';

class AccentOption {
  const AccentOption({
    required this.key,
    required this.label,
    required this.color,
  });

  final String key;
  final String label;
  final Color color;
}

class AppPalette {
  static const Color background = Color(0xFFF9F9FC);
  static const Color surface = Color(0xFFF9F9FC);
  static const Color surfaceContainerLow = Color(0xFFF3F3F6);
  static const Color surfaceContainer = Color(0xFFEEEEF0);
  static const Color surfaceContainerHigh = Color(0xFFE8E8EA);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E5);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF454652);
  static const Color outline = Color(0xFF757684);
  static const Color outlineVariant = Color(0xFFC5C5D4);
  static const Color success = Color(0xFF1B6D24);
  static const Color successContainer = Color(0xFFA0F399);
  static const Color tertiary = Color(0xFF712F00);
  static const Color tertiaryContainer = Color(0xFFFFDBCA);
  static const Color error = Color(0xFFBA1A1A);
  static const Color darkBackground = Color(0xFF0F1320);
  static const Color darkSurface = Color(0xFF151A28);
  static const Color darkSurfaceContainer = Color(0xFF1A2132);
  static const Color darkSurfaceContainerHigh = Color(0xFF20283B);
  static const Color darkOnSurface = Color(0xFFF0F0F3);
  static const Color darkOnSurfaceVariant = Color(0xFFAEB2C3);

  static const List<AccentOption> accentOptions = <AccentOption>[
    AccentOption(key: 'indigo', label: 'Indigo', color: Color(0xFF24389C)),
    AccentOption(key: 'green', label: 'Green', color: Color(0xFF1B6D24)),
    AccentOption(key: 'amber', label: 'Amber', color: Color(0xFF964100)),
    AccentOption(key: 'violet', label: 'Violet', color: Color(0xFF6750A4)),
    AccentOption(key: 'red', label: 'Red', color: Color(0xFFB3261E)),
  ];

  static Color accentColorForKey(String key) {
    for (final option in accentOptions) {
      if (option.key == key) {
        return option.color;
      }
    }
    return accentOptions.first.color;
  }
}
