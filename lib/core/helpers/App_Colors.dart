import 'package:flutter/material.dart';

class AppColors {
  // الألوان الأساسية للوحة التحكم (Admin Dashboard)
  static const Color primary = Color(0xff246BFD); // اللون الأساسي (الأزرق)
  static const Color lightPrimary = Color(
    0xffE9F0FF,
  ); // أزرق فاتح جداً (للخلفيات الصغيرة أو الـ Active States)
  static const Color scaffoldBackground = Color(
    0xffFFFFFF,
  ); // خلفية التطبيق الأساسية
  static const Color cardBackground = Color(
    0xffFAFAFA,
  ); // خلفية الكروت والجداول المريحة للعين

  // ألوان النصوص
  static const Color textPrimary = Color(
    0xff212121,
  ); // لون النص الأساسي (العناوين والأرقام المهمة)
  static const Color textSecondary = Color(
    0xff757575,
  ); // لون النص الثانوي (العناوين الفرعية)
  static const Color textTertiary = Color(
    0xff9E9E9E,
  ); // لون النص الثالثي (التواريخ أو الملاحظات الجانبية)
  static const Color darkHeader = Color(
    0xff1E293B,
  ); // أزرق داكن لعناوين الجدول والهيدر العلوية

  // حقول الإدخال والحدود والخلفيات
  static const Color textField = Color(0xffF5F5F5); // خلفية حقول الإدخال
  static const Color borderColor = Color(
    0xffE0E0E0,
  ); // لون الحدود للجداول أو الكروت
  static const Color pageBackground = Color(
    0xffF8FAFC,
  ); // خلفية الصفحة العامة خارج الكروت

  // ألوان الحالات الإدارية (Status Colors)
  static const Color success = Color(0xff4CAF50); // أخضر: مقبول / مدفوع / نشط
  static const Color successLight = Color(0xffE8F5E9); // خلفية الفاتح للمقبول

  static const Color error = Color(0xffF44336); // أحمر: مرفوض / ملغي / معطل
  static const Color errorLight = Color(0xffFFEBEE); // خلفية الفاتح للمرفوض

  static const Color warning = Color(
    0xffFF9800,
  ); // برتقالي: قيد الانتظار / معلق / مراجعة
  static const Color warningLight = Color(0xffFFF3E0); // خلفية الفاتح للمعلق

  // ✨ ألوان إضافية تم استخراجها خصيصاً للتصميم (أزرار الجدول والتفاصيل)
  static const Color info = Color(0xff0EA5E9); // سماوي/أزرق للتفاصيل والملفات
  static const Color infoLight = Color(0xffE0F2FE); // خلفية الإجراءات السماوية

  static const Color edit = Color(0xffF59E0B); // برتقالي للـ Edit
  static const Color editLight = Color(0xffFEF3C7); // خلفية زر التعديل

  static const Color star = Color(
    0xffF59E0B,
  ); // لون نجمة التقييم (الذهبي/البرتقالي)
}
