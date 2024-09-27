import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _themePreference = 'System Default';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _themePreference = prefs.getString('theme') ?? 'System Default';
    });
  }

  _setThemePreference(String preference) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', preference);
    setState(() {
      _themePreference = preference;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Theme',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              title: const Text('Light'),
              leading: Radio<String>(
                value: 'Light',
                groupValue: _themePreference,
                onChanged: (value) {
                  _setThemePreference(value!);
                },
              ),
            ),
            ListTile(
              title: const Text('Dark'),
              leading: Radio<String>(
                value: 'Dark',
                groupValue: _themePreference,
                onChanged: (value) {
                  _setThemePreference(value!);
                },
              ),
            ),
            ListTile(
              title: const Text('System Default'),
              leading: Radio<String>(
                value: 'System Default',
                groupValue: _themePreference,
                onChanged: (value) {
                  _setThemePreference(value!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
