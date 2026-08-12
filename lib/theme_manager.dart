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
    return IconButton(
      icon: Icon(
        isDark ? Icons.light_mode : Icons.dark_mode,
        color: Colors.white,
      ),
      tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
      onPressed: () async {
        final newIsDark = !isDark;
        themeNotifier.value = newIsDark ? ThemeMode.dark : ThemeMode.light;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDarkMode', newIsDark);
      },
    );
  }
}
