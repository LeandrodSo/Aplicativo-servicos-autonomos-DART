import 'package:app_servicos/SubTopicos/Eletricista.dart';
import 'package:app_servicos/SubTopicos/Encanador.dart';
import 'package:app_servicos/SubTopicos/Marceneiro.dart';
import 'package:app_servicos/SubTopicos/Pedreiro.dart';
import 'package:app_servicos/SubTopicos/T%C3%A9cnicoArCondicionado.dart';
import 'package:app_servicos/SubTopicos/T%C3%A9cnicoEletrodom%C3%A9stico.dart';
import 'package:flutter/material.dart';

class Manutencao extends StatelessWidget {
  final int userId;

  Manutencao({required this.userId});
  final List<String> professions = [
    'Encanador',
    'Eletricista',
    'Marceneiro',
    'Técnico de Ar Condicionado',
    'Técnico de Reparo de Eletrodomésticos',
    'Pedreiro',
  ];

  void handleProfessionTap(BuildContext context, String profession) {
    // Navegue para telas diferentes com base na profissão selecionada
    if (profession == 'Encanador') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEncanador(userId: userId),
      ));
    } else if (profession == 'Eletricista') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEletricista(userId: userId),
      ));
    } else if (profession == 'Marceneiro') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaMarceneiro(userId: userId),
      ));
    } else if (profession == 'Técnico de Ar Condicionado') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaTecnicoArCondicionado(userId: userId),
      ));
    } else if (profession == 'Técnico de Reparo de Eletrodomésticos') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaTecnicoEletrodomestico(userId: userId),
      ));
    } else if (profession == 'Pedreiro') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaPedreiro(userId: userId),
      ));
    } else {
      // Adicione outras profissões e ações aqui
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Lista de Profissões'),
          backgroundColor: Colors.blue,
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.home), // Ícone no canto superior direito
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: professions.length,
          itemBuilder: (context, index) {
            final profession = professions[index];
            return Card(
              elevation: 4,
              margin: EdgeInsets.all(8),
              child: ListTile(
                onTap: () {
                  // Chame a função de manipulação quando o item for pressionado
                  handleProfessionTap(context, profession);
                },
                title: Text(profession),
                leading: Icon(Icons.work),
              ),
            );
          },
        ),
      ),
    );
  }
}
