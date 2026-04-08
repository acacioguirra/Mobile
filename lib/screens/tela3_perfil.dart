
import 'package:flutter/material.dart';
import 'tela6_chat.dart';

class PerfilScreen extends StatelessWidget {

  final Map<String, String> atleta;

  const PerfilScreen({super.key, required this.atleta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Perfil do Atleta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: SingleChildScrollView(
        // SingleChildScrollView permite rolar o conteúdo
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF4CAF50), // círculo verde
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              atleta['nome'] ?? 'Atleta',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              '${atleta['posicao'] ?? 'Posição'} | Canhoto',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2333),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MetricaItem(valor: '1.78m', label: 'Altura'),
                  // Divisor vertical entre métricas
                  Container(width: 1, height: 40, color: Colors.grey[700]),
                  _MetricaItem(valor: '72kg', label: 'Peso'),
                  Container(width: 1, height: 40, color: Colors.grey[700]),
                  _MetricaItem(
                    valor: atleta['idade']?.replaceAll(' anos', '') ?? '19',
                    label: 'Idade',
                    corValor: const Color(0xFF4CAF50), // idade em verde
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Habilidades Validadas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChipHabilidade(texto: 'Visão de Jogo +5'),
                _ChipHabilidade(texto: 'Passe Curto +3'),
                _ChipHabilidade(texto: 'Velocidade +4'),
                _ChipHabilidade(texto: 'Drible +2'),
              ],
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        nomeContato: atleta['nome'] ?? 'Atleta',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text(
                  'ENVIAR MENSAGEM',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

class _MetricaItem extends StatelessWidget {
  final String valor;
  final String label;
  final Color corValor;

  const _MetricaItem({
    required this.valor,
    required this.label,
    this.corValor = const Color(0xFF4FC3F7), // azul padrão
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          valor,
          style: TextStyle(
            color: corValor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _ChipHabilidade extends StatelessWidget {
  final String texto;

  const _ChipHabilidade({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A237E), // azul escuro
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
