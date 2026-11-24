import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:recetas_app/screens/splash_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactory, databaseFactoryFfi, sqfliteFfiInit;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const RecetasApp());
}

class RecetasApp extends StatelessWidget {
  const RecetasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Recetas del Mayab",
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
