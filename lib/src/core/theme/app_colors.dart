import 'package:flutter/material.dart';

/// 트렌디한 색상 조합
/// 라이트 모드: 부드러운 파스텔톤 기반
/// 다크 모드: 모던한 다크 테마 with 네온 액센트
class AppColors {
  // Light Theme Colors
  static const Color lightPrimary = Color(0xFF6366F1); // Indigo 500 - 모던한 인디고
  static const Color lightPrimaryVariant = Color(0xFF4F46E5); // Indigo 600
  static const Color lightSecondary = Color(0xFFF59E0B); // Amber 500 - 따뜻한 앰버
  static const Color lightSecondaryVariant = Color(0xFFD97706); // Amber 600
  static const Color lightBackground = Color(0xFFF9FAFB); // Gray 50 - 부드러운 회색 배경
  static const Color lightSurface = Color(0xFFFFFFFF); // 순백색
  static const Color lightError = Color(0xFFEF4444); // Red 500
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF111827); // Gray 900
  static const Color lightOnSurface = Color(0xFF1F2937); // Gray 800
  static const Color lightOnError = Color(0xFFFFFFFF);
  
  // Dark Theme Colors
  static const Color darkPrimary = Color(0xFF818CF8); // Indigo 400 - 밝은 인디고
  static const Color darkPrimaryVariant = Color(0xFFA78BFA); // Purple 400
  static const Color darkSecondary = Color(0xFFFBBF24); // Amber 400 - 네온 앰버
  static const Color darkSecondaryVariant = Color(0xFFFCD34D); // Amber 300
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900 - 딥 다크
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkError = Color(0xFFF87171); // Red 400
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFF000000);
  static const Color darkOnBackground = Color(0xFFF3F4F6); // Gray 100
  static const Color darkOnSurface = Color(0xFFE5E7EB); // Gray 200
  static const Color darkOnError = Color(0xFF000000);
  
  // Shared Colors
  static const Color dividerLight = Color(0xFFE5E7EB); // Gray 200
  static const Color dividerDark = Color(0xFF374151); // Gray 700
  
  // Card Colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E293B); // Slate 800
  
  // Success/Warning Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
}