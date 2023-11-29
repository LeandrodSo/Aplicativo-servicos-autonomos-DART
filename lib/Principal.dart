import 'dart:async';
import 'package:app_servicos/Ajuda.dart';
import 'package:app_servicos/pesquisa.dart';
import 'package:flutter/material.dart';
import 'package:app_servicos/Favoritos.dart';
import 'package:app_servicos/Contratos.dart';
import 'package:app_servicos/servicos.dart';
import 'package:app_servicos/Perfil.dart';
import 'package:app_servicos/modelos/CartoesTelaPrincipal.dart';
import 'package:mysql1/mysql1.dart';

class Principal extends StatefulWidget {
  final int userId;
  final String userEmail;
  final String userName;
  final String userCidade;
  final String userProfissao;
  final String userAtuacao;
  final String userNumero;

  Principal(
      {required this.userId,
      required this.userEmail,
      required this.userName,
      required this.userCidade,
      required this.userProfissao,
      required this.userAtuacao,
      required this.userNumero});

  @override
  _PrincipalState createState() => _PrincipalState(
        userId: userId,
        userEmail: userEmail,
        userName: userName,
        userCidade: userCidade,
        userProfissao: userProfissao,
        userAtuacao: userAtuacao,
        userNumero: userNumero,
      );
}

class _PrincipalState extends State<Principal> {
  final int userId;
  final String userEmail;
  final String userName;
  final String userCidade;
  final String userProfissao;
  final String userAtuacao;
  final String userNumero;

  _PrincipalState(
      {required this.userId,
      required this.userEmail,
      required this.userName,
      required this.userCidade,
      required this.userProfissao,
      required this.userAtuacao,
      required this.userNumero});

  @override
  void initState() {
    super.initState();
    consultaAmigosPendente(userId, context);
    consultaMsgPendente(userId, context);
    consultaContratospendentes(userId, context);
  }

//Função para consultar se ha solicitaçoes "pendentes" e notificar o usuario
  Future<void> consultaAmigosPendente(int userId, BuildContext context) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    Timer.periodic(Duration(seconds: 100), (timer) async {
      //timer que consulta BD a cada 150 segundos
      final results = await conexao.query(
          'SELECT * FROM amigos WHERE Status = ? AND idRecebedor = ?',
          ['pendente', userId]);

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Você tem solicitações de amizade pendentes!'),
            action: SnackBarAction(
              label: 'Fechar',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }
  //---------------------------------------------------------------------------

//Função para consultar se ha contratos "pendentes" e notificar-----------------
  Future<void> consultaContratospendentes(
      int userId, BuildContext context) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    Timer.periodic(Duration(seconds: 150), (timer) async {
      final results = await conexao.query(
          'SELECT * FROM contratos WHERE status = ? AND cliente_id = ?',
          ['pendente', userId]);

      if (results.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Voce possui propostas de contrato!'),
            action: SnackBarAction(
              label: 'Fechar',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }
  //----------------------------------------------------------------------------

  //Função consulta se ha mensagens "naolida" e notifica o usuario-------------
  Future<void> consultaMsgPendente(int userId, BuildContext context) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    Timer.periodic(Duration(seconds: 50), (timer) async {
      final resultsmsg = await conexao.query(
          'SELECT * FROM mensagem WHERE status = ? AND idReceptor = ?',
          ['naolida', userId]);

      if (resultsmsg.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Você possui novas mensagens!'),
            action: SnackBarAction(
              label: 'Fechar',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }
  //---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(69, 64, 75, 0.824),
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'Bem vindo',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Ao seu App de Serviços',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 123, 154, 247),
        elevation: 0,
        toolbarHeight: 80,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32))),
// Design botao pesquise e caminho --------------------------------------------

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Pesquisa(userId: userId)), //navegação para outra tela
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
        //----------------------------------------------------------------------------
      ),
      drawer: Drawer(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text('$userName'),
                accountEmail: Text('$userEmail'),
              ),

              // APP BAR PERFIL, CLICK DIRECIONAMENTO => PERFIL------------------
              ListTile(
                leading: Image.asset(
                  "assets/images/perfil.png",
                  height: 35,
                  width: 35,
                ),
                title: Text(
                  'Perfil',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Perfil(
                          //navegação para outra tela
                          userId: userId,
                          userEmail: userEmail,
                          userName: userName,
                          userCidade: userCidade,
                          userProfissao: userProfissao,
                          userAtuacao: userAtuacao,
                          userNumero: userNumero),
                    ),
                  );
                },
              ),
              //------------------------------------------------------------------

              // APP BAR CONTRATOS, CLICK DIRECIONAMENTO => CONTRATOS-------------
              ListTile(
                leading: Image.asset(
                  "assets/images/contrato.png",
                  height: 35,
                  width: 35,
                ),
                title: Text(
                  'Contratos',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Contratos(userId: userId), //navegação para outra tela
                    ),
                  );
                },
              ),
              //----------------------------------------------------------------

              // APP BAR SERVIÇO, CLICK DIRECIONAMENTO => SERVIÇO----------------
              ListTile(
                leading: Image.asset(
                  "assets/images/serviços.png",
                  height: 35,
                  width: 35,
                ),
                title: Text(
                  'Serviços',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Servicos(
                            userId: userId)), //navegação para outra tela
                  );
                },
              ),
              //----------------------------------------------------------------

              // APP BAR CONTATOS, CLICK DIRECIONAMENTO => CONTATOS-------------
              ListTile(
                leading: Image.asset(
                  "assets/images/contato.png",
                  height: 35,
                  width: 35,
                ),
                title: Text(
                  'Amigos',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Amigos(userId: userId), //navegação para outra tela
                    ),
                  );
                },
              ),

              //----------------------------------------------------------------

              // APP BAR AJUDA, CLICK DIRECIONAMENTO => AJUDA------------------
              ListTile(
                leading: Image.asset(
                  "assets/images/ajuda.png",
                  height: 35,
                  width: 35,
                ),
                title: Text(
                  'Ajuda',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Ajuda(
                        userId: userId,
                      ), //navegação para outra tela
                    ),
                  );
                },
              ),
              //----------------------------------------------------------------
            ],
          )),
      body: Cartoes(userId: userId),
    );
  }
}

//-----------------------------------------------------------------------------