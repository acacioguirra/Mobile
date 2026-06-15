// lib/screens/shared/tela_chat.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/chat_service.dart';
import '../../services/auth_service.dart';
import '../../models/mensagem_model.dart';
import '../../utils/app_colors.dart';

class TelaChat extends StatefulWidget {
  final String conversaId;
  final String nomeContato;
  final String contatoUid;

  const TelaChat({
    super.key,
    required this.conversaId,
    required this.nomeContato,
    required this.contatoUid,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  String _meuNome = '';
  String _meuUid = '';

  @override
  void initState() {
    super.initState();
    _meuUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final usuario = await context.read<AuthService>().buscarUsuarioAtual();
    if (mounted) {
      setState(() => _meuNome = usuario?.nome ?? 'Usuário');
      // Marcar como lido após carregar o UID
      context.read<ChatService>().marcarComoLido(widget.conversaId, _meuUid);
    }
  }

  Future<void> _enviar() async {
    final texto = _ctrl.text.trim();
    if (texto.isEmpty) return;
    
    // ✅ CORREÇÃO: Garante que temos o nome do remetente antes de enviar
    if (_meuNome.isEmpty) {
      await _carregarDados();
    }

    _ctrl.clear();

    try {
      await context.read<ChatService>().enviarMensagem(
            conversaId: widget.conversaId,
            remetenteUid: _meuUid,
            remetenteNome: _meuNome,
            destinatarioUid: widget.contatoUid,
            texto: texto,
          );

      _rolarParaFim();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _rolarParaFim() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.nomeContato,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const Text('Online',
                style: TextStyle(color: AppColors.verde, fontSize: 11)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MensagemModel>>(
              stream: context
                  .read<ChatService>()
                  .streamMensagens(widget.conversaId),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.verde),
                  );
                }

                final msgs = snap.data ?? [];

                if (msgs.isEmpty) {
                  return const Center(
                    child: Text('Diga "Olá!" para iniciar a conversa.',
                        style: TextStyle(color: Colors.grey)),
                  );
                }

                // Auto-scroll ao receber novas mensagens
                WidgetsBinding.instance.addPostFrameCallback((_) => _rolarParaFim());

                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final msg = msgs[i];
                    final enviada = msg.remetenteUid == _meuUid;
                    return _Bolha(mensagem: msg, enviada: enviada);
                  },
                );
              },
            ),
          ),

          // Campo de texto
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 30), // Padding extra para iPhones/Gesture nav
            color: const Color(0xFF0A0A0A),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mensagem...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: AppColors.card,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _enviar(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.verde,
                  child: IconButton(
                    icon: const Icon(Icons.send,
                        color: Colors.white, size: 20),
                    onPressed: _enviar,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bolha extends StatelessWidget {
  final MensagemModel mensagem;
  final bool enviada;

  const _Bolha({required this.mensagem, required this.enviada});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: enviada ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: enviada ? AppColors.verde : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(enviada ? 16 : 0),
            bottomRight: Radius.circular(enviada ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!enviada) ...[
              Text(mensagem.remetenteNome,
                  style: const TextStyle(
                      color: AppColors.verde,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
            ],
            Text(mensagem.texto,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
