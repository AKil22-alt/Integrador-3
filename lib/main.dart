// importando as bibliotecas necessárias para o funcionamento do aplicativo
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Certifique-se de que este arquivo existe no seu projeto
import 'login.dart'; 

Future<void> main() async {
  // Obrigatório ao usar métodos assíncronos (await) antes do runApp
  WidgetsFlutterBinding.ensureInitialized(); 
  
  await dotenv.load();
  
  // Aqui estava o erro: você deve passar a sua classe TelaApp, não um MaterialApp vazio
  runApp(const TelaApp()); 
}

// Cria a classe Tela App do tipo StatelessWidget
class TelaApp extends StatelessWidget {
  const TelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // retorna um material app que permite criar as telas do aplicativo
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: AnimatedSplashScreen(
        splash: Icons.home,
        splashIconSize: 200,
        splashTransition: SplashTransition.scaleTransition,
        pageTransitionType: PageTransitionType.leftToRight,
        nextScreen: const LoginPage(), // Assumindo que LoginPage seja const
        backgroundColor: Colors.red,
      ),
    );
  }
}