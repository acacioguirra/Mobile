// lib/screens/atleta/tela_home_atleta.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/atleta_service.dart';
import '../../models/atleta_model.dart';
import '../../utils/app_colors.dart';
import '../shared/tela_perfil_atleta.dart';
import '../shared/tela_chat_lista.dart';
import '../shared/tela_busca.dart';

class TelaHomeAtleta extends StatefulWidget {
  const TelaHomeAtleta({super.key});

  @override
  State<TelaHomeAtleta> createState() => _TelaHomeAtletaState();
}

class _TelaHomeAtletaState extends State<TelaHomeAtleta> {
  int _abaSelecionada = 0;

  final List<Widget> _telas = const [
    _TabFeed(),
    _TabUploadVideo(),
    TelaChatLista(),
    _TabMeuPerfil(),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Feed'),
          BottomNavigationBarItem(icon: Icon(Icons.video_call), label: 'Vídeo'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}

// ── Tab Feed ─────────────────────────────────────────────
class _TabFeed extends StatelessWidget {
  const _TabFeed();

  @override
  Widget build(BuildContext context) {
    final atletaService = context.read<AtletaService>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('BasePro', style: TextStyle(color: AppColors.verde)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TelaBusca()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<AtletaModel>>(
        stream: atletaService.streamFeed(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.verde),
            );
          }

          if (snap.hasError) {
            return Center(
              child: Text('Erro: ${snap.error}',
                  style: const TextStyle(color: Colors.grey)),
            );
          }

          final atletas = snap.data ?? [];

          if (atletas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum atleta cadastrado ainda.',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: atletas.length,
            itemBuilder: (context, i) => _CardAtletaFeed(atleta: atletas[i]),
          );
        },
      ),
    );
  }
}

class _CardAtletaFeed extends StatelessWidget {
  final AtletaModel atleta;
  const _CardAtletaFeed({required this.atleta});

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
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.verde, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail do vídeo ou placeholder
            Container(
              height: 200,
              decoration: const BoxDecoration(
                color: AppColors.cardClaro,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: atleta.videos.isNotEmpty
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.play_circle_fill,
                            color: AppColors.verde, size: 52),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${atleta.videos.length} vídeo${atleta.videos.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    )
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.videocam_off,
                              color: Colors.grey, size: 36),
                          SizedBox(height: 8),
                          Text('Sem vídeos ainda',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${atleta.nome}, ${atleta.idade} anos',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${atleta.posicao} · ${atleta.cidade}',
                    style: const TextStyle(color: AppColors.verde, fontSize: 13),
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

// ── Tab Upload de Vídeo ───────────────────────────────────
class _TabUploadVideo extends StatefulWidget {
  const _TabUploadVideo();

  @override
  State<_TabUploadVideo> createState() => _TabUploadVideoState();
}

class _TabUploadVideoState extends State<_TabUploadVideo> {
  double _progresso = 0;
  bool _enviando = false;
  String? _nomeArquivo;

  Future<void> _selecionarEEnviar() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final arquivo = File(result.files.single.path!);
    final nome = result.files.single.name;

    // Verificar tamanho (limite 100MB)
    final tamanhoMB = arquivo.lengthSync() / (1024 * 1024);
    if (tamanhoMB > 100) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vídeo muito grande. Máximo 100MB.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _enviando = true;
      _progresso = 0;
      _nomeArquivo = nome;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await context.read<AtletaService>().uploadVideo(
            uid: uid,
            arquivo: arquivo,
            onProgresso: (p) => setState(() => _progresso = p),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vídeo publicado com sucesso! ✅'),
            backgroundColor: AppColors.verde,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Publicar Vídeo')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mostre seu talento',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Publique vídeos de treinos, partidas e lances para ser visto por olheiros.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 40),

            // Área de drop
            GestureDetector(
              onTap: _enviando ? null : _selecionarEEnviar,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _enviando ? AppColors.verde : Colors.grey[700]!,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _enviando ? Icons.upload : Icons.video_call_outlined,
                      color: _enviando ? AppColors.verde : Colors.grey,
                      size: 52,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _enviando
                          ? 'Enviando...'
                          : 'Toque para selecionar vídeo MP4',
                      style: TextStyle(
                        color: _enviando ? AppColors.verde : Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                    if (_nomeArquivo != null && _enviando) ...[
                      const SizedBox(height: 8),
                      Text(
                        _nomeArquivo!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Barra de progresso
            if (_enviando) ...[
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: _progresso,
                backgroundColor: AppColors.card,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.verde),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 8),
              Text(
                '${(_progresso * 100).toStringAsFixed(0)}%',
                style:
                    const TextStyle(color: AppColors.verde, fontSize: 14),
              ),
            ],

            const SizedBox(height: 32),

            // Dicas
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 Dicas para um bom vídeo',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('• Filmagem em boa iluminação',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('• Mostre suas habilidades técnicas',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('• Duração entre 1 e 3 minutos',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                  Text('• Formato MP4, máximo 100MB',
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Tab Meu Perfil ────────────────────────────────────────
class _TabMeuPerfil extends StatelessWidget {
  const _TabMeuPerfil();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox();

    return TelaPerfilAtleta(atletaUid: uid, isMeuPerfil: true);
  }
}
