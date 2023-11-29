import 'package:app_servicos/SubTopicos/Carreto.dart';
import 'package:app_servicos/SubTopicos/Entregador.dart';
import 'package:app_servicos/SubTopicos/Mensageiro.dart';
import 'package:app_servicos/SubTopicos/MotoristaAplicativo.dart';
import 'package:flutter/material.dart';

class Entrega extends StatelessWidget {
  final int userId;

  Entrega({required this.userId});
  final List<String> professions = [
    'Entregador',
    'Motorista de Aplicativo',
    'Mensageiro',
    'Carreto',
  ];

  void handleProfessionTap(BuildContext context, String profession) {
    // Navegue para telas diferentes com base na profissão selecionada
    if (profession == 'Entregador') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEntregador(userId: userId),
      ));
    } else if (profession == 'Motorista de Aplicativo') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaMotoristaAplicativo(userId: userId),
      ));
    } else if (profession == 'Mensageiro') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaMensageiro(userId: userId),
      ));
    } else if (profession == 'Carreto') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaCarreto(userId: userId),
      ));
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
