// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream do usuário autenticado
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get usuarioAtual => _auth.currentUser;

  // CORREÇÃO: Stream do documento do usuário no Firestore
  // Usado pelo AuthGate para evitar race condition entre Auth e Firestore
  Stream<UsuarioModel?> streamUsuarioAtual() {
    return _auth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _db
          .collection('usuarios')
          .doc(user.uid)
          .snapshots()
          .map((doc) {
            if (!doc.exists || doc.data() == null) return null;
            return UsuarioModel.fromMap(doc.data()!, doc.id);
          });
    });
  }

  // Cadastro como Atleta
  Future<UsuarioModel?> cadastrarAtleta({
    required String nome,
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await cred.user!.updateDisplayName(nome);

      final usuario = UsuarioModel(
        uid: cred.user!.uid,
        nome: nome,
        email: email,
        tipo: TipoUsuario.atleta,
        criadoEm: DateTime.now(),
      );

      await _db.collection('usuarios').doc(usuario.uid).set(usuario.toMap());
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _traduzirErro(e.code);
    }
  }

  // Cadastro como Olheiro
  Future<UsuarioModel?> cadastrarOlheiro({
    required String nome,
    required String email,
    required String senha,
    required String clube,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );
      await cred.user!.updateDisplayName(nome);

      final usuario = UsuarioModel(
        uid: cred.user!.uid,
        nome: nome,
        email: email,
        tipo: TipoUsuario.olheiro,
        criadoEm: DateTime.now(),
      );

      final dadosOlheiro = usuario.toMap();
      dadosOlheiro['clube'] = clube;

      await _db.collection('usuarios').doc(usuario.uid).set(dadosOlheiro);
      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _traduzirErro(e.code);
    }
  }

  // Login
  Future<UsuarioModel?> login({
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );

      final doc = await _db.collection('usuarios').doc(cred.user!.uid).get();
      if (!doc.exists) return null;

      return UsuarioModel.fromMap(doc.data()!, doc.id);
    } on FirebaseAuthException catch (e) {
      throw _traduzirErro(e.code);
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Buscar dados do usuário atual (one-shot, para uso pontual)
  Future<UsuarioModel?> buscarUsuarioAtual() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _db.collection('usuarios').doc(uid).get();
    if (!doc.exists) return null;

    return UsuarioModel.fromMap(doc.data()!, doc.id);
  }

  // Traduzir erros do Firebase para PT-BR
  String _traduzirErro(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Este e-mail já está em uso.';
      case 'weak-password':
        return 'Senha muito fraca. Use ao menos 6 caracteres.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente em instantes.';
      default:
        return 'Erro inesperado. Tente novamente.';
    }
  }
}
