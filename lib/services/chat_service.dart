import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatService {
  /// O endereço do Langflow 
  static final String baseUrl = dotenv.env['LANGFLOW_URL']?.trim() ?? '';

  /// Endpoint Langflow.
  static const String chatEndpoint = '/api/v1/chat/completions';

  /// A chave de API do Langflow
  static final String? apiKey = dotenv.env['LANGFLOW_API_KEY']?.trim();

  static Future<String> sendMessage(String message) async {
    if (baseUrl.isEmpty) {
      throw Exception('LANGFLOW_URL não definido em .env');
    }

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

    final response = await http.post(uri, headers: headers, body: body).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw Exception('Tempo limite excedido ao enviar a mensagem.'),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha no chat: ${response.statusCode} ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body);
    return _parseChatResponse(data);
  }

  static String _parseChatResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      if (data['message'] is String) return data['message'] as String;
      if (data['response'] is String) return data['response'] as String;
      if (data['output'] is String) return data['output'] as String;

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
