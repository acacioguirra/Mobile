

import 'package:flutter/material.dart';
import 'tela3_perfil.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});


  static const List<Map<String, String>> atletas = [
    {
      'nome': 'João Silva',
      'idade': '17 anos',
      'posicao': 'Atacante',
      'cidade': 'Feira de Santana',
    },
    {
      'nome': 'Carlos Souza',
      'idade': '19 anos',
      'posicao': 'Meia',
      'cidade': 'Salvador',
    },
    {
      'nome': 'Matheus Brito',
      'idade': '19 anos',
      'posicao': 'Meio-Campo',
      'cidade': 'Alagoinhas',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E), 
        title: const Text(
          'Feed de Destaques',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),


      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: atletas.length,
        itemBuilder: (context, index) {
          final atleta = atletas[index];


          return _CardVideo(atleta: atleta);
        },
      ),
    );
  }
}


class _CardVideo extends StatelessWidget {
  final Map<String, String> atleta;

  const _CardVideo({required this.atleta});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilScreen(atleta: atleta),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2333), // fundo azul escuro
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4CAF50), // borda verde
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Color(0xFF2A3550),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_fill,
                      color: Color(0xFF4CAF50),
                      size: 52,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vídeo do Atleta',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome em destaque
                  Text(
                    '${atleta['nome']}, ${atleta['idade']}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${atleta['posicao']} - ${atleta['cidade']}',
                    style: const TextStyle(
                      color: Color(0xFF4CAF50),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
