// Tela acionamento
import 'package:flutter/material.dart';
import 'package:integrador/services/iot_service.dart';

class Telaacionamento extends StatefulWidget {
  const Telaacionamento({super.key});

  @override
  State<Telaacionamento> createState() => _TelaacionamentoState();
}

class _TelaacionamentoState extends State<Telaacionamento> {
  bool _pumpOn = false;
  bool _loading = false;
  String _statusMessage = 'Aguardando comando';

  Future<void> _sendPumpCommand(bool turnOn) async {
    setState(() {
      _loading = true;
    });

    try {
      await IotService.sendPumpCommand(turnOn);
      if (!mounted) return;
      setState(() {
        _pumpOn = turnOn;
        _statusMessage = turnOn ? 'Bomba ligada com sucesso' : 'Bomba desligada com sucesso';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_statusMessage),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Falha ao enviar comando';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: ${error.toString()}'),
          backgroundColor: Colors.red[700],
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _loading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Row(
          children: [
            Image.asset('images/AgroGoais.png', height: 34),
            const SizedBox(width: 10),
            const Text('Acionamento AgroGoais'),
          ],
        ),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Controle manual da bomba',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: _pumpOn ? Colors.green[100] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          _pumpOn ? 'Ligada' : 'Desligada',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _pumpOn ? Colors.green[800] : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _loading ? null : () => _sendPumpCommand(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _loading
                  ? const SizedBox(
                      height: 24,
                      child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)),
                    )
                  : const Text('Ligar bomba'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : () => _sendPumpCommand(false),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Desligar bomba'),
            )
          ],
        ),
      ),
    );
  }
}