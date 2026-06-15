// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'utils/app_colors.dart';
import 'services/auth_service.dart';
import 'services/atleta_service.dart';
import 'services/chat_service.dart';
import 'screens/auth/tela_boas_vindas.dart';
import 'screens/atleta/tela_home_atleta.dart';
import 'screens/olheiro/tela_home_olheiro.dart';
import 'models/usuario_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BaseProApp());
}

class BaseProApp extends StatelessWidget {
  const BaseProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<AtletaService>(create: (_) => AtletaService()),
        Provider<ChatService>(create: (_) => ChatService()),
      ],
      child: MaterialApp(
        title: 'BasePro',
        debugShowCheckedModeBanner: false,
        theme: appTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.verde),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const TelaBoasVindas();
        }

        // Usuário logado — buscar tipo para redirecionar
        return FutureBuilder<UsuarioModel?>(
          future: authService.buscarUsuarioAtual(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Colors.black,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.verde),
                ),
              );
            }

            final usuario = userSnap.data;
            if (usuario == null) return const TelaBoasVindas();

            if (usuario.tipo == TipoUsuario.olheiro) {
              return const TelaHomeOlheiro();
            }
            return const TelaHomeAtleta();
          },
        );
      },
    );
  }
}
