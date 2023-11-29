import 'package:app_servicos/Principal.dart';
import 'package:app_servicos/SubTopicos/DesignerUI.dart';
import 'package:app_servicos/SubTopicos/DesignerUX.dart';
import 'package:app_servicos/SubTopicos/DesignerWeb.dart';
import 'package:app_servicos/SubTopicos/DevMobile.dart';
import 'package:app_servicos/SubTopicos/EspecialistaRede.dart';
import 'package:app_servicos/SubTopicos/Seguran%C3%A7aCibern%C3%A9tica.dart';
import 'package:app_servicos/SubTopicos/T%C3%A9cnicoSuporteTI.dart';
import 'package:flutter/material.dart';

class AreaTI extends StatelessWidget {
  final int userId;

  AreaTI({required this.userId});
  final List<String> professions = [
    'Desenvolvedor de Aplicativos Móveis',
    'Especialista em Redes',
    'Técnico de Suporte de TI',
    'Especialista em Segurança Cibernética',
    'Designer de Interfaces de Usuário (UI)',
    'Designer de Experiência do Usuário (UX)',
    'Designer de Websites',
  ];

  void handleProfessionTap(BuildContext context, String profession) {
    // Navegue para telas diferentes com base na profissão selecionada
    if (profession == 'Desenvolvedor de Aplicativos Móveis') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaDevMobile(userId: userId),
      ));
    } else if (profession == 'Especialista em Redes') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaEspecialistaRedes(userId: userId),
      ));
    } else if (profession == 'Técnico de Suporte de TI') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaSuporteTI(userId: userId),
      ));
    } else if (profession == 'Especialista em Segurança Cibernética') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaSegurancaCibernetica(userId: userId),
      ));
    } else if (profession == 'Designer de Interfaces de Usuário (UI)') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaDesignerUI(userId: userId),
      ));
    } else if (profession == 'Designer de Experiência do Usuário (UX)') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaDesignerUX(userId: userId),
      ));
    } else if (profession == 'Designer de Websites') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => TelaDesignerWEB(userId: userId),
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
