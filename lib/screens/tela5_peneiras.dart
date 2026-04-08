
import 'package:flutter/material.dart';

class PeneirasScreen extends StatelessWidget {
  const PeneirasScreen({super.key});


  static const List<Map<String, dynamic>> peneiras = [
    {
      'tipo': 'NOVA OPORTUNIDADE',
      'corTipo': Color(0xFF4CAF50), // verde
      'titulo': 'Avaliação Fluminense de Feira',
      'subtitulo': 'Sub-17 e Sub-20 | Estádio Joia da Princesa',
      'data': 'Data: 15/04/2026',
      'temData': true,
    },
    {
      'tipo': 'PROFISSIONAL',
      'corTipo': Color(0xFF2196F3), // azul
      'titulo': 'Teste para Lateral Direito',
      'subtitulo': 'Clube Atlético Baiano | Salvador-BA',
      'data': '',
      'temData': false,
    },
    {
      'tipo': 'BASE',
      'corTipo': Color(0xFFFF9800), // laranja
      'titulo': 'Peneira Sub-15 Esporte Clube',
      'subtitulo': 'Sub-15 | Campo Municipal - Feira de Santana',
      'data': 'Data: 22/04/2026',
      'temData': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Peneiras Abertas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: peneiras.length,
        itemBuilder: (context, index) {
          final peneira = peneiras[index];
          return _CardPeneira(peneira: peneira);
        },
      ),
    );
  }
}


class _CardPeneira extends StatelessWidget {
  final Map<String, dynamic> peneira;

  const _CardPeneira({required this.peneira});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(10),
        // Borda esquerda colorida de acordo com o tipo
        border: Border(
          left: BorderSide(
            color: peneira['corTipo'] as Color,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Text(
              peneira['tipo'] as String,
              style: TextStyle(
                color: peneira['corTipo'] as Color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 6),


            Text(
              peneira['titulo'] as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),


            Text(
              peneira['subtitulo'] as String,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),


            if (peneira['temData'] == true) ...[
              const SizedBox(height: 8),
              Text(
                peneira['data'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: 12),


            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Inscrição realizada com sucesso!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: peneira['corTipo'] as Color,
                  side: BorderSide(color: peneira['corTipo'] as Color),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'TENHO INTERESSE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
