import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatefulWidget {
  // ...existing code...
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  String _selectedLang = 'ro';

  @override
  void initState() {
    super.initState();
    final locale = Get.locale;
    _selectedLang = (locale?.languageCode ?? 'ro');
  }

  void _changeLanguage(String code) {
    setState(() => _selectedLang = code);
    Get.updateLocale(Locale(code));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings_title'.tr),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.person),
            title: Text('settings_account'.tr),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              // placeholder: navigate to account details/change password
              Get.snackbar('info'.tr, 'settings_account'.tr);
            },
          ),
          SwitchListTile(
            title: Text('settings_notifications'.tr),
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
          ),
          ListTile(
            title: Text('settings_language'.tr),
            subtitle: Text(
              _selectedLang == 'ro'
                  ? 'language_ro'.tr
                  : _selectedLang == 'en'
                      ? 'language_en'.tr
                      : 'language_ru'.tr,
            ),
          ),
          RadioListTile(
            title: Text('language_ro'.tr),
            value: 'ro',
            groupValue: _selectedLang,
            onChanged: (v) => _changeLanguage(v as String),
          ),
          RadioListTile(
            title: Text('language_en'.tr),
            value: 'en',
            groupValue: _selectedLang,
            onChanged: (v) => _changeLanguage(v as String),
          ),
          RadioListTile(
            title: Text('language_ru'.tr),
            value: 'ru',
            groupValue: _selectedLang,
            onChanged: (v) => _changeLanguage(v as String),
          ),
        ],
      ),
    );
  }
}

