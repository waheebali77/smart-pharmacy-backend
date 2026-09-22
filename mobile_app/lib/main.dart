import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'src/providers/auth_provider.dart';
import 'src/providers/theme_controller.dart';
import 'src/screens/splash_screen.dart';
import 'src/screens/pricing_carousel_screen.dart';
import 'src/services/api_service.dart';
import 'src/services/auth_service.dart';
import 'src/services/customer_service.dart';
import 'src/services/owner_service.dart';
import 'src/services/location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };
  ui.PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled application error: $error');
    debugPrintStack(stackTrace: stack);
    return true;
  };
  ErrorWidget.builder =
      (details) => Material(
        color: Colors.white,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Unable to render this screen.\nPlease restart the app.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
            ),
          ),
        ),
      );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const apiBaseUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'https://smart-pharmacy-backend-1.onrender.com/api',
    );

    final secureStorage = FlutterSecureStorage();
    late AuthProvider authProvider;
    final dio =
        ApiService.create(
          baseUrl: apiBaseUrl,
          secureStorage: secureStorage,
          onUnauthorized: () => authProvider.handleUnauthorized(),
        ).dio;

    final authService = AuthService(dio: dio, secureStorage: secureStorage);
    authProvider = AuthProvider(
      authService: authService,
      secureStorage: secureStorage,
    );
    final customerService = CustomerService(dio);
    final ownerService = OwnerService(dio);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        Provider<CustomerService>(create: (_) => customerService),
        Provider<OwnerService>(create: (_) => ownerService),
        Provider<LocationService>(create: (_) => LocationService(dio)),
      ],
      child: Consumer<ThemeController>(
        builder: (context, theme, _) {
          final localization = EasyLocalization.of(context);
          final locale = localization?.locale ?? const Locale('en');
          final isOwner = context.watch<AuthProvider>().isOwner;
          final primaryColor =
              isOwner ? const Color(0xFF005A9C) : const Color(0xFF4682B4);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Pharmacy',
            locale: locale,
            supportedLocales:
                localization?.supportedLocales ??
                const [Locale('en'), Locale('ar')],
            localizationsDelegates: localization?.delegates,
            routes: {
              '/pricing-carousel':
                  (_) => PricingCarouselScreen(ownerService: ownerService),
            },
            builder:
                (context, child) => Directionality(
                  textDirection:
                      locale.languageCode == 'ar'
                          ? ui.TextDirection.rtl
                          : ui.TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                ),
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                secondary: primaryColor,
                surface: const Color(0xFFFFFFFF),
                error: const Color(0xFFEF4444),
              ),
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.white,
              ),
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: Colors.white,
                elevation: 8,
                indicatorColor: primaryColor.withValues(alpha: 0.1),
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: primaryColor.withValues(alpha: 0.1),
                selectedColor: primaryColor,
                labelStyle: TextStyle(color: primaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            themeMode: theme.mode,
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: primaryColor,
                primary: primaryColor,
                secondary: primaryColor,
                surface: const Color(0xFF1E293B),
                brightness: Brightness.dark,
              ),
              scaffoldBackgroundColor: const Color(0xFF0F172A),
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: const Color(0xFF1E293B),
              ),
              appBarTheme: AppBarTheme(
                centerTitle: true,
                elevation: 0,
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              navigationBarTheme: NavigationBarThemeData(
                backgroundColor: const Color(0xFF1E293B),
                elevation: 8,
                indicatorColor: primaryColor.withValues(alpha: 0.2),
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: primaryColor.withValues(alpha: 0.2),
                selectedColor: primaryColor,
                labelStyle: TextStyle(color: primaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
