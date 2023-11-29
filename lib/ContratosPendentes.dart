import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';

class ContratosPendentes extends StatefulWidget {
  final int userId;

  ContratosPendentes({Key? key, required this.userId})
      : super(key: key); //Atributos necessarios para acesso

  @override
  _ContratosPendentesState createState() => _ContratosPendentesState();
}

class _ContratosPendentesState extends State<ContratosPendentes> {
  late MySqlConnection conexao;
  List<Map<String, dynamic>> contratos = [];
  final DateFormat dateFormat =
      DateFormat('dd/MM/yyyy'); // Define o formato da data

  @override
  void initState() {
    super.initState();
    conectarAoBancoDeDados();
  }

  //Função para conectar ao Db-------------------------------------------------
  Future<void> conectarAoBancoDeDados() async {
    conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    carregarContratosPendentes();
  }
  //----------------------------------------------------------------------------

  //Função selecionar contratos com status "pendente"---------------------------
  Future<void> carregarContratosPendentes() async {
    final results = await conexao.query(
        'SELECT * FROM contratos WHERE status = ? AND cliente_id = ?',
        ['pendente', widget.userId]);

    print('Número de contratos pendentes: ${results.length}');
    print('Contratos carregados: $results');
    setState(() {
      contratos =
          results.map((r) => r.fields).toList(); //inserir contratos na lista
    });
  }

  //---------------------------------------------------------------------------

  //Função que Aceito um contrato mudando o status para "ativo"----------------
  Future<void> aceitarContrato(int contratoId) async {
    final result = await conexao.query(
      'UPDATE contratos SET status = ? WHERE id = ?',
      ['ativo', contratoId],
    );
    if (result.affectedRows! > 0) {
      carregarContratosPendentes();
      showDialog(
        //Aviso de o contrato foi aceito
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contrato aceito!'),
            content: Text('Confira seus contratos ativos.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
  //----------------------------------------------------------------------------

  //Função que recusa o contrato, deletando da tabela MYSQL--------------------
  Future<void> recusarContrato(int contratoId) async {
    final result = await conexao.query(
      'DELETE FROM contratos WHERE id = ?',
      [contratoId],
    );
    if (result.affectedRows! > 0) {
      carregarContratosPendentes();
      showDialog(
        //Notificação de contrato recusado
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Contrato recusado!'),
            content: Text('O contrato foi recusado.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  //----------------------------------------------------------------------------

  //Função que obtem nome do trabalahdor usando o "trabalhadorId"---------------
  Future<String> obterNomeTrabalhador(int trabalhadorId) async {
    final result = await conexao.query(
      'SELECT nome FROM usuarios WHERE id = ?',
      [trabalhadorId],
    );

    if (result.isNotEmpty) {
      return result.first['nome'];
    } else {
      return 'Nome não encontrado';
    }
  }
  //----------------------------------------------------------------------------

  // Sobrescrevendo o método build para definir a interface do usuário do widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contratos Pendentes"),
      ),
      body: ListView.builder(
        itemCount: contratos.length,
        itemBuilder: (context, index) {
          final contrato = contratos[index];
          return FutureBuilder<String>(
            future: obterNomeTrabalhador(contrato['trabalhador_id']),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else {
                final nomeTrabalhador = snapshot.data ?? 'Nome não encontrado';
                return Container(
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          "Trabalhador: $nomeTrabalhador"), //exibir dados no container
                      Text("Serviço: ${contrato['servico']}"),
                      Text(
                        "Data do Contrato: ${dateFormat.format(contrato['data_contrato'])}",
                      ),
                      Text("Descrição: ${contrato['descricao']}"),
                      Text("Valor: ${contrato['valor']}"),
                      Text("Status: ${contrato['status']}"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              aceitarContrato(contrato['id']);
                            },
                            child: Text("Aceitar"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              recusarContrato(contrato['id']);
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red[200]),
                            ),
                            child: Text("Recusar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    conexao.close();
    super.dispose();
  }
}
