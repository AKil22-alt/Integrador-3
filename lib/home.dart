// importa a biblioteca que permite criar os widgets
import 'package:integrador/dashboard.dart';
import 'package:integrador/chatbot.dart';
import 'package:integrador/controlador.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: DashboardScreen()),
  );
}

// Cria a classe do tipo Stateless
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // polimorfismo que permite tratar as funções de forma diferente
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cria o Drawer propriedade que permite criar um elemento lateral
      drawer: Drawer(
        child: ListView(
          // adicionando espaçamento com padding
          padding: EdgeInsets.zero,
          children: [
            // DrawerHeader
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.green[700]),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.analytics, color: Colors.green[700]),
              title: const Text('Monitoramento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ColetaDadosScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.settings_remote_outlined,
                color: Colors.green[700],
              ),
              title: const Text('Acionamento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Telaacionamento()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.smart_toy_outlined, color: Colors.green[700]),
              title: const Text('Chatbot'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatScreen()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        elevation: 5,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Row(
          children: [
            Image.asset('images/AgroGoais.png', height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: const Text(
                'AgroGoais',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.person, color: Colors.green),
            ),
          ],
        ),
      ),

      backgroundColor: const Color(0xFFE8F5E9),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('images/AgroGoais.png', height: 48),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'AGRO TECH GOIÁS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Irrigação Inteligente com Monitoramento em Tempo Real',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Clientes corporativos no segmento agrícola enfrentam dificuldades em controlar o uso eficiente de água e energia, pois o manejo é feito com base em monitoramento manual. Isso ocasiona desperdício de água, custos crescentes de energia elétrica e baixa precisão na irrigação.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'A proposta consiste no desenvolvimento de um sistema completo de monitoramento e controle, que combina IoT, integração horizontal e vertical, aplicativo mobile, computação em nuvem e Chatbot.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Acesso rápido',
            style: TextStyle(
              color: Color(0xFF1B5E20),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _DashboardButton(
            icon: Icons.analytics,
            label: 'Monitoramento',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ColetaDadosScreen()),
              );
            },
          ),
          const SizedBox(height: 12),
          _DashboardButton(
            icon: Icons.settings_remote_outlined,
            label: 'Acionamento',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Telaacionamento()),
              );
            },
          ),
          const SizedBox(height: 12),
          _DashboardButton(
            icon: Icons.smart_toy_outlined,
            label: 'Chatbot',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Cria a classe Dashboard Button

class _DashboardButton extends StatelessWidget {
  // Cria atributos para a classe

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  // cria o construtor
  const _DashboardButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Widget novo
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
          child: Row(
            children: [
              Icon(icon, color: Colors.brown, size: 40),
              SizedBox(width: 16),
              Text(label, style: TextStyle(fontSize: 18, color: Colors.brown)),
            ],
          ),
        ),
      ),
    );
  }
}
