// dashboard_page.dart
import 'package:barberapp/main.dart';
import 'package:barberapp/schedule_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'contact_page.dart';
import 'edit_profile_page.dart';
import 'agenda_page.dart'; // Certifique-se de que você importou a página da agenda

class DashboardPage extends StatelessWidget {
  // Função para obter o token do SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Função para obter a role do usuário
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  // Função de logout com o context
  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token != null) {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:8000/api/logout'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token', // Usa o token aqui
          },
        );

        if (response.statusCode == 200) {
          await prefs.remove('auth_token');
          await prefs.remove('user_role');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          print('Falha no logout: ${response.statusCode} - ${response.body}');
        }
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
        child: FutureBuilder<String?>(
          future: getUserRole(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final userRole = snapshot.data;

            return ListView(
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
                // Exibe a agenda administrativa somente se o usuário for admin
                if (userRole == 'admin')
                  ListTile(
                    title: Text('Agenda Administrativa'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AgendaPage()),
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
            );
          },
        ),
      ),
      body: Center(
        child: Text('Bem-vindo ao Dashboard'),
      ),
    );
  }
}
