// lib/services/atleta_service.dart

import 'dart:io';
import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/atleta_model.dart';

class AtletaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Criar/atualizar perfil do atleta
  Future<void> salvarPerfil(AtletaModel atleta) async {
    try {
      dev.log('Salvando perfil do atleta: ${atleta.uid}');
      await _db.collection('atletas').doc(atleta.uid).set(atleta.toMap());
      dev.log('Perfil salvo com sucesso!');
    } catch (e) {
      dev.log('ERRO ao salvar perfil: $e');
      rethrow;
    }
  }

  // Buscar perfil do atleta por uid
  Future<AtletaModel?> buscarPorUid(String uid) async {
    try {
      final doc = await _db.collection('atletas').doc(uid).get();
      if (!doc.exists) return null;
      return AtletaModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      dev.log('ERRO ao buscar atleta por UID: $e');
      return null;
    }
  }

  // Stream do feed (todos os atletas, ordenado por data)
  // CORREÇÃO: adicionado tratamento de erro para índice ausente no Firestore
  Stream<List<AtletaModel>> streamFeed() {
    return _db
        .collection('atletas')
        .orderBy('criadoEm', descending: true)
        .limit(30)
        .snapshots()
        .handleError((e) {
          dev.log('ERRO no streamFeed (verifique índice "criadoEm" no Firestore): $e');
        })
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
    try {
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

      if (idadeMin != null) {
        atletas = atletas.where((a) => a.idade >= idadeMin).toList();
      }
      if (idadeMax != null) {
        atletas = atletas.where((a) => a.idade <= idadeMax).toList();
      }

      return atletas;
    } catch (e) {
      dev.log('ERRO ao buscar atletas com filtros: $e');
      rethrow;
    }
  }

  // Upload de vídeo usando XFile — compatível com Web, Android e iOS
  Future<String> uploadVideoXFile({
    required String uid,
    required XFile xfile,
    required Function(double) onProgresso,
  }) async {
    try {
      dev.log('Iniciando upload XFile para UID: $uid');
      final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = _storage.ref('videos/$uid/$nomeArquivo');

      // Lê os bytes do XFile (funciona na web e no mobile)
      final bytes = await xfile.readAsBytes();
      dev.log('Bytes lidos: ${bytes.length}');

      final task = ref.putData(
        bytes,
        SettableMetadata(contentType: 'video/mp4'),
      );

      task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            final progresso = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgresso(progresso);
          }
        },
        onError: (e) => dev.log('Erro no progresso: $e'),
      );

      final snapshot = await task;
      if (snapshot.state != TaskState.success) {
        throw Exception('Upload falhou: ${snapshot.state}');
      }

      onProgresso(1.0);
      final url = await ref.getDownloadURL();
      dev.log('URL obtida: $url');

      await _db.collection('atletas').doc(uid).set(
        {
          'videos': FieldValue.arrayUnion([url]),
          'ultimoVideoEm': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      dev.log('Vídeo vinculado ao atleta!');
      return url;
    } catch (e) {
      dev.log('ERRO no uploadVideoXFile: $e');
      rethrow;
    }
  }

  // CORREÇÃO: Upload de vídeo com progresso funcionando corretamente
  Future<String> uploadVideo({
    required String uid,
    required File arquivo,
    required Function(double) onProgresso,
  }) async {
    try {
      dev.log('Iniciando upload de vídeo para UID: $uid');
      final nomeArquivo = '${DateTime.now().millisecondsSinceEpoch}.mp4';
      final ref = _storage.ref('videos/$uid/$nomeArquivo');

      // CORREÇÃO: Criar a task ANTES de escutar os eventos
      final task = ref.putFile(
        arquivo,
        SettableMetadata(contentType: 'video/mp4'),
      );

      // CORREÇÃO: Escutar progresso via snapshotEvents de forma síncrona
      // O listener é registrado antes do await, garantindo que não perde eventos
      task.snapshotEvents.listen(
        (snapshot) {
          if (snapshot.totalBytes > 0) {
            final progresso = snapshot.bytesTransferred / snapshot.totalBytes;
            onProgresso(progresso);
            dev.log('Upload progresso: ${(progresso * 100).toStringAsFixed(1)}%');
          }
        },
        onError: (e) => dev.log('Erro no progresso: $e'),
      );

      // Aguardar conclusão do upload
      final snapshot = await task;

      if (snapshot.state != TaskState.success) {
        throw Exception('Upload falhou com estado: ${snapshot.state}');
      }

      dev.log('Upload concluído no Storage. Buscando URL...');
      final url = await ref.getDownloadURL();
      dev.log('URL obtida: $url');

      // CORREÇÃO: Garantir progresso 100% após upload concluído
      onProgresso(1.0);

      dev.log('Salvando URL no Firestore...');
      // CORREÇÃO: Usar FieldValue.serverTimestamp() para garantir Timestamp correto
      await _db.collection('atletas').doc(uid).set(
        {
          'videos': FieldValue.arrayUnion([url]),
          'ultimoVideoEm': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      dev.log('Vídeo vinculado ao atleta com sucesso!');

      return url;
    } catch (e) {
      dev.log('ERRO CRÍTICO no upload de vídeo: $e');
      rethrow;
    }
  }

  // Deletar vídeo
  Future<void> deletarVideo({
    required String uid,
    required String videoUrl,
  }) async {
    try {
      final ref = _storage.refFromURL(videoUrl);
      await ref.delete();
    } catch (e) {
      dev.log('Aviso: Não foi possível deletar do Storage (pode já ter sido removido): $e');
    }

    await _db.collection('atletas').doc(uid).set(
      {'videos': FieldValue.arrayRemove([videoUrl])},
      SetOptions(merge: true),
    );
  }

  // Upload de foto de perfil
  Future<String> uploadFotoPerfil({
    required String uid,
    required File arquivo,
  }) async {
    try {
      final ref = _storage.ref('fotos_perfil/$uid/perfil.jpg');

      await ref.putFile(
        arquivo,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final url = await ref.getDownloadURL();

      await Future.wait([
        _db.collection('atletas').doc(uid).set(
              {'fotoPerfil': url},
              SetOptions(merge: true),
            ),
        _db.collection('usuarios').doc(uid).set(
              {'fotoPerfil': url},
              SetOptions(merge: true),
            ),
      ]);

      return url;
    } catch (e) {
      dev.log('ERRO no upload de foto de perfil: $e');
      rethrow;
    }
  }
}
