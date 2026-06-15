// lib/services/chat_service.dart

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
    final id = _idConversa(meuUid, outroUid);
    final ref = _db.collection('conversas').doc(id);

    // ✅ CORREÇÃO: Usa set com merge em vez de verificar existência.
    // Isso garante que o documento exista sem erros de permissão ou race conditions.
    final dadosConversa = {
      'id': id,
      'participantes': FieldValue.arrayUnion([meuUid, outroUid]),
      'nomesParticipantes': {
        meuUid: meuNome,
        outroUid: outroNome,
      },
      'ultimaAtividade': FieldValue.serverTimestamp(),
    };

    await ref.set(dadosConversa, SetOptions(merge: true));

    // Garante que os campos de inicialização existam se for uma conversa nova
    final doc = await ref.get();
    if (doc.data()?['naoLidas'] == null) {
      await ref.update({
        'ultimaMensagem': '',
        'naoLidas': {meuUid: 0, outroUid: 0},
      });
    }

    return id;
  }

  // Stream de mensagens de uma conversa (tempo real)
  Stream<List<MensagemModel>> streamMensagens(String conversaId) {
    return _db
        .collection('conversas')
        .doc(conversaId)
        .collection('mensagens')
        .orderBy('enviadaEm', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MensagemModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Enviar mensagem de texto
  Future<void> enviarMensagem({
    required String conversaId,
    required String remetenteUid,
    required String remetenteNome,
    required String destinatarioUid,
    required String texto,
  }) async {
    final mensagem = MensagemModel(
      id: '',
      remetenteUid: remetenteUid,
      remetenteNome: remetenteNome,
      texto: texto,
      tipo: TipoMensagem.texto,
      enviadaEm: DateTime.now(),
      lida: false,
    );

    final batch = _db.batch();

    // Adicionar mensagem
    final msgRef = _db
        .collection('conversas')
        .doc(conversaId)
        .collection('mensagens')
        .doc();

    batch.set(msgRef, mensagem.toMap());

    // ✅ CORREÇÃO: Usa set com merge na conversa para garantir que ela exista
    // antes de tentar dar o update (evita erro NOT_FOUND).
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
  }

  // Stream de conversas do usuário
  Stream<List<ConversaModel>> streamConversas(String uid) {
    return _db
        .collection('conversas')
        .where('participantes', arrayContains: uid)
        .orderBy('ultimaAtividade', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ConversaModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Marcar mensagens como lidas
  Future<void> marcarComoLido(String conversaId, String meuUid) async {
    await _db.collection('conversas').doc(conversaId).set({
      'naoLidas': {meuUid: 0}
    }, SetOptions(merge: true));
  }
}
