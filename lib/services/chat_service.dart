import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatService {
  /// Atualize esta URL para o endereço do Langflow que expõe o endpoint de chat.
  /// Exemplo: http://192.168.0.100:8686
  static const String baseUrl = 'http://<LANGFLOW_URL>';

  /// Ajuste este endpoint conforme a configuração do seu Langflow.
  static const String chatEndpoint = '/api/v1/chat/completions';

  /// Se o Langflow exigir autenticação, configure aqui.
  static const String? apiKey = null;

  static Future<String> sendMessage(String message) async {
    final uri = Uri.parse('$baseUrl$chatEndpoint');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (apiKey != null && apiKey!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }

    final body = jsonEncode({
      'model': 'gpt-3.5-turbo',
      'messages': [
        {'role': 'user', 'content': message},
      ],
      'temperature': 0.7,
      'max_tokens': 500,
    });

    final response = await http.post(uri, headers: headers, body: body);

    if (response.statusCode != 200) {
      throw Exception('Falha no chat: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body);
    return _parseChatResponse(data);
  }

  static String _parseChatResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'];
      if (data['response'] is String) return data['response'];
      if (data['output'] is String) return data['output'];
      if (data['choices'] is List && data['choices'].isNotEmpty) {
        final first = data['choices'][0];
        if (first is Map<String, dynamic>) {
          if (first['message'] is Map<String, dynamic>) {
            final message = first['message'] as Map<String, dynamic>;
            final content = message['content'];
            if (content is String) return content;
            if (content is Map<String, dynamic> && content['text'] is String) {
              return content['text'] as String;
            }
          }
          if (first['text'] is String) return first['text'] as String;
        }
      }
    }
    return data.toString();
  }
}
