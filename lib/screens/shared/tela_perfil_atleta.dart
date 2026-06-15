// lib/screens/shared/tela_perfil_atleta.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../services/atleta_service.dart';
import '../../services/auth_service.dart';
import '../../services/chat_service.dart';
import '../../models/atleta_model.dart';
import '../../models/usuario_model.dart';
import '../../utils/app_colors.dart';
import 'tela_chat.dart';

class TelaPerfilAtleta extends StatelessWidget {
  final String atletaUid;
  final bool isMeuPerfil;

  const TelaPerfilAtleta({
    super.key,
    required this.atletaUid,
    this.isMeuPerfil = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtletaModel?>(
      future: context.read<AtletaService>().buscarPorUid(atletaUid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.verde),
            ),
          );
        }

        final atleta = snap.data;
        if (atleta == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Perfil não encontrado.',
                  style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return _PerfilConteudo(atleta: atleta, isMeuPerfil: isMeuPerfil);
      },
    );
  }
}

class _PerfilConteudo extends StatelessWidget {
  final AtletaModel atleta;
  final bool isMeuPerfil;

  const _PerfilConteudo({required this.atleta, required this.isMeuPerfil});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(isMeuPerfil ? 'Meu Perfil' : 'Perfil do Atleta'),
        actions: [
          if (isMeuPerfil)
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.grey),
              onPressed: () async {
                await context.read<AuthService>().logout();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.verde,
              backgroundImage: atleta.fotoPerfil != null
                  ? NetworkImage(atleta.fotoPerfil!)
                  : null,
              child: atleta.fotoPerfil == null
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),

            Text(
              atleta.nome,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${atleta.posicao} | ${atleta.pe[0].toUpperCase()}${atleta.pe.substring(1)}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              '${atleta.cidade} · ${atleta.regiao}',
              style: const TextStyle(color: AppColors.verde, fontSize: 13),
            ),

            const SizedBox(height: 24),

            // Métricas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Metrica(
                      valor: atleta.altura > 0
                          ? '${atleta.altura.toStringAsFixed(2)}m'
                          : '-',
                      label: 'Altura'),
                  Container(width: 1, height: 40, color: Colors.grey[800]),
                  _Metrica(
                      valor: atleta.peso > 0
                          ? '${atleta.peso.toStringAsFixed(0)}kg'
                          : '-',
                      label: 'Peso'),
                  Container(width: 1, height: 40, color: Colors.grey[800]),
                  _Metrica(
                      valor: '${atleta.idade}',
                      label: 'Idade',
                      cor: AppColors.verde),
                ],
              ),
            ),

            // Bio
            if (atleta.bio.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Sobre',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(atleta.bio,
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 14)),
            ],

            // Habilidades
            if (atleta.habilidades.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Habilidades',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: atleta.habilidades.map((h) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A237E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(h,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 12)),
                  );
                }).toList(),
              ),
            ],

            // Vídeos
            if (atleta.videos.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Vídeos',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              ...atleta.videos.map((url) => _PlayerVideo(url: url)),
            ],

            // Botão mensagem (apenas se não for meu perfil)
            if (!isMeuPerfil) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final meuUid =
                        FirebaseAuth.instance.currentUser?.uid ?? '';
                    final usuario = await context
                        .read<AuthService>()
                        .buscarUsuarioAtual();
                    final meuNome = usuario?.nome ?? 'Usuário';

                    final chatService = context.read<ChatService>();
                    final conversaId = await chatService.iniciarConversa(
                      meuUid: meuUid,
                      meuNome: meuNome,
                      outroUid: atleta.uid,
                      outroNome: atleta.nome,
                    );

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TelaChat(
                            conversaId: conversaId,
                            nomeContato: atleta.nome,
                            contatoUid: atleta.uid,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.message),
                  label: const Text('ENVIAR MENSAGEM'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  final String valor;
  final String label;
  final Color cor;

  const _Metrica({
    required this.valor,
    required this.label,
    this.cor = AppColors.azulInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(valor,
            style: TextStyle(
                color: cor,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// Player de vídeo real usando video_player + chewie
class _PlayerVideo extends StatefulWidget {
  final String url;
  const _PlayerVideo({required this.url});

  @override
  State<_PlayerVideo> createState() => _PlayerVideoState();
}

class _PlayerVideoState extends State<_PlayerVideo> {
  late VideoPlayerController _vpCtrl;
  ChewieController? _chewieCtrl;
  bool _inicializado = false;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    _vpCtrl = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _vpCtrl.initialize();

    _chewieCtrl = ChewieController(
      videoPlayerController: _vpCtrl,
      aspectRatio: 16 / 9,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      placeholder: Container(color: AppColors.cardClaro),
    );

    if (mounted) setState(() => _inicializado = true);
  }

  @override
  void dispose() {
    _vpCtrl.dispose();
    _chewieCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.cardClaro,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.hardEdge,
      child: _inicializado && _chewieCtrl != null
          ? Chewie(controller: _chewieCtrl!)
          : const Center(
              child: CircularProgressIndicator(color: AppColors.verde),
            ),
    );
  }
}
