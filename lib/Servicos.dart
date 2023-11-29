import 'package:app_servicos/ContratosPendentes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Adicionado para formatação de datas
import 'package:mysql1/mysql1.dart';

class Servicos extends StatefulWidget {
  final int userId;

  Servicos({Key? key, required this.userId}) : super(key: key);

  @override
  _ServicosState createState() => _ServicosState();
}

class _ServicosState extends State<Servicos> {
  List<Map<String, dynamic>> servicosData = []; //lista de contratos vazio

  @override
  void initState() {
    super.initState();
    carregaContratos();
  }

//Função que seleciona todos os contratos do DB---------------------------------
  Future<void> carregaContratos() async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final results = await connection.query('SELECT * FROM contratos');

    for (var row in results) {
      servicosData.add(row.fields); //adicionar a lista
    }

    await connection.close();

    setState(() {});
  }
  //----------------------------------------------------------------------------

  //Função atualizar o status para "cancelado"----------------------------------
  Future<void> AtualizarContratoCancelar(int contratoId) async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final result = await connection.query(
        'UPDATE contratos SET status = ? WHERE id = ?',
        ['cancelado', contratoId]);

    await connection.close();
  }
  //----------------------------------------------------------------------------

  //Função para resgatar nome usando o "userId"---------------------------------
  Future<String> ObterNome(int userId) async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final results = await connection
        .query('SELECT nome FROM usuarios WHERE id = ?', [userId]);

    await connection.close();

    if (results.isNotEmpty) {
      return results.first['nome'];
    }

    return 'Nome não encontrado'; // Ou qualquer outro valor padrão caso o nome não seja encontrado.
  }
  //----------------------------------------------------------------------------

  //Função Obter nome do cliente usando o "clienteId"----------------------------
  Future<String> ObterNomeCliente(int clienteId) async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final results = await connection
        .query('SELECT nome FROM usuarios WHERE id = ?', [clienteId]);

    await connection.close();

    if (results.isNotEmpty) {
      return results.first['nome'];
    }

    return 'Nome não encontrado'; // Ou qualquer outro valor padrão caso o nome não seja encontrado.
  }
  //----------------------------------------------------------------------------

  String formatDate(DateTime dateTime) {
    //Formatar data personalizada
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff808080),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () =>
              Navigator.pop(context, false), //voltar para tela anterior
        ),
        centerTitle: true,
        title: Text("Lista de Serviços"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ContratosPendentes(
                      userId: widget.userId), //Navegação para outra tela
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: servicosData.length,
        itemBuilder: (context, index) {
          final contrato = servicosData[index];
          Color backgroundColor;

          if (contrato['status'] == 'ativo') {
            backgroundColor = const Color.fromARGB(255, 0, 140, 255);
          } else if (contrato['status'] == 'concluido') {
            backgroundColor = Colors.green;
          } else if (contrato['status'] == 'cancelado') {
            backgroundColor = Colors.red;
          } else {
            backgroundColor = Colors.white;
          }

          if (widget.userId == contrato['trabalhador_id']) {
            return Container(
              color: backgroundColor,
              margin: EdgeInsets.only(bottom: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InfoRow("Serviço", contrato['servico']),
                      InfoRow("Descrição", contrato['descricao']),
                      FutureBuilder<String>(
                        future: ObterNomeCliente(contrato['cliente_id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return InfoRow("Cliente", snapshot.data);
                            } else {
                              return InfoRow("Cliente", "Nome não encontrado");
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      FutureBuilder<String>(
                        future: ObterNome(contrato['trabalhador_id']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return InfoRow("Trabalhador", snapshot.data);
                            } else {
                              return InfoRow(
                                  "Trabalhador", "Nome não encontrado");
                            }
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      InfoRow("Data do Contrato",
                          formatDate(contrato['data_contrato'])),
                      InfoRow("Valor", contrato['valor']),
                      InfoRow("Status", contrato['status']),
                      if (contrato['status'] == 'ativo')
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                AtualizarContratoCancelar(contrato['id']);
                                setState(() {
                                  contrato['status'] = 'cancelado';
                                });
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                              child: Text("Cancelar"),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final dynamic value;

  InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(
              "$label: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value.toString(),
            ),
          ],
        ));
  }
}
