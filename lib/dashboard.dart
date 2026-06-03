// criando a segunda tela do aplicativo

import 'package:flutter/material.dart';
import 'package:integrador/services/iot_service.dart';

class ColetaDadosScreen extends StatefulWidget {
  const ColetaDadosScreen({super.key});

  @override
  State<ColetaDadosScreen> createState() => _ColetaDadosScreenState();
}

class _ColetaDadosScreenState extends State<ColetaDadosScreen> {
  SensorReadings? _readings;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final readings = await IotService.fetchSensorReadings();
      if (!mounted) return;
      setState(() {
        _readings = readings;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }

  Widget _buildStatusCard(String title, String value, String subtitle, Color color, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: color.withAlpha(38),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal[700],
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Image.asset('images/AgroGoais.png', height: 34),
            const SizedBox(width: 10),
            const Text('Monitoramento'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      Card(
                        margin: const EdgeInsets.only(top: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Erro ao carregar dados',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text(_errorMessage ?? 'Ocorreu um problema inesperado.'),
                              const SizedBox(height: 14),
                              ElevatedButton(
                                onPressed: _loadData,
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700]),
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.05),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Dados em tempo real',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                              'Última atualização: ${_readings?.timestamp.toLocal().toString().split('.').first ?? '--'}',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildStatusCard(
                        'Temperatura',
                        '${_readings?.temperature.toStringAsFixed(1)} °C',
                        'Nível ideal para o cultivo',
                        Colors.orange.shade700,
                        Icons.thermostat,
                      ),
                      _buildStatusCard(
                        'Umidade do ar',
                        '${_readings?.humidityAir.toStringAsFixed(1)} %',
                        'Umidade relativa do ambiente',
                        Colors.lightBlue.shade700,
                        Icons.cloud,
                      ),
                      _buildStatusCard(
                        'Umidade do solo',
                        '${_readings?.soilMoisture.toStringAsFixed(1)} %',
                        'Verifique as condições da irrigação',
                        Colors.green.shade700,
                        Icons.water_drop,
                      ),
                      _buildStatusCard(
                        'Bomba de irrigação',
                        _readings?.pumpOn == true ? 'Ligada' : 'Desligada',
                        'Controle manual disponível na aba Acionamento',
                        _readings?.pumpOn == true ? Colors.green : Colors.grey,
                        Icons.power,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Puxe para atualizar',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
      ),
    );
  }
}
 