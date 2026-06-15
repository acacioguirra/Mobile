// lib/screens/olheiro/tela_perfil_olheiro.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/usuario_model.dart';
import '../../utils/app_colors.dart';

class TelaPerfilOlheiro extends StatefulWidget {
  const TelaPerfilOlheiro({super.key});

  @override
  State<TelaPerfilOlheiro> createState() => _TelaPerfilOlheiroState();
}

class _TelaPerfilOlheiroState extends State<TelaPerfilOlheiro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _clubeCtrl = TextEditingController();
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final usuario = await context.read<AuthService>().buscarUsuarioAtual();
    if (usuario != null) {
      _nomeCtrl.text = usuario.nome;
      
      // Buscar clube no Firestore (campo extra do olheiro)
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(usuario.uid).get();
      if (mounted) {
        setState(() {
          _clubeCtrl.text = doc.data()?['clube'] ?? '';
        });
      }
    }
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
        'nome': _nomeCtrl.text.trim(),
        'clube': _clubeCtrl.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado!'), backgroundColor: AppColors.verde),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () => context.read<AuthService>().logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.verde,
                child: Icon(Icons.business_center, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 32),
              
              TextFormField(
                controller: _nomeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person_outlined, color: Colors.grey),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe seu nome' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _clubeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Clube / Organização',
                  prefixIcon: Icon(Icons.business_outlined, color: Colors.grey),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Informe o clube' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _salvar,
                  child: _carregando 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('SALVAR ALTERAÇÕES'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
