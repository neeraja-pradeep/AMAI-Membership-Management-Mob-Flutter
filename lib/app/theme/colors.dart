import 'dart:math';

import 'package:flutter/material.dart';

/// App color palette for AMAI application
class AppColors {
  AppColors._();

  // ============== Primary Colors ==============
  static const Color primary = Color(0xFF1E3A5F);
  static const Color primaryLight = Color(0xFF4A6FA5);
  static const Color primaryDark = Color(0xFF0D1F33);

  static const Color newPrimaryLight = Color(0xFF854854);

  // ============== Secondary Colors ==============
  static const Color secondary = Color(0xFFFFB74D);
  static const Color secondaryLight = Color(0xFFFFD180);
  static const Color secondaryDark = Color(0xFFF57C00);

  // ============== Status Colors ==============
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFFE3F2FD);

  // ============== Neutral Colors ==============
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ============== Background Colors ==============
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color scaffoldBackground = Color(0xFFF5F7FA);

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0062, 0.9556],
    colors: [
      Color(0xFFFFF6F6), // #FFF6F6
      Color(0xFFFFFFFF), // #FFFFFF
    ],
    transform: GradientRotation(178.93 * pi / 180),
  );

  // ============== Text Colors ==============
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF212121);

  // ============== Card Colors ==============
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1A000000);

  // ============== Membership Card Colors ==============
  static const Color membershipCardGradientStart = Color(0xFF1E3A5F);
  static const Color membershipCardGradientEnd = Color(0xFF4A6FA5);
  static const Color membershipCardText = Color(0xFFFFFFFF);
  static const Color membershipCardAccent = Color(0xFFFFB74D);

  // ============== Aswas Plus Card Colors ==============
  static const Color aswasCardGradientStart = Color(0xFF00695C);
  static const Color aswasCardGradientEnd = Color(0xFF26A69A);
  static const Color aswasCardText = Color(0xFF4C0708);
  static const Color aswasCardAccent = Color(0xFFB2DFDB);

  // ============== Event Card Colors ==============
  static const Color eventCardBackground = Color(0xFFFFFFFF);
  static const Color eventCardOverlay = Color(0x80000000);
  static const Color eventDateBadge = Color(0xFF1E3A5F);
  static const Color eventDateBadgeText = Color(0xFFFFFFFF);
  static const Color eventPriceBadge = Color(0xFF4CAF50);
  static const Color eventPriceBadgeText = Color(0xFFFFFFFF);
  static const Color eventRegisterButton = Color(0xFF1E3A5F);
  static const Color eventRegisterButtonText = Color(0xFFFFFFFF);

  // ============== Status Badge Colors ==============
  static const Color activeBadge = Color(0xFFFFDDDD);
  static const Color activeBadgeText = Color(0xFF4C0708);
  static const Color inactiveBadge = Color(0xFF9E9E9E);
  static const Color inactiveBadgeText = Color(0xFFFFFFFF);
  static const Color expiredBadge = Color(0xFFE53935);
  static const Color expiredBadgeText = Color(0xFFFFFFFF);
  static const Color expiringSoonBadge = Color(0xFFFF9800);
  static const Color expiringSoonBadgeText = Color(0xFFFFFFFF);

  // ============== Divider Colors ==============
  static const Color divider = Color(0xFFE0E0E0);
  static const Color dividerLight = Color(0xFFF5F5F5);
}
