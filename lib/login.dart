import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cadastro.dart';
import 'home.dart';

// Página de login principal do aplicativo
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto de email e senha
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void dispose() {
    // Limpa os controladores ao remover o widget
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<String?> _fazerLogin() async {
    String email = _emailController.text.trim();
    String senha = _senhaController.text;

    if (email.isEmpty || senha.isEmpty) {
      return 'Preencha email e senha';
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Modo demonstração
    if (email == 'Demonstracao' && senha == '123456') {
      await prefs.setBool('demo_mode', true);
      return null; // sucesso em modo demonstração
    }

    String? senhaSalva = prefs.getString(email);

    if (senhaSalva == null || senhaSalva != senha) {
      return 'Email ou senha incorretos';
    }

    // Login normal: desativa modo demonstração caso estivesse ativo
    await prefs.setBool('demo_mode', false);

    return null; // Success
  }

  @override
  Widget build(BuildContext context) {
    // Constrói a interface de login com campos e botões
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  Center(
                    child: Column(
                      children: [
                        Image.asset('images/AgroGoais.png', height: 100),
                        const SizedBox(height: 16),
                        const Text(
                          'Agro Tech Goiás',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  _buildTextField('Email', _emailController),
                  const SizedBox(height: 16),
                  _buildTextField('Senha', _senhaController, obscureText: true),
                  const SizedBox(height: 28),
                  _buildPrimaryButton('Login', () async {
                    String? error = await _fazerLogin();
                    if (!mounted) return;
                    if (error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error)),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login realizado com sucesso')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                    }
                  }),
                  const SizedBox(height: 14),
                  _buildSecondaryButton('Não tenho conta', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CadastroPage(),
                      ),
                    );
                  }),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Cria um campo de texto com rótulo personalizado
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Botão principal para ação de login
  Widget _buildPrimaryButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  // Botão secundário para navegação até a tela de cadastro
  Widget _buildSecondaryButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }
}
