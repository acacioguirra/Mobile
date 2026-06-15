// lib/screens/shared/tela_chat_lista.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../services/chat_service.dart';
import '../../models/mensagem_model.dart';
import '../../utils/app_colors.dart';
import 'tela_chat.dart';

class TelaChatLista extends StatelessWidget {
  const TelaChatLista({super.key});

  @override
  Widget build(BuildContext context) {
    final meuUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Conversas')),
      body: StreamBuilder<List<ConversaModel>>(
        stream: context.read<ChatService>().streamConversas(meuUid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.verde),
            );
          }

          final conversas = snap.data ?? [];

          if (conversas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      color: Colors.grey, size: 52),
                  SizedBox(height: 16),
                  Text('Nenhuma conversa ainda.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: conversas.length,
            itemBuilder: (context, i) {
              final conversa = conversas[i];
              final outroUid = conversa.participantes
                  .firstWhere((uid) => uid != meuUid, orElse: () => '');
              final outroNome =
                  conversa.nomesParticipantes[outroUid] ?? 'Usuário';
              final naoLidas = conversa.naoLidas[meuUid] ?? 0;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.verde,
                  child: Text(
                    outroNome.isNotEmpty ? outroNome[0].toUpperCase() : '?',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(outroNome,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text(
                  conversa.ultimaMensagem,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      timeago.format(conversa.ultimaAtividade,
                          locale: 'pt_BR'),
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    if (naoLidas > 0) ...[
                      const SizedBox(height: 4),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.verde,
                        child: Text('$naoLidas',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ),
                    ],
                  ],
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TelaChat(
                      conversaId: conversa.id,
                      nomeContato: outroNome,
                      contatoUid: outroUid,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
