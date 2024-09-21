// dashboard_page.dart
import 'package:barberapp/main.dart';
import 'package:barberapp/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'contact_page.dart';
import 'edit_profile_page.dart';

class DashboardPage extends StatelessWidget {
  // Função para obter o token do SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Função de logout com o context
  Future<void> logout(BuildContext context) async {
    try {
      final token = await getToken();

      if (token == null) {
        print('Usuário não autenticado');
        return;
      }

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Logout bem-sucedido');

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');

        // Redireciona para a tela de login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        print('Falha no logout: ${response.body}');
      }
    } catch (e) {
      print('Erro ao fazer logout: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: Text('Agendar Corte'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulePage()),
                );
              },
            ),
            ListTile(
              title: Text('Editar Cadastro'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()),
                );
              },
            ),
            ListTile(
              title: Text('Contato'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactPage()),
                );
              },
            ),
            ListTile(
              title: Text('Sair'),
              onTap: () async {
                await logout(context); // Passa o contexto para a função logout
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Bem-vindo ao Dashboard'),
      ),
    );
  }
}
