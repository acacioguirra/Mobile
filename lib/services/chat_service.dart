// lib/services/chat_service.dart

import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mensagem_model.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Gera um ID de conversa consistente entre dois usuários
  String _idConversa(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // Iniciar ou buscar conversa entre dois usuários
  Future<String> iniciarConversa({
    required String meuUid,
    required String meuNome,
    required String outroUid,
    required String outroNome,
  }) async {
    try {
      dev.log('Iniciando conversa entre $meuUid e $outroUid');
      final id = _idConversa(meuUid, outroUid);
      final ref = _db.collection('conversas').doc(id);

      // CORREÇÃO: set com merge garante criação e atualização sem sobrescrever
      await ref.set(
        {
          'id': id,
          'participantes': [meuUid, outroUid],
          'nomesParticipantes': {
            meuUid: meuNome,
            outroUid: outroNome,
          },
          'ultimaAtividade': FieldValue.serverTimestamp(),
          'ultimaMensagem': '',
          'naoLidas': {meuUid: 0, outroUid: 0},
        },
        SetOptions(merge: true),
      );

      dev.log('Conversa pronta: $id');
      return id;
    } catch (e) {
      dev.log('ERRO ao iniciar conversa: $e');
      rethrow;
    }
  }

  // Stream de mensagens de uma conversa (tempo real)
  Stream<List<MensagemModel>> streamMensagens(String conversaId) {
    return _db
        .collection('conversas')
        .doc(conversaId)
        .collection('mensagens')
        .orderBy('enviadaEm', descending: false)
        .snapshots()
        .handleError((e) {
          dev.log('ERRO no streamMensagens (verifique índice "enviadaEm"): $e');
        })
        .map((snap) {
          dev.log('Recebidas ${snap.docs.length} mensagens para $conversaId');
          return snap.docs
              .map((d) => MensagemModel.fromMap(d.data(), d.id))
              .toList();
        });
  }

  // Enviar mensagem de texto
  Future<void> enviarMensagem({
    required String conversaId,
    required String remetenteUid,
    required String remetenteNome,
    required String destinatarioUid,
    required String texto,
  }) async {
    try {
      dev.log('Enviando mensagem na conversa: $conversaId');
      final batch = _db.batch();

      final msgRef = _db
          .collection('conversas')
          .doc(conversaId)
          .collection('mensagens')
          .doc();

      final dadosMsg = {
        'remetenteUid': remetenteUid,
        'remetenteNome': remetenteNome,
        'texto': texto,
        'tipo': 'texto',
        // CORREÇÃO: sempre usar serverTimestamp para ordenação correta
        'enviadaEm': FieldValue.serverTimestamp(),
        'lida': false,
      };

      batch.set(msgRef, dadosMsg);

      // CORREÇÃO: atualizar conversa com serverTimestamp para manter ordenação no streamConversas
      batch.set(
        _db.collection('conversas').doc(conversaId),
        {
          'ultimaMensagem': texto,
          'ultimaAtividade': FieldValue.serverTimestamp(),
          'naoLidas.$destinatarioUid': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      await batch.commit();
      dev.log('Mensagem enviada com sucesso!');
    } catch (e) {
      dev.log('ERRO ao enviar mensagem: $e');
      rethrow;
    }
  }

  // Stream de conversas do usuário
  // CORREÇÃO: query requer índice composto no Firestore:
  // Coleção: conversas | Campos: participantes (Arrays) + ultimaAtividade (Desc)
  Stream<List<ConversaModel>> streamConversas(String uid) {
    return _db
        .collection('conversas')
        .where('participantes', arrayContains: uid)
        .orderBy('ultimaAtividade', descending: true)
        .snapshots()
        .handleError((e) {
          dev.log('ERRO no streamConversas. Verifique índice composto no Firestore: $e');
        })
        .map((snap) {
          dev.log('Encontradas ${snap.docs.length} conversas para o usuário $uid');
          return snap.docs
              .map((d) => ConversaModel.fromMap(d.data(), d.id))
              .toList();
        });
  }

  // Marcar mensagens como lidas
  Future<void> marcarComoLido(String conversaId, String meuUid) async {
    try {
      await _db.collection('conversas').doc(conversaId).set({
        'naoLidas': {meuUid: 0}
      }, SetOptions(merge: true));
    } catch (e) {
      dev.log('Erro ao marcar como lido: $e');
    }
  }
}
