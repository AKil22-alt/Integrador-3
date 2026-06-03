import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SensorReadings {
  final double temperature;
  final double humidityAir;
  final double soilMoisture;
  final bool pumpOn;
  final DateTime timestamp;
  final String sensorId;

  SensorReadings({
    required this.temperature,
    required this.humidityAir,
    required this.soilMoisture,
    required this.pumpOn,
    required this.timestamp,
    required this.sensorId,
  });

  factory SensorReadings.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> payload = {};

    dynamic rawValue = json['jsonValue'] ?? json['valor_json'] ?? json['valorJson'];
    if (rawValue is String) {
      try {
        final decoded = jsonDecode(rawValue);
        if (decoded is Map<String, dynamic>) {
          payload = decoded;
        }
      } catch (_) {
        payload = {};
      }
    } else if (rawValue is Map<String, dynamic>) {
      payload = rawValue;
    }

    final merged = {...json, ...payload};

    double parseDouble(String key) {
      final dynamic value = merged[key];
      if (value is num) return value.toDouble();
      if (value is String) {
        final parsed = double.tryParse(value.replaceAll(',', '.'));
        return parsed ?? 0.0;
      }
      return 0.0;
    }

    bool parseBool(String key) {
      final dynamic value = merged[key];
      if (value is bool) return value;
      if (value is num) return value == 1;
      if (value is String) {
        return value.toLowerCase() == 'true' || value == '1';
      }
      return false;
    }

    DateTime parseTimestamp() {
      final dynamic value = json['createdAt'] ?? json['timestamp'] ?? json['data_hora'] ?? json['time'];
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return SensorReadings(
      temperature: parseDouble('temperature'),
      humidityAir: parseDouble('humidity_air') > 0 ? parseDouble('humidity_air') : parseDouble('humidityAir'),
      soilMoisture: parseDouble('soil_moisture') > 0 ? parseDouble('soil_moisture') : parseDouble('soilMoisture'),
      pumpOn: parseBool('pump') || parseBool('pump_on') || parseBool('pumpOn'),
      timestamp: parseTimestamp(),
      sensorId: json['sensorId']?.toString() ?? '',
    );
  }
}

class IotService {
  /// Atualizar esta URL para o endereço do backend NestJS.
  static const String baseUrl = 'http://localhost:3000';
  static const String dataEndpoint = '/data';

  static Future<SensorReadings> fetchSensorReadings() async {
    // Se estiver em modo demonstração, retornar dados simulados localmente
    try {
      final prefs = await SharedPreferences.getInstance();
      final demo = prefs.getBool('demo_mode') ?? false;
      if (demo) {
        final now = DateTime.now();
        final rnd = Random(now.millisecondsSinceEpoch);
        final double temperature = 18 + rnd.nextDouble() * 12; // 18..30
        final double humidityAir = 35 + rnd.nextDouble() * 50; // 35..85
        final double soilMoisture = 25 + rnd.nextDouble() * 60; // 25..85
        final bool pumpOn = rnd.nextBool();

        return SensorReadings(
          temperature: double.parse(temperature.toStringAsFixed(1)),
          humidityAir: double.parse(humidityAir.toStringAsFixed(1)),
          soilMoisture: double.parse(soilMoisture.toStringAsFixed(1)),
          pumpOn: pumpOn,
          timestamp: now,
          sensorId: 'DEMO_SENSOR',
        );
      }
    } catch (_) {
      // se falhar ao verificar prefs, cair para modo real
    }

    final uri = Uri.parse('$baseUrl$dataEndpoint');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode != 200) {
      throw Exception('Falha ao carregar dados: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final List<dynamic> items = decoded is List ? decoded : [decoded];

    if (items.isEmpty) {
      throw Exception('Nenhum dado de telemetria encontrado');
    }

    items.sort((a, b) {
      final aDate = _parseDate(a['createdAt'] ?? a['data_hora'] ?? a['timestamp']);
      final bDate = _parseDate(b['createdAt'] ?? b['data_hora'] ?? b['timestamp']);
      return bDate.compareTo(aDate);
    });

    return SensorReadings.fromJson(items.first as Map<String, dynamic>);
  }

  static Future<void> sendPumpCommand(bool activate) async {
    // Em modo demonstração apenas simula o envio sem fazer requisição
    try {
      final prefs = await SharedPreferences.getInstance();
      final demo = prefs.getBool('demo_mode') ?? false;
      if (demo) return; // ignora envio real em demonstração
    } catch (_) {
      // ignore
    }

    final uri = Uri.parse('$baseUrl$dataEndpoint');
    final body = jsonEncode({
      'sensorId': 'REPLACE_WITH_SENSOR_ID',
      'jsonValue': jsonEncode({'pump': activate}),
    });

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Falha ao enviar comando: ${response.statusCode}');
    }
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}
