import 'package:flutter/material.dart';

class AgendaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda Administrativa'),
      ),
      body: Center(
        child: Text('Bem-vindo à agenda do administrador.'),
      ),
    );
  }
}
