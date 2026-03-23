import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class ThemeManager {
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isDark = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isDark ? 'Dark' : 'Light',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Switch(
          value: isDark,
          onChanged: (val) async {
            themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isDarkMode', val);
          },
        ),
      ],
    );
  }
}
