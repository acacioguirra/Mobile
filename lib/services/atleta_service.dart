// lib/services/atleta_service.dart

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/atleta_model.dart';

class AtletaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Criar/atualizar perfil do atleta
  Future<void> salvarPerfil(AtletaModel atleta) async {
    await _db.collection('atletas').doc(atleta.uid).set(atleta.toMap());
  }

  // Buscar perfil do atleta por uid
  Future<AtletaModel?> buscarPorUid(String uid) async {
    final doc = await _db.collection('atletas').doc(uid).get();
    if (!doc.exists) return null;
    return AtletaModel.fromMap(doc.data()!, doc.id);
  }

  // Stream do feed (todos os atletas, ordenado por data)
  Stream<List<AtletaModel>> streamFeed() {
    return _db
        .collection('atletas')
        .orderBy('criadoEm', descending: true)
        .limit(30)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AtletaModel.fromMap(d.data(), d.id))
            .toList());
  }

  // Buscar atletas com filtros
  Future<List<AtletaModel>> buscarAtletas({
    String? posicao,
    String? regiao,
    int? idadeMin,
    int? idadeMax,
  }) async {
    Query query = _db.collection('atletas');

    if (posicao != null && posicao.isNotEmpty) {
      query = query.where('posicao', isEqualTo: posicao);
    }
    if (regiao != null && regiao.isNotEmpty) {
      query = query.where('regiao', isEqualTo: regiao);
    }

    final snap = await query.get();
    var atletas = snap.docs
        .map((d) => AtletaModel.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    // Filtro de idade no client (Firestore não suporta múltiplos range filters)
    if (idadeMin != null) {
      atletas = atletas.where((a) => a.idade >= idadeMin).toList();
    }
    if (idadeMax != null) {
      atletas = atletas.where((a) => a.idade <= idadeMax).toList();
    }

    return atletas;
  }

  // Upload de vídeo MP4 para o Firebase Storage
  Future<String> uploadVideo({
    required String uid,
    required File arquivo,
    required Function(double) onProgresso,
  }) async {
    final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.mp4';
    final ref = _storage.ref('videos/$uid/$nomeArquivo');

    final task = ref.putFile(
      arquivo,
      SettableMetadata(contentType: 'video/mp4'),
    );

    // Monitorar progresso do upload
    task.snapshotEvents.listen((snapshot) {
      if (snapshot.totalBytes > 0) {
        final progresso = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgresso(progresso);
      }
    });

    await task;
    final url = await ref.getDownloadURL();

    // Salvar URL no perfil do atleta no Firestore
    await _db.collection('atletas').doc(uid).update({
      'videos': FieldValue.arrayUnion([url]),
    });

    return url;
  }

  // Deletar vídeo
  Future<void> deletarVideo({
    required String uid,
    required String videoUrl,
  }) async {
    // Remover do Storage
    try {
      final ref = _storage.refFromURL(videoUrl);
      await ref.delete();
    } catch (_) {}

    // Remover do Firestore
    await _db.collection('atletas').doc(uid).update({
      'videos': FieldValue.arrayRemove([videoUrl]),
    });
  }

  // Upload de foto de perfil
  Future<String> uploadFotoPerfil({
    required String uid,
    required File arquivo,
  }) async {
    final ref = _storage.ref('fotos_perfil/$uid/perfil.jpg');

    await ref.putFile(
      arquivo,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final url = await ref.getDownloadURL();

    // Atualizar em atletas e usuarios
    await Future.wait([
      _db.collection('atletas').doc(uid).update({'fotoPerfil': url}),
      _db.collection('usuarios').doc(uid).update({'fotoPerfil': url}),
    ]);

    return url;
  }
}
