import 'package:app_servicos/SubTopicos/CuidadorIdosos.dart';
import 'package:app_servicos/SubTopicos/Enfermeiro.dart';
import 'package:app_servicos/SubTopicos/FisioterapeutaDomicilio.dart';
import 'package:app_servicos/SubTopicos/MassagistaTerapeutico.dart';
import 'package:app_servicos/SubTopicos/Massoterapeuta.dart';
import 'package:flutter/material.dart';

class Saude extends StatelessWidget {
  final int userId;

  Saude({required this.userId});
  final List<String> professions = [
    'Cuidador de Idosos',
    'Cuidador de Pacientes com Necessidades Especiais',
    'Enfermeiro Domiciliar',
    'Fisioterapeuta em Domicílio',
    'Massagista Terapêutico',
    'Massoterapeuta Esportivo',
    'Massoterapeuta Relaxante',
  ];

  void handleProfessionTap(BuildContext context, String profession) {
    // Navegue para telas diferentes com base na profissão selecionada
    if (profession == 'Cuidador de Idosos') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaCuidadorIdosos(userId: userId),
      ));
    } else if (profession == 'Enfermeiro Domiciliar') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEnfermeiro(userId: userId),
      ));
    } else if (profession == 'Fisioterapeuta em Domicílio') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaFisioterapeutaDomicilio(userId: userId),
      ));
    } else if (profession == 'Massagista Terapêutico') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaMassagistaTerapeutico(userId: userId),
      ));
    } else if (profession == 'Massoterapeuta') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => Massoterapeuta(userId: userId),
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
