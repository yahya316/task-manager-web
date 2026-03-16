import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _defaultHostedBaseUrl =
      'https://wholesome-possibility-production.up.railway.app/api';
  static const String _envBaseUrl = String.fromEnvironment('BACKEND_URL');
  static const String _envAndroidBaseUrl =
      String.fromEnvironment('BACKEND_URL_ANDROID');
  static const String _envIosBaseUrl =
      String.fromEnvironment('BACKEND_URL_IOS');

  // BACKEND_URL applies to all platforms.
  // BACKEND_URL_ANDROID and BACKEND_URL_IOS can override platform-specific URLs.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (kIsWeb) return _defaultHostedBaseUrl;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        if (_envAndroidBaseUrl.isNotEmpty) return _envAndroidBaseUrl;
        return _defaultHostedBaseUrl;
      }
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        if (_envIosBaseUrl.isNotEmpty) return _envIosBaseUrl;
        return _defaultHostedBaseUrl;
      }
    } catch (_) {}
    return _defaultHostedBaseUrl;
  }

  // Status colors - Modern & Vibrant
  static const Color pendingColor = Color(0xFFF59E0B); // Amber
  static const Color inProgressColor = Color(0xFF6366F1); // Indigo
  static const Color completedColor = Color(0xFF10B981); // Emerald
  static const Color cancelledColor = Color(0xFFEF4444); // Rose

  // Theme colors - Premium Slate & Indigo
  static const Color primaryColor = Color(0xFF4F46E5); // Rich Indigo
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryDark = Color(0xFF3730A3);

  static const Color surfaceColor = Color(0xFFF8FAFC); // Slate 50
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color dividerColor = Color(0xFFE2E8F0); // Slate 200

  // Accents
  static const Color accentIndigo = Color(0xFF818CF8);
  static const Color accentTeal = Color(0xFF2DD4BF);
  static const Color accentRose = Color(0xFFFB7185);

  static Color getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return pendingColor;
      case 'In Progress':
        return inProgressColor;
      case 'Completed':
        return completedColor;
      case 'Cancelled':
        return cancelledColor;
      default:
        return textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status) {
      case 'Pending':
        return Icons.access_time_rounded;
      case 'In Progress':
        return Icons.rotate_right_rounded;
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}
