# KpaHours - تطبيق تتبع ساعات العمل ومؤشرات الأداء (KPI)

تطبيق أندرويد تم بناؤه باستخدام **Flutter** بهيكل Clean / Feature-First Architecture.

## 📁 هيكل المشروع (Project Architecture)

```
lib/
├── core/
│   ├── constants/       # ألوان وثوابت التطبيق (AppColors, AppStrings)
│   ├── network/         # أدوات الاتصال بالـ API و XAMPP (ApiClient, ApiEndpoints)
│   ├── theme/           # ثيم التطبيق المظلم والفاتح (AppTheme)
│   ├── utils/           # الدوال المساعدة والتحقق
│   └── widgets/         # العناصر المشتركة (CustomButton, CustomTextField...)
├── features/
│   ├── auth/            # المصادقة وتسجيل الدخول
│   ├── dashboard/       # لوحة التحكم ومؤشرات الأداء اليومية والشهرية
│   └── hours_tracking/  # تسجيل وتتبع ساعات العمل والمهام
└── main.dart            # نقطة انطلاق التطبيق مع دعم كامل للغة العربية (RTL)
```

## 🚀 كيفية التشغيل
1. تأكد من تثبيت Flutter SDK.
2. تشغيل جلب الحزم:
   ```bash
   flutter pub get
   ```
3. تشغيل التطبيق على محاكي أو جهاز أندرويد:
   ```bash
   flutter run
   ```
