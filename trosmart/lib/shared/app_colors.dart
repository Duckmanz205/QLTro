import 'package:flutter/material.dart';

class AppColors {
  // ===== MÀU CHỦ ĐẠO =====
  static const Color primaryPurple = Color(0xFFB794F4);

  // ===== MÀU ADMIN =====
  static const Color adminDarkPurple = Color(0xFF6A3092);
  static const Color accentTeal = Color(0xFF2DDCB1);
  static const Color statusOrange = Color(0xFFFF9800);

  // ===== BACKGROUND & TEXT =====
  static const Color backgroundGray = Color(0xFFF8F7FA);
  static const Color textDark = Color(0xFF1A0D2D);
  static const Color textLight = Color(0xFF999999);

  // ===== GRADIENT =====
  static const LinearGradient adminHeaderGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFA161D2),
      Color(0xFF64417F),
      Color(0xFF27202C),
    ],
  );

  // ===== MÀU BỔ SUNG =====
  static const Color darkAccent = Color(0xFF27202C);
  static const Color warningLightBg = Color(0xFFFFF3E0); 
  static const Color purpleLightBg = Color(0xFFF3E5F5); 
  static const Color purpleBorder = Color(0xFFE1BEE7); 
  static const Color dividerLight = Color(0xFFF5F5F5); 
  
  // Màu đặc thù cho Quản lý Điện Nước
  static const Color utilityPurpleLight = Color(0xFF9D50CF);
  static const Color utilityPurpleDark = Color(0xFF4D2A72);
  static const Color utilityTealLight = Color(0xFFE5FDF8);
  static const Color utilityDarkCard = Color(0xFF362E40);
  static const Color utilityGray = Color(0xFF8C8C91);
  static const Color utilityBorder = Color(0xFFE8E8EE);

  // ===== MÀU ĐẶC THÙ CHO QUẢN LÝ SỰ CỐ =====
  static const Color statusPending = Color(0xFFFB923C);    // Cam (Chờ xử lý)
  static const Color statusProcessing = Color(0xFF60A5FA); // Xanh dương (Đang xử lý)
  static const Color statusUrgent = Color(0xFFF87171);     // Đỏ (Khẩn cấp/Từ chối)
  
  static const Color incidentBg1 = Color(0xFF9D69BA); // Nền thẻ sự cố tím nhạt
  static const Color incidentBg2 = Color(0xFF8A58A8); // Nền thẻ sự cố tím đậm hơn
  static const Color incidentBg3 = Color(0xFFA782BE); // Nền thẻ sự cố tím sáng

  // ===== MÀU ĐẶC THÙ CHO KHÁCH THUÊ (USER) - Bổ sung mới =====
  static const Color tealDark = Color(0xFF0D9488); 
  static const Color userPurple = Color(0xFFA855F7); 
  static const Color userPurpleLight = Color(0xFFC084FC); 
  static const Color textMuted = Color(0xFF6B7280); 
  static const Color userBorder = Color(0xFFF3F4F6); 

  // Các màu còn thiếu trích xuất từ form Báo cáo sự cố
  static const Color textMain = Color(0xFF1F2937);
  static const Color userTeal = Color(0xFF2DD4BF);
  static const Color userBgLight = Color(0xFFF9FAFB);
  static const Color userTealLightBg = Color(0xFFF0FDFA);
  static const Color userTealBorder = Color(0xFFE0F2F1);
  static const Color userStarGold = Color(0xFFF59E0B);
}