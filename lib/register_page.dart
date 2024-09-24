// register_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> register() async {
    setState(() {
      errorMessage = ''; // Limpar mensagens de erro anteriores
    });

    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    // Validações
    if (name.isEmpty || name.length > 128) {
      setState(() {
        errorMessage = 'Nome é obrigatório e deve ter no máximo 128 caracteres';
      });
      _clearErrorMessageAfterDelay(); // Limpa após 4 segundos
      return;
    }

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() {
        errorMessage = 'Email inválido';
      });
      _clearErrorMessageAfterDelay(); // Limpa após 4 segundos
      return;
    }

    if (password.isEmpty || password.length < 6 || password.length > 16) {
      setState(() {
        errorMessage = 'A senha deve ter entre 6 e 16 caracteres';
      });
      _clearErrorMessageAfterDelay(); // Limpa após 4 segundos
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/register'),
        body: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      print('Resposta do backend: ${response.body}');
      if (response.statusCode == 201) {
        Navigator.pop(context); // Voltar após registro bem-sucedido
      } else {
        setState(() {
          errorMessage = 'Erro ao cadastrar: ${response.body}';
        });
        _clearErrorMessageAfterDelay(); // Limpa após 4 segundos
      }
    } catch (e) {
      print('Erro ao fazer registro: $e');
      setState(() {
        errorMessage = 'Erro ao se conectar ao servidor';
      });
      _clearErrorMessageAfterDelay(); // Limpa após 4 segundos
    }
  }

  // Função para limpar a mensagem de erro após 4 segundos
  void _clearErrorMessageAfterDelay() async {
    await Future.delayed(Duration(seconds: 4));
    setState(() {
      errorMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar-se'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: register,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
