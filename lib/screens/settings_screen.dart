import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: ListTile(
          title: Text('Theme'),
          subtitle: Text('Change app theme'),
          trailing: DropdownButton<ThemeMode>(
            value: themeProvider.themeMode,
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
            onChanged: (ThemeMode mode) {
              themeProvider.setTheme(mode);
            },
          ),
        ));
  }
}
