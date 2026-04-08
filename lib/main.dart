import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/app_settings_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/order_provider.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';
import 'package:device_preview/device_preview.dart';
void main() async {
  // Garante que o Flutter está pronto antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // Liga o banco de dados
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => const ChoperiaApp(), 
    ),
  );
}

class ChoperiaApp extends StatelessWidget {
  const ChoperiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppSettingsProvider>(
          create: (_) => AppSettingsProvider(),
        ),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider<MenuProvider>(create: (_) => MenuProvider()),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<OrderProvider>(create: (_) => OrderProvider()),
      ],
      child: Consumer<AppSettingsProvider>(
        builder: (_, AppSettingsProvider settings, _) {
          return MaterialApp(
            builder: DevicePreview.appBuilder,
            locale: DevicePreview.locale(context), 
            title: 'Choperia 820',
            debugShowCheckedModeBanner: false,
            supportedLocales: const <Locale>[
              Locale('pt'),
             
            ],
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: settings.themeMode,
            onGenerateRoute: AppRoutes.onGenerateRoute,
            initialRoute: AppRoutes.splash,
          );
        },
      ),
    );
  }
}
