import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'providers/shift_providers.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  
  // Load persisted shift duration preference
  final container = ProviderContainer();
  final prefsService = container.read(preferencesServiceProvider);
  final savedDuration = await prefsService.loadShiftDuration();
  container.read(shiftDurationProvider.notifier).state = savedDuration;
  
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const KpaShiftApp(),
    ),
  );
}

class KpaShiftApp extends StatelessWidget {
  const KpaShiftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kpa Work Time',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigationScreen(),
    );
  }
}
