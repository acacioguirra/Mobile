// lib/screens/atleta/tela_editar_perfil_atleta.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/atleta_service.dart';
import '../../models/atleta_model.dart';
import '../../utils/app_colors.dart';

class TelaEditarPerfilAtleta extends StatefulWidget {
  final AtletaModel atleta;
  const TelaEditarPerfilAtleta({super.key, required this.atleta});

  @override
  State<TelaEditarPerfilAtleta> createState() => _TelaEditarPerfilAtletaState();
}

class _TelaEditarPerfilAtletaState extends State<TelaEditarPerfilAtleta> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeCtrl;
  late TextEditingController _idadeCtrl;
  late TextEditingController _cidadeCtrl;
  late TextEditingController _alturaCtrl;
  late TextEditingController _pesoCtrl;
  late TextEditingController _bioCtrl;
  
  late String _posicao;
  late String _regiao;
  late String _pe;
  late Set<String> _habilidadesSelecionadas;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.atleta.nome);
    _idadeCtrl = TextEditingController(text: widget.atleta.idade.toString());
    _cidadeCtrl = TextEditingController(text: widget.atleta.cidade);
    _alturaCtrl = TextEditingController(text: widget.atleta.altura.toString());
    _pesoCtrl = TextEditingController(text: widget.atleta.peso.toString());
    _bioCtrl = TextEditingController(text: widget.atleta.bio);
    _posicao = widget.atleta.posicao;
    _regiao = widget.atleta.regiao;
    _pe = widget.atleta.pe;
    _habilidadesSelecionadas = Set.from(widget.atleta.habilidades);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    _cidadeCtrl.dispose();
    _alturaCtrl.dispose();
    _pesoCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _carregando = true);

    try {
      final atletaAtualizado = AtletaModel(
        uid: widget.atleta.uid,
        nome: _nomeCtrl.text.trim(),
        idade: int.tryParse(_idadeCtrl.text) ?? 0,
        posicao: _posicao,
        cidade: _cidadeCtrl.text.trim(),
        estado: widget.atleta.estado,
        regiao: _regiao,
        altura: double.tryParse(_alturaCtrl.text.replaceAll(',', '.')) ?? 0,
        peso: double.tryParse(_pesoCtrl.text.replaceAll(',', '.')) ?? 0,
        pe: _pe,
        fotoPerfil: widget.atleta.fotoPerfil,
        videos: widget.atleta.videos,
        habilidades: _habilidadesSelecionadas.toList(),
        bio: _bioCtrl.text.trim(),
        criadoEm: widget.atleta.criadoEm,
      );

      await context.read<AtletaService>().salvarPerfil(atletaAtualizado);
      
      if (mounted) {
        Navigator.pop(context);
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
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _campo(_nomeCtrl, 'Nome completo', Icons.person_outlined),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _campo(_idadeCtrl, 'Idade', Icons.cake_outlined, tipo: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_cidadeCtrl, 'Cidade', Icons.location_city_outlined)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _campo(_alturaCtrl, 'Altura (m)', Icons.height, tipo: TextInputType.number)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_pesoCtrl, 'Peso (kg)', Icons.monitor_weight_outlined, tipo: TextInputType.number)),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text('Posição', style: TextStyle(color: Colors.grey, fontSize: 13)),
              _dropdown(_posicao, posicoesFutebol, (v) => setState(() => _posicao = v!)),
              const SizedBox(height: 16),

              const Text('Região', style: TextStyle(color: Colors.grey, fontSize: 13)),
              _dropdown(_regiao, regioesBrasil, (v) => setState(() => _regiao = v!)),
              const SizedBox(height: 16),

              const Text('Pé dominante', style: TextStyle(color: Colors.grey, fontSize: 13)),
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
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              const Text('Habilidades (até 5)', style: TextStyle(color: Colors.grey, fontSize: 13)),
              Wrap(
                spacing: 8,
                children: habilidadesDisponiveis.map((h) {
                  final sel = _habilidadesSelecionadas.contains(h);
                  return FilterChip(
                    label: Text(h, style: const TextStyle(fontSize: 12)),
                    selected: sel,
                    onSelected: (v) {
                      setState(() {
                        if (v && _habilidadesSelecionadas.length < 5) {
                          _habilidadesSelecionadas.add(h);
                        } else if (!v) _habilidadesSelecionadas.remove(h);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bioCtrl,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Bio'),
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

  Widget _campo(TextEditingController ctrl, String label, IconData icon, {TextInputType tipo = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: tipo,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: Colors.grey)),
      validator: (v) => v == null || v.isEmpty ? 'Obrigatório' : null,
    );
  }

  Widget _dropdown(String valor, List<String> opcoes, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: valor,
          isExpanded: true,
          dropdownColor: AppColors.card,
          style: const TextStyle(color: Colors.white),
          items: opcoes.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
