// lib/screens/shared/tela_busca.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/atleta_service.dart';
import '../../models/atleta_model.dart';
import '../../utils/app_colors.dart';
import 'tela_perfil_atleta.dart';

class TelaBusca extends StatefulWidget {
  const TelaBusca({super.key});

  @override
  State<TelaBusca> createState() => _TelaBuscaState();
}

class _TelaBuscaState extends State<TelaBusca> {
  String? _posicao;
  String? _regiao;
  List<AtletaModel>? _resultados;
  bool _carregando = false;

  Future<void> _filtrar() async {
    setState(() {
      _carregando = true;
      _resultados = null;
    });

    try {
      final atletas = await context.read<AtletaService>().buscarAtletas(
            posicao: _posicao,
            regiao: _regiao,
          );
      setState(() => _resultados = atletas);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Buscar Talentos')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelCampo('Posição'),
            _dropdown(
              valor: _posicao,
              hint: 'Todas as posições',
              opcoes: posicoesFutebol,
              onChanged: (v) => setState(() => _posicao = v),
            ),
            const SizedBox(height: 16),

            _labelCampo('Região'),
            _dropdown(
              valor: _regiao,
              hint: 'Todo o Brasil',
              opcoes: regioesBrasil,
              onChanged: (v) => setState(() => _regiao = v),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _carregando ? null : _filtrar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('FILTRAR'),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: _resultados == null
                  ? const Center(
                      child: Text(
                        'Use os filtros acima para encontrar atletas.',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : _resultados!.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum atleta encontrado com esses filtros.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _resultados!.length,
                          itemBuilder: (context, i) {
                            final atleta = _resultados![i];
                            return _ItemAtleta(atleta: atleta);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelCampo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto,
          style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _dropdown({
    required String? valor,
    required String hint,
    required List<String> opcoes,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          hint: Text(hint, style: const TextStyle(color: Colors.grey)),
          isExpanded: true,
          dropdownColor: AppColors.card,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: [
            DropdownMenuItem(value: null, child: Text(hint)),
            ...opcoes.map(
                (o) => DropdownMenuItem(value: o, child: Text(o))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ItemAtleta extends StatelessWidget {
  final AtletaModel atleta;
  const _ItemAtleta({required this.atleta});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TelaPerfilAtleta(atletaUid: atleta.uid),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey[700],
              backgroundImage: atleta.fotoPerfil != null
                  ? NetworkImage(atleta.fotoPerfil!)
                  : null,
              child: atleta.fotoPerfil == null
                  ? Text(
                      atleta.nome[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(atleta.nome,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(
                    '${atleta.posicao} · ${atleta.idade} anos · ${atleta.cidade}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            if (atleta.videos.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.verde.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow,
                        color: AppColors.verde, size: 14),
                    Text(
                      '${atleta.videos.length}',
                      style: const TextStyle(
                          color: AppColors.verde, fontSize: 12),
                    ),
                  ],
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
