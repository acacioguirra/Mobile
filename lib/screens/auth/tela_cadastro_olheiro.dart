// lib/screens/auth/tela_cadastro_olheiro.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';

class TelaCadastroOlheiro extends StatefulWidget {
  const TelaCadastroOlheiro({super.key});

  @override
  State<TelaCadastroOlheiro> createState() => _TelaCadastroOlheiroState();
}

class _TelaCadastroOlheiroState extends State<TelaCadastroOlheiro> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _clubeCtrl = TextEditingController();
  bool _carregando = false;
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _clubeCtrl.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      await context.read<AuthService>().cadastrarOlheiro(
            nome: _nomeCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            senha: _senhaCtrl.text.trim(),
            clube: _clubeCtrl.text.trim(),
          );

      // ✅ CORREÇÃO: após cadastro bem-sucedido, remove toda a pilha de navegação
      // e retorna ao AuthGate, que detecta o novo estado e redireciona para
      // TelaHomeOlheiro automaticamente.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta — Olheiro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cadastro de Olheiro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Encontre talentos em todo o Brasil.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 32),

              _campo(_nomeCtrl, 'Nome completo', Icons.person_outlined,
                  validator: (v) =>
                      v == null || v.trim().length < 2 ? 'Informe seu nome' : null),
              const SizedBox(height: 16),

              _campo(_clubeCtrl, 'Clube ou organização', Icons.business_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe o clube' : null),
              const SizedBox(height: 16),

              _campo(_emailCtrl, 'E-mail', Icons.email_outlined,
                  tipo: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'E-mail inválido' : null),
              const SizedBox(height: 16),

              TextFormField(
                controller: _senhaCtrl,
                obscureText: !_senhaVisivel,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _senhaVisivel ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _senhaVisivel = !_senhaVisivel),
                  ),
                ),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 32),

              // Info sobre verificação
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.azul.withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.azulInfo, size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Olheiros têm acesso completo aos perfis e vídeos dos atletas.',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _carregando ? null : _cadastrar,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('CRIAR CONTA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType tipo = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
      validator: validator,
    );
  }
}
