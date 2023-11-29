import 'package:app_servicos/SubTopicos/ConsultorFinanceiro.dart';
import 'package:app_servicos/SubTopicos/ConsultorMarketing.dart';
import 'package:app_servicos/SubTopicos/ConsultorNeg%C3%B3cios.dart';
import 'package:app_servicos/SubTopicos/EscritorFreelancer.dart';
import 'package:flutter/material.dart';

class Consultoriafreelancer extends StatelessWidget {
  final int userId;

  Consultoriafreelancer({required this.userId});
  final List<String> professions = [
    'Consultor de Negócios',
    'Consultor de Marketing',
    'Consultor Financeiro',
    'Escritor Freelancer',
  ];

  void handleProfessionTap(BuildContext context, String profession) {
    // Navegue para telas diferentes com base na profissão selecionada
    if (profession == 'Consultor de Negócios') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaConsultorNegocios(userId: userId),
      ));
    } else if (profession == 'Consultor de Marketing') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaConsultorMarketing(userId: userId),
      ));
    } else if (profession == 'Consultor Financeiro') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaConsultorFinanceiro(userId: userId),
      ));
    } else if (profession == 'Escritor Freelancer') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEscritorFreelancer(userId: userId),
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
