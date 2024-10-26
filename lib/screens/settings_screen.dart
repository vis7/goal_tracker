// lib/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../widgets/sidebar.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../database/db_helper.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> _exportData(BuildContext context) async {
    try {
      String jsonData = await DBHelper.instance.exportData();

      // Let the user pick a location to save the file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save exported data as',
        fileName: 'goals_backup.json',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(jsonData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data exported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }

  Future<void> _importData(BuildContext context) async {
    try {
      // Let the user pick the file to import
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        final file = File(filePath);
        String jsonData = await file.readAsString();

        await DBHelper.instance.importData(jsonData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data imported successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error importing data: $e')),
      );
    }
  }

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
          Divider(),
          ListTile(
            leading: Icon(Icons.import_export),
            title: Text('Export Data'),
            subtitle: Text('Export your goals and achievements'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Import Data'),
            subtitle: Text('Import goals and achievements from a file'),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }
}
