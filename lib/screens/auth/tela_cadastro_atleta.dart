// lib/screens/auth/tela_cadastro_atleta.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/atleta_service.dart';
import '../../models/atleta_model.dart';
import '../../utils/app_colors.dart';

class TelaCadastroAtleta extends StatefulWidget {
  const TelaCadastroAtleta({super.key});

  @override
  State<TelaCadastroAtleta> createState() => _TelaCadastroAtletaState();
}

class _TelaCadastroAtletaState extends State<TelaCadastroAtleta> {
  final _formKey = GlobalKey<FormState>();
  int _etapa = 0; // 0 = conta, 1 = perfil esportivo

  // Conta
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  // Perfil esportivo
  final _idadeCtrl = TextEditingController();
  final _cidadeCtrl = TextEditingController();
  final _alturaCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  String _posicao = posicoesFutebol.first;
  String _regiao = regioesBrasil[1]; // Nordeste
  String _pe = 'destro';
  final Set<String> _habilidadesSelecionadas = {};
  bool _carregando = false;
  bool _senhaVisivel = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _idadeCtrl.dispose();
    _cidadeCtrl.dispose();
    _alturaCtrl.dispose();
    _pesoCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      final usuario = await context.read<AuthService>().cadastrarAtleta(
            nome: _nomeCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            senha: _senhaCtrl.text.trim(),
          );

      if (usuario == null) throw 'Erro ao criar conta.';

      final atleta = AtletaModel(
        uid: usuario.uid,
        nome: usuario.nome,
        idade: int.tryParse(_idadeCtrl.text) ?? 0,
        posicao: _posicao,
        cidade: _cidadeCtrl.text.trim(),
        estado: '',
        regiao: _regiao,
        altura: double.tryParse(_alturaCtrl.text.replaceAll(',', '.')) ?? 0,
        peso: double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0,
        pe: _pe,
        videos: [],
        habilidades: _habilidadesSelecionadas.toList(),
        bio: _bioCtrl.text.trim(),
        criadoEm: DateTime.now(),
      );

      await context.read<AtletaService>().salvarPerfil(atleta);

      // ✅ CORREÇÃO: após cadastro bem-sucedido, remove toda a pilha de navegação
      // e retorna ao AuthGate, que detecta o novo estado e redireciona para
      // TelaHomeAtleta automaticamente.
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
      appBar: AppBar(
        title: Text(_etapa == 0 ? 'Criar conta — Atleta' : 'Seu perfil esportivo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: _etapa == 0 ? _etapaConta() : _etapaPerfil(),
        ),
      ),
    );
  }

  Widget _etapaConta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _campo(_nomeCtrl, 'Nome completo', Icons.person_outlined,
            validator: (v) =>
                v == null || v.trim().length < 2 ? 'Informe seu nome' : null),
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
            prefixIcon:
                const Icon(Icons.lock_outlined, color: Colors.grey),
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
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _etapa = 1);
              }
            },
            child: const Text('CONTINUAR'),
          ),
        ),
      ],
    );
  }

  Widget _etapaPerfil() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _campo(_idadeCtrl, 'Idade', Icons.cake_outlined,
                  tipo: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return n == null || n < 10 || n > 50
                        ? 'Idade inválida'
                        : null;
                  }),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(_cidadeCtrl, 'Cidade', Icons.location_city_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a cidade' : null),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _campo(_alturaCtrl, 'Altura (m)', Icons.height,
                  tipo: TextInputType.number),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _campo(_pesoCtrl, 'Peso (kg)', Icons.monitor_weight_outlined,
                  tipo: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Posição
        _labelCampo('Posição'),
        _dropdown(_posicao, posicoesFutebol, (v) => setState(() => _posicao = v!)),
        const SizedBox(height: 16),

        // Região
        _labelCampo('Região'),
        _dropdown(_regiao, regioesBrasil, (v) => setState(() => _regiao = v!)),
        const SizedBox(height: 16),

        // Pé dominante
        _labelCampo('Pé dominante'),
        Row(
          children: ['destro', 'canhoto', 'ambidestro'].map((p) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p[0].toUpperCase() + p.substring(1)),
                  selected: _pe == p,
                  selectedColor: AppColors.verde,
                  onSelected: (_) => setState(() => _pe = p),
                  labelStyle: TextStyle(
                    color: _pe == p ? Colors.white : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Habilidades
        _labelCampo('Habilidades (selecione até 5)'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: habilidadesDisponiveis.map((h) {
            final sel = _habilidadesSelecionadas.contains(h);
            return FilterChip(
              label: Text(h, style: const TextStyle(fontSize: 12)),
              selected: sel,
              selectedColor: AppColors.verde.withOpacity(0.3),
              checkmarkColor: AppColors.verde,
              onSelected: (v) {
                setState(() {
                  if (v && _habilidadesSelecionadas.length < 5) {
                    _habilidadesSelecionadas.add(h);
                  } else {
                    _habilidadesSelecionadas.remove(h);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Bio
        TextFormField(
          controller: _bioCtrl,
          maxLines: 3,
          maxLength: 200,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Fale sobre você (opcional)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _carregando ? null : _finalizar,
            child: _carregando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('CRIAR MEU PERFIL'),
          ),
        ),
      ],
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

  Widget _labelCampo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto,
          style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _dropdown(
      String valor, List<String> opcoes, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          dropdownColor: AppColors.card,
          iconEnabledColor: Colors.white,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: opcoes
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
