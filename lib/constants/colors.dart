import 'package:flutter/material.dart';

class AppColors {
  
  static const Color primary = Color(0xFFE53E3E);           
  static const Color primaryLight = Color(0xFFED6A6A);     
  
  static const Color secondary = Color(0xFFD4AF37);        
  static const Color secondaryLight = Color(0xFFE6C555);
  static const Color secondaryDark = Color(0xFFB8941F); 
  
  static const Color accent = Color(0xFF4F46E5);            
  static const Color accentLight = Color(0xFF6366F1);     
  static const Color accentDark = Color(0xFF3730A3);      
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFAFAFA);    
  static const Color surface = Color(0xFFFFFFFF);          
  static const Color surfaceVariant = Color(0xFFF5F5F7);    
  
  static const Color textPrimary = Color(0xFF1A1A1A);   
  static const Color textSecondary = Color(0xFF6B7280);  
  static const Color textHint = Color(0xFF9CA3AF);         
  
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);
  
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);
  
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  

  static const Color border = Color(0xFFE5E7EB);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFFD1D5DB);
  
  static const Color shadow = Color(0x1A000000);       
  static const Color shadowMedium = Color(0x33000000);  
  static const Color shadowStrong = Color(0x4D000000);
  
  
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color disabledText = Color(0xFF9CA3AF);
  
  
  static const Color overlay = Color(0x80000000);        
  static const Color overlayLight = Color(0x40000000);  
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryLight, secondary],
  );
  
  static const LinearGradient saarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, secondary],
  );
  
}