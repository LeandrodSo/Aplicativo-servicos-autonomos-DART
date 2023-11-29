import 'package:app_servicos/SubTopicos/Cabeleireiro.dart';
import 'package:app_servicos/SubTopicos/Esteticista.dart';
import 'package:app_servicos/SubTopicos/ManicurePedicure.dart';
import 'package:app_servicos/SubTopicos/Maquiador.dart';
import 'package:app_servicos/SubTopicos/Nutricionista.dart';
import 'package:app_servicos/SubTopicos/PersonalTrainer.dart';
import 'package:app_servicos/SubTopicos/TratamentoPele.dart';
import 'package:flutter/material.dart';

class BemEstar extends StatelessWidget {
  final int userId;

  BemEstar({required this.userId});
  final List<String> professions = [
    'Cabeleireiro',
    'Maquiador',
    'Manicure e Pedicure',
    'Esteticista',
    'Especialista em Tratamentos de Pele',
    'Personal Trainer',
    'Nutricionista',
  ];

  void handleProfessionTap(BuildContext context, String profession) {
    // Navegue para telas diferentes com base na profissão selecionada
    if (profession == 'Cabeleireiro') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaCabeleireiro(userId: userId),
      ));
    } else if (profession == 'Maquiador') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaMaquiador(userId: userId),
      ));
    } else if (profession == 'Manicure e Pedicure') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaManicurePedicure(userId: userId),
      ));
    } else if (profession == 'Esteticista') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEsteticista(userId: userId),
      ));
    } else if (profession == 'Especialista em Tratamentos de Pele') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaTratamentoPele(userId: userId),
      ));
    } else if (profession == 'Personal Trainer') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaPersonalTrainer(userId: userId),
      ));
    } else if (profession == 'Nutricionista') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaNutricionista(userId: userId),
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
