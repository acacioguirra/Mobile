

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {

  final String nomeContato;

  const ChatScreen({super.key, required this.nomeContato});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  final TextEditingController _controller = TextEditingController();


  final ScrollController _scrollController = ScrollController();


  final List<Map<String, dynamic>> _mensagens = [
    {
      'texto': 'Vimos seu vídeo. Teria disponibilidade para um teste segunda?',
      'enviada': false, // mensagem recebida
      'remetente': 'Scout Bahia de Feira',
    },
    {
      'texto': 'Com certeza! Estarei lá.',
      'enviada': true, // mensagem enviada por mim
      'remetente': 'Eu',
    },
  ];


  void _enviarMensagem() {
    final texto = _controller.text.trim();


    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add({
        'texto': texto,
        'enviada': true,
        'remetente': 'Eu',
      });
    });


    _controller.clear();


    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }


  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.nomeContato,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Text(
              'Online',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 11,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),


      body: Column(
        children: [


          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _mensagens.length,
              itemBuilder: (context, index) {
                final msg = _mensagens[index];
                return _BolhaMensagem(
                  texto: msg['texto'] as String,
                  enviada: msg['enviada'] as bool,
                  remetente: msg['remetente'] as String,
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: const Color(0xFF0A0A0A),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Mensagem...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF1C2333),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    // Envia ao pressionar "Enter" no teclado
                    onSubmitted: (_) => _enviarMensagem(),
                  ),
                ),

                const SizedBox(width: 8),

                // ── Botão de envio ───────────────────
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF4CAF50),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _enviarMensagem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BolhaMensagem extends StatelessWidget {
  final String texto;
  final bool enviada;
  final String remetente;

  const _BolhaMensagem({
    required this.texto,
    required this.enviada,
    required this.remetente,
  });

  @override
  Widget build(BuildContext context) {
    return Align(

      alignment: enviada ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(

          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: enviada
              ? const Color(0xFF4CAF50) // verde para enviadas
              : const Color(0xFF1C2333), // azul escuro para recebidas
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(enviada ? 16 : 0),
            bottomRight: Radius.circular(enviada ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (!enviada) ...[
              Text(
                remetente,
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              texto,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
