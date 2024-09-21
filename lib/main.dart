import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dashboard_page.dart';
import 'register_page.dart';
import 'edit_profile_page.dart';
import 'contact_page.dart';
import 'schedule_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/login'),
        body: {
          'email': emailController.text,
          'password': passwordController.text,
        },
      );
      print('Resposta do backend: ${response.body}');
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['access_token'];

        if(token != null){
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
      } else {
        print('Falha no login: ${response.body}');
      }
    } catch (e) {
      print('Erro ao fazer login: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marquinhos - BarberShop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onPressed: login,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
              },
              child: Text('Cadastrar-se'),
            ),
          ],
        ),
      ),
    );
  }
}
