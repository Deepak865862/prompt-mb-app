import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'config/theme.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Status bar ko transparent aur light icons wala banata hai
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const PromptMBApp());
}

class PromptMBApp extends StatelessWidget {
  const PromptMBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prompt MB',
      debugShowCheckedModeBanner: false, // "DEBUG" label hatane ke liye
      theme: AppTheme.darkTheme,
      home: const SplashScreen(), // Sabse pehle Splash Screen dikhayega
    );
  }
}
