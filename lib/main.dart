import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dashboard_page.dart';
import 'register_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barber App',
      theme: ThemeData(
        primaryColor: Color(0xFF212121),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Color(0xFF1DE9B6)),
        scaffoldBackgroundColor: Color(0xFFFFFFFF),
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF424242)),
          headlineMedium: TextStyle(color: Color(0xFF212121), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF212121),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/login'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': emailController.text,
            'password': passwordController.text,
          }),
        );
        print('Resposta do servidor: ${response.body}');
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('Dados do access_token: ${responseData['access_token']}');

          // Aqui você pega o access_token corretamente
          final accessToken = responseData['access_token'];

          if (accessToken != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', accessToken); // Armazena o token corretamente

            final role = responseData['role'];
            await prefs.setString('user_role', role);

            // Redireciona para Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => DashboardPage()),
            );
          } else {
            setState(() {
              errorMessage = 'Erro de autenticação. Token inválido.';
            });
          }
        } else {
          setState(() {
            errorMessage = 'Usuário inválido. Por favor, realizar cadastro.';
          });
        }
      } catch (e) {
        print('Erro ao fazer login: $e');
        setState(() {
          errorMessage = 'Erro ao realizar login. Tente novamente.';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Preencha todos os campos.';
      });
    }

    // Limpar mensagem de erro após um tempo
    Future.delayed(Duration(seconds: 4), () {
      setState(() {
        errorMessage = null;
      });
    });
  }

  Future<void> someApiCall() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/some_endpoint'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Marquinhos - BarberShop'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email inválido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Senha inválida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 10),
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
      ),
    );
  }
}
