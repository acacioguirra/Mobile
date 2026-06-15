// lib/models/usuario_model.dart

enum TipoUsuario { atleta, olheiro }

class UsuarioModel {
  final String uid;
  final String nome;
  final String email;
  final TipoUsuario tipo;
  final String? fotoPerfil;
  final DateTime criadoEm;

  UsuarioModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.tipo,
    this.fotoPerfil,
    required this.criadoEm,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String uid) {
    return UsuarioModel(
      uid: uid,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      tipo: map['tipo'] == 'olheiro' ? TipoUsuario.olheiro : TipoUsuario.atleta,
      fotoPerfil: map['fotoPerfil'],
      criadoEm: (map['criadoEm'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email,
      'tipo': tipo == TipoUsuario.olheiro ? 'olheiro' : 'atleta',
      'fotoPerfil': fotoPerfil,
      'criadoEm': criadoEm,
    };
  }
}
