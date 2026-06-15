// lib/models/atleta_model.dart

class AtletaModel {
  final String uid;
  final String nome;
  final int idade;
  final String posicao;
  final String cidade;
  final String estado;
  final String regiao;
  final double altura;
  final double peso;
  final String pe; // 'destro', 'canhoto', 'ambidestro'
  final String? fotoPerfil;
  final List<String> videos; // URLs do Firebase Storage
  final List<String> habilidades;
  final String bio;
  final DateTime criadoEm;

  AtletaModel({
    required this.uid,
    required this.nome,
    required this.idade,
    required this.posicao,
    required this.cidade,
    required this.estado,
    required this.regiao,
    required this.altura,
    required this.peso,
    required this.pe,
    this.fotoPerfil,
    required this.videos,
    required this.habilidades,
    required this.bio,
    required this.criadoEm,
  });

  factory AtletaModel.fromMap(Map<String, dynamic> map, String uid) {
    return AtletaModel(
      uid: uid,
      nome: map['nome'] ?? '',
      idade: map['idade'] ?? 0,
      posicao: map['posicao'] ?? '',
      cidade: map['cidade'] ?? '',
      estado: map['estado'] ?? '',
      regiao: map['regiao'] ?? '',
      altura: (map['altura'] ?? 0).toDouble(),
      peso: (map['peso'] ?? 0).toDouble(),
      pe: map['pe'] ?? 'destro',
      fotoPerfil: map['fotoPerfil'],
      videos: List<String>.from(map['videos'] ?? []),
      habilidades: List<String>.from(map['habilidades'] ?? []),
      bio: map['bio'] ?? '',
      criadoEm: (map['criadoEm'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'idade': idade,
      'posicao': posicao,
      'cidade': cidade,
      'estado': estado,
      'regiao': regiao,
      'altura': altura,
      'peso': peso,
      'pe': pe,
      'fotoPerfil': fotoPerfil,
      'videos': videos,
      'habilidades': habilidades,
      'bio': bio,
      'criadoEm': criadoEm,
    };
  }
}

// Constantes reutilizáveis
const List<String> posicoesFutebol = [
  'Goleiro', 'Zagueiro', 'Lateral Direito', 'Lateral Esquerdo',
  'Volante', 'Meia', 'Meia-Atacante', 'Ponta Direita',
  'Ponta Esquerda', 'Atacante', 'Centroavante',
];

const List<String> regioesBrasil = [
  'Norte', 'Nordeste', 'Centro-Oeste', 'Sudeste', 'Sul',
];

const List<String> habilidadesDisponiveis = [
  'Velocidade', 'Drible', 'Passe Curto', 'Passe Longo',
  'Finalização', 'Visão de Jogo', 'Marcação', 'Cabeceio',
  'Força', 'Resistência', 'Liderança', 'Chute de Longe',
];
