import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false; // Controle para mostrar que o bot está "digitando"

  void _sendMessage() async {
    final apiKey = dotenv.env['LANGFLOW_API_KEY'];
    final userMessage = _controller.text.trim();
    const String url = "http://localhost:7860/api/v1/run/d60cfa5c-700c-4a53-b2d6-8d8b1b2bc06a";

    if (apiKey == null || apiKey.isEmpty) {
      _showError("LangFlow Api Key não encontrada no .env");
      return;
    }

    if (userMessage.isEmpty) return;

    // Captura o tempo antes da chamada assíncrona
    final timeNow = TimeOfDay.now().format(context);

    setState(() {
      _messages.add({
        'text': userMessage,
        'isMe': true,
        'time': timeNow,
      });
      _controller.clear();
      _isLoading = true; // Ativa o indicador de carregamento
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": apiKey
        },
        body: jsonEncode({
          "input_value": userMessage,
          "output_type": "chat",
          "input_type": "chat"
        }),
      );

      // Verificação de segurança obrigatória no Flutter moderno após um await
      if (!mounted) return; 

      final botTime = TimeOfDay.now().format(context);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        print("Resposta da API: $decoded");
        
        final botReply = decoded["outputs"]?[0]?["outputs"]?[0]?["results"]?["message"]?["text"] ?? "Não consegui entender!";
        
        setState(() {
          _isLoading = false;
          _messages.add({
            'text': botReply,
            'isMe': false,
            'time': botTime
          });
        });
      } else {
        setState(() {
          _isLoading = false;
          _messages.add({
            'text': 'Erro ao obter resposta do assistente (Status: ${response.statusCode})',
            'isMe': false,
            'time': botTime
          });
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _messages.add({
          'text': 'Erro de conexão: $e',
          'isMe': false,
          'time': TimeOfDay.now().format(context)
        });
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _limparMessages() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Fundo leve para destacar mensagens
      appBar: AppBar(
        backgroundColor: Colors.green.shade700, // Cor verde solicitada
        elevation: 2,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Image.asset("images/logo_chat.png", height: 40),
            ),
            const SizedBox(width: 12),
            const Text(
              'Chat Agro Tech',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _limparMessages,
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            tooltip: 'Limpar Conversa',
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return MessageBubble(
                  text: msg['text'],
                  isMe: msg['isMe'],
                  time: msg['time'],
                );
              },
            ),
          ),
          
          // Indicador de digitação
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text("Assistente digitando...", style: TextStyle(color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
                ],
              ),
            ),

          // Área de input de texto
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                )
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem...',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green.shade600,
                    radius: 24,
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const MessageBubble({
    required this.text,
    required this.isMe,
    required this.time,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        // Limita a largura máxima do balão para não ocupar a tela toda
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? Colors.green.shade100 : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            // Cantos assimétricos dependendo de quem envia
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isMe ? const Radius.circular(2) : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(1, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            )
          ],
        ),
      ),
    );
  }
}