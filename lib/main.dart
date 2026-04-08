
import 'package:flutter/material.dart';
import 'screens/tela1_welcome.dart';

void main() {

  runApp(const BaseProApp());
}

class BaseProApp extends StatelessWidget {
  const BaseProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BasePro',

 
      debugShowCheckedModeBanner: false,


      theme: ThemeData(

        brightness: Brightness.dark,


        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CAF50),
          brightness: Brightness.dark,
        ),

  
        fontFamily: 'Roboto',


        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
        ),

        useMaterial3: true,
      ),


      home: const WelcomeScreen(),
    );
  }
}
