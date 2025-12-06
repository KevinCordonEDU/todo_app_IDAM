import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'services/mongo_service.dart';

// Clase para ignorar errores de certificado SSL (Solo desarrollo/emuladores)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Activar Override de SSL
  HttpOverrides.global = MyHttpOverrides();

  // 2. Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // 3. Conectar a BD
  await MongoService.connect();

  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modern To-Do',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}