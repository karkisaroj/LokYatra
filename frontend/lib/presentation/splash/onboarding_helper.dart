import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';

Future<void> markOnboardingSeen() async {
  if (kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
  } else {
    await SqliteService().put('has_seen_onboarding', true);
  }
}