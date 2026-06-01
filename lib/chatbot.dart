import 'package:flutter/material.dart';
import 'package:integrador/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        'text': text,
        'isMe': true,
        'time': TimeOfDay.now().format(context),
      });
      _controller.clear();
      _loading = true;
    });

    try {
      final response = await ChatService.sendMessage(text);
      if (!mounted) return;
      setState(() {
        _messages.add({
          'text': response,
          'isMe': false,
          'time': TimeOfDay.now().format(context),
        });
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro no chatbot: ${error.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  void _clearMessages() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
          title: Text('Chatbot',style: TextStyle(color: Colors.white),),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: _messages.length,
              itemBuilder: (context,index){
                final msg = _messages[index];
                return  MessageBuble(
                  text: msg['text'], isMe: msg['isMe'], time: msg['time']);
              })
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 8,vertical: 4
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Digite sua mensagem',
                          border: InputBorder.none
                        ),
                        
                      ),
                      
                      ),
                      _loading
                          ? const SizedBox(
                              width: 40,
                              height: 40,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(strokeWidth: 2.5),
                              ),
                            )
                          : IconButton(
                              onPressed: _sendMessage,
                              icon: const Icon(Icons.send, color: Colors.teal),
                            ),
                      IconButton(onPressed: _clearMessages, icon: const Icon(Icons.clear, color: Colors.teal)),
                  ],
                ),
                )
        ],
      ),
    );
  }
}



class MessageBuble extends StatelessWidget{
  // cria variaveis e construtor 

  final String text;
  final bool isMe;
  final String time;
  const MessageBuble({super.key, required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Align(
      alignment: isMe? Alignment.centerRight:Alignment.center,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe?Colors.green[100]:Colors.grey[300],
              borderRadius: BorderRadius.circular(12)
            ),
            child: Text(text),
          ),
          Text(time,style: TextStyle(fontSize: 10,color: Colors.grey),)
        ],
      ),
    );
  }
}