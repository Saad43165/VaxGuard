import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme.dart';
import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/triage_quiz_screen.dart';
import 'screens/triage_result_screen.dart';
import 'screens/first_aid_screen.dart';
import 'screens/vaccine_schedule_screen.dart';
import 'screens/hospital_map_screen.dart';
import 'screens/dashboard_screen.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'utils/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize services
  await DatabaseService.instance.initialize();
  await NotificationService.instance.initialize();

  runApp(const VaxGuardApp());
}

class VaxGuardApp extends StatelessWidget {
  const VaxGuardApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaxGuard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppConstants.splashRoute,
      routes: {
        AppConstants.splashRoute: (context) => const SplashScreen(),
        AppConstants.homeRoute: (context) => const HomeScreen(),
        AppConstants.triageRoute: (context) => const TriageQuizScreen(),
        AppConstants.triageResultRoute: (context) => const TriageResultScreen(),
        AppConstants.firstAidRoute: (context) => const FirstAidScreen(),
        AppConstants.vaccineScheduleRoute: (context) =>
            const VaccineScheduleScreen(),
        AppConstants.hospitalMapRoute: (context) => const HospitalMapScreen(),
        AppConstants.dashboardRoute: (context) => const DashboardScreen(),
      },
    );
  }
}
