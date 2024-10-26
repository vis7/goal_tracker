import 'package:flutter/material.dart';
import 'package:goal_tracker/utils/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            title: Text('System Default'),
            value: ThemeMode.system,
            groupValue: themeProvider.getThemeMode,
            onChanged: (value) {
              themeProvider.setTheme(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text('Light Theme'),
            value: ThemeMode.light,
            groupValue: themeProvider.getThemeMode,
            onChanged: (value) {
              themeProvider.setTheme(value!);
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text('Dark Theme'),
            value: ThemeMode.dark,
            groupValue: themeProvider.getThemeMode,
            onChanged: (value) {
              themeProvider.setTheme(value!);
            },
          ),
        ],
      ),
    );
  }
}
