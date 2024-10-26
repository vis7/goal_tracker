// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../widgets/sidebar.dart'; // Added import for SideBar

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      drawer: SideBar(), // Include the drawer to have the menu icon
      body: ListView(
        children: [
          ListTile(
            title: Text('Theme'),
            subtitle: Text('Select your preferred theme'),
            trailing: DropdownButton<ThemeMode>(
              value: themeProvider.getThemeMode,
              items: [
                DropdownMenuItem(
                  child: Text('System Default'),
                  value: ThemeMode.system,
                ),
                DropdownMenuItem(
                  child: Text('Light'),
                  value: ThemeMode.light,
                ),
                DropdownMenuItem(
                  child: Text('Dark'),
                  value: ThemeMode.dark,
                ),
              ],
              onChanged: (ThemeMode? newThemeMode) {
                if (newThemeMode != null) {
                  themeProvider.setThemeMode(newThemeMode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
