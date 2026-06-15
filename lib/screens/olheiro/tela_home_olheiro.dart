// lib/screens/olheiro/tela_home_olheiro.dart

import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../shared/tela_busca.dart';
import '../shared/tela_chat_lista.dart';
import 'tela_perfil_olheiro.dart';

class TelaHomeOlheiro extends StatefulWidget {
  const TelaHomeOlheiro({super.key});

  @override
  State<TelaHomeOlheiro> createState() => _TelaHomeOlheiroState();
}

class _TelaHomeOlheiroState extends State<TelaHomeOlheiro> {
  int _abaSelecionada = 0;

  final List<Widget> _telas = const [
    TelaBusca(),
    TelaChatLista(),
    TelaPerfilOlheiro(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _telas[_abaSelecionada],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaSelecionada,
        onTap: (i) => setState(() => _abaSelecionada = i),
        backgroundColor: AppColors.azulEscuro,
        selectedItemColor: AppColors.verde,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
