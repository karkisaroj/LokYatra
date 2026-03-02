import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/Helpers/SecureStorageService.dart';
import 'package:lokyatra_frontend/core/services/sqlite_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    if (!_hasNavigated) {
      Future.delayed(const Duration(seconds: 2), _checkAuth);
    }
  }

  Future<void> _checkAuth() async {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    bool seenOnboarding = false;

    if (kIsWeb) {
      // sqflite does not work on web — use SharedPreferences instead
      final prefs = await SharedPreferences.getInstance();
      seenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    } else {
      final sqlite = SqliteService();
      await sqlite.database;
      final val = await sqlite.get('has_seen_onboarding');
      seenOnboarding = val != null;
    }

    debugPrint('has_seen_onboarding → $seenOnboarding');

    if (!mounted) return;

    if (!seenOnboarding) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    final token = await SecureStorageService.getAccessToken();

    if (!mounted) return;

    if (token == null || JwtDecoder.isExpired(token)) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final decoded = JwtDecoder.decode(token);
      final role = decoded['role'] ??
          decoded['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];

      if (!mounted) return;

      if (role == 'tourist') {
        Navigator.pushReplacementNamed(context, '/touristHome');
      } else if (role == 'owner') {
        Navigator.pushReplacementNamed(context, '/ownerHome');
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/adminDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      debugPrint('JWT decode error: $e');
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/lokyatra_logo.png', height: 120),
            const SizedBox(height: 24),
            const Text(
              "Explore Nepal's \nCultural Heritage",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            const Text('Loading...', style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}