

import 'package:flutter/material.dart';
import 'tela3_perfil.dart';

class BuscaScreen extends StatefulWidget {

  const BuscaScreen({super.key});

  @override
  State<BuscaScreen> createState() => _BuscaScreenState();
}

class _BuscaScreenState extends State<BuscaScreen> {


  String _posicaoSelecionada = 'Zagueiro';
  String _regiaoSelecionada = 'Nordeste';
  bool _buscaRealizada = false;


  final List<String> _posicoes = [
    'Goleiro', 'Zagueiro', 'Lateral', 'Volante',
    'Meia', 'Atacante', 'Ponta',
  ];

  final List<String> _regioes = [
    'Norte', 'Nordeste', 'Centro-Oeste', 'Sudeste', 'Sul',
  ];


  final List<Map<String, String>> _todosAtletas = [
    {'nome': 'Lucas Mendes', 'posicao': 'Zagueiro', 'idade': '18 anos', 'cidade': 'Feira de Santana'},
    {'nome': 'Rafael Costa', 'posicao': 'Zagueiro', 'idade': '20 anos', 'cidade': 'Recife'},
    {'nome': 'João Silva',   'posicao': 'Atacante',  'idade': '17 anos', 'cidade': 'Salvador'},
    {'nome': 'Pedro Alves',  'posicao': 'Meia',      'idade': '21 anos', 'cidade': 'Fortaleza'},
  ];


  List<Map<String, String>> _resultados = [];


  void _filtrar() {
    setState(() {

      _resultados = _todosAtletas.where((atleta) {
        return atleta['posicao'] == _posicaoSelecionada;
      }).toList();
      _buscaRealizada = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Buscar Talentos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            const Text(
              'Posição',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              valor: _posicaoSelecionada,
              opcoes: _posicoes,
              onChanged: (val) => setState(() => _posicaoSelecionada = val!),
            ),

            const SizedBox(height: 20),


            const Text(
              'Região',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 8),
            _buildDropdown(
              valor: _regiaoSelecionada,
              opcoes: _regioes,
              onChanged: (val) => setState(() => _regiaoSelecionada = val!),
            ),

            const SizedBox(height: 24),


            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _filtrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'FILTRAR',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),


            Expanded(
              child: _buscaRealizada
                  ? _resultados.isEmpty

                      ? const Center(
                          child: Text(
                            'Nenhum atleta encontrado.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )

                      : ListView.builder(
                          itemCount: _resultados.length,
                          itemBuilder: (context, index) {
                            final atleta = _resultados[index];
                            return _ItemResultado(atleta: atleta);
                          },
                        )
                  : const SizedBox(), // vazio antes de filtrar
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDropdown({
    required String valor,
    required List<String> opcoes,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2333),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: DropdownButtonHideUnderline(

        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          dropdownColor: const Color(0xFF1C2333),
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: opcoes.map((opcao) {
            return DropdownMenuItem(value: opcao, child: Text(opcao));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}


class _ItemResultado extends StatelessWidget {
  final Map<String, String> atleta;

  const _ItemResultado({required this.atleta});

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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2333),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [

            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[700],
              child: Text(
                atleta['nome']![0], // primeira letra do nome
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  atleta['nome']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${atleta['posicao']} - ${atleta['idade']}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const Spacer(),

            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
