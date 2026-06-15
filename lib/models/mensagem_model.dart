// lib/models/mensagem_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum TipoMensagem { texto, video, imagem }

class MensagemModel {
  final String id;
  final String remetenteUid;
  final String remetenteNome;
  final String texto;
  final TipoMensagem tipo;
  final String? midiaUrl;
  final DateTime enviadaEm;
  final bool lida;

  MensagemModel({
    required this.id,
    required this.remetenteUid,
    required this.remetenteNome,
    required this.texto,
    required this.tipo,
    this.midiaUrl,
    required this.enviadaEm,
    required this.lida,
  });

  factory MensagemModel.fromMap(Map<String, dynamic> map, String id) {
    return MensagemModel(
      id: id,
      remetenteUid: map['remetenteUid'] ?? '',
      remetenteNome: map['remetenteNome'] ?? '',
      texto: map['texto'] ?? '',
      tipo: TipoMensagem.values.firstWhere(
        (t) => t.name == (map['tipo'] ?? 'texto'),
        orElse: () => TipoMensagem.texto,
      ),
      midiaUrl: map['midiaUrl'],
      // CORREÇÃO: parse robusto de Timestamp do Firestore
      enviadaEm: _parseDateTime(map['enviadaEm']),
      lida: map['lida'] ?? false,
    );
  }

  // CORREÇÃO: suporte explícito a Timestamp do Firestore
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    try {
      return (value as Timestamp).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'remetenteUid': remetenteUid,
      'remetenteNome': remetenteNome,
      'texto': texto,
      'tipo': tipo.name,
      'midiaUrl': midiaUrl,
      // CORREÇÃO: salvar como Timestamp explícito (o service usa serverTimestamp, mas aqui fica o fallback)
      'enviadaEm': Timestamp.fromDate(enviadaEm),
      'lida': lida,
    };
  }
}

class ConversaModel {
  final String id;
  final List<String> participantes;
  final Map<String, String> nomesParticipantes;
  final String ultimaMensagem;
  final DateTime ultimaAtividade;
  final Map<String, int> naoLidas;

  ConversaModel({
    required this.id,
    required this.participantes,
    required this.nomesParticipantes,
    required this.ultimaMensagem,
    required this.ultimaAtividade,
    required this.naoLidas,
  });

  factory ConversaModel.fromMap(Map<String, dynamic> map, String id) {
    return ConversaModel(
      id: id,
      participantes: List<String>.from(map['participantes'] ?? []),
      nomesParticipantes: Map<String, String>.from(map['nomesParticipantes'] ?? {}),
      ultimaMensagem: map['ultimaMensagem'] ?? '',
      // CORREÇÃO: parse robusto de Timestamp
      ultimaAtividade: _parseDateTime(map['ultimaAtividade']),
      naoLidas: Map<String, int>.from(
        (map['naoLidas'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toInt()),
        ),
      ),
    );
  }

  // CORREÇÃO: suporte explícito a Timestamp do Firestore
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    try {
      return (value as Timestamp).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'participantes': participantes,
      'nomesParticipantes': nomesParticipantes,
      'ultimaMensagem': ultimaMensagem,
      'ultimaAtividade': Timestamp.fromDate(ultimaAtividade),
      'naoLidas': naoLidas,
    };
  }
}
