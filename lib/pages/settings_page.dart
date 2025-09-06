import 'package:flutter/material.dart';
import '../core/business_mode.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Notification'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text('Dark mode'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
            secondary: const Icon(Icons.dark_mode),
          ),
          // 🔥 Business Mode toggle
          ValueListenableBuilder<bool>(
            valueListenable: BusinessMode.enabled,
            builder: (context, enabled, _) {
              return SwitchListTile(
                title: const Text('Business mode'),
                value: enabled,
                onChanged: (value) {
                  BusinessMode.enabled.value = value;
                },
                secondary: const Icon(Icons.business_center),
              );
            },
          ),
        ],
      ),
    );
  }
}
