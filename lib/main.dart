import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:sales_force/config/theme/app_theme.dart';
import 'package:sales_force/presentation/cobranzas/providers/cobros_providers.dart';
import 'package:sales_force/presentation/perfil/perfil.dart';
import 'package:sales_force/presentation/products/products_screen.dart';
import 'package:sales_force/presentation/screen/configuracion/config_screen.dart';
import 'package:sales_force/presentation/screen/home/home_screen.dart';
import 'package:sales_force/presentation/screen/informacion/informacion.dart';
import 'package:sales_force/presentation/screen/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sales_force/presentation/screen/visits/providers/visit_add_new_provider.dart';
import 'package:sales_force/presentation/screen/visits/providers/visits_planned_providers.dart';
import 'package:sales_force/presentation/screen/visits/providers/visits_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sizer/sizer.dart';

class AppInitializer {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
    if (isFirstTime) {
      prefs.setBool("isFirstTime", false);
    }
    requestPermissions();
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => VisitsProvider()),
      ChangeNotifierProvider(create: (_) => VisitsPlannedProvider()),
      ChangeNotifierProvider(create: (_) => VisitsNewProvider()),

    ], child: MyApp(initialRoute: isFirstTime ? '/configuracion' : '/')));
  }
}

void requestPermissions() async {
  // Solicitar permisos de acceso a la cámara y a la galería
  Location location = Location();

  await Permission.camera.request();
}

void main() {
  AppInitializer.initialize();

  // runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          initialRoute: widget.initialRoute,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
          ],
          locale: const Locale(
              'es', 'ES'), // Establece el idioma predeterminado a español

          debugShowCheckedModeBanner: false,
          title: 'Sales Force GSS',
          theme: AppTheme(selectedColor: 0).theme(),
          routes: {
            '/': (context) => const Login(),
            '/configuracion': (context) => const Configuracion(),
            '/home': (context) => const Home(),
            '/perfil': (context) => const Perfil(),
            '/products': (context) => const Products(),
            '/informacion': (context) => const Informacion(),
          },
        );
      },
    );
  }
}
