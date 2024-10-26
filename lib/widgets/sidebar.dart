// lib/widgets/sidebar.dart

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../database/db_helper.dart';

class SideBar extends StatelessWidget {
  Future<void> _exportData(BuildContext context) async {
    try {
      String csvData = await DBHelper.instance.exportData();

      // Let the user pick a location to save the file
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save exported data as',
        fileName: 'goals_backup.csv',
      );

      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(csvData);
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
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        final file = File(filePath);
        String csvData = await file.readAsString();

        await DBHelper.instance.importData(csvData);
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
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Text(
              'Goal Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_week),
            title: Text('Week View'),
            onTap: () {
              Navigator.pushNamed(context, '/week_view');
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Month View'),
            onTap: () {
              Navigator.pushNamed(context, '/month_view');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.import_export),
            title: Text('Export Data'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: Icon(Icons.file_upload),
            title: Text('Import Data'),
            onTap: () => _importData(context),
          ),
        ],
      ),
    );
  }
}
