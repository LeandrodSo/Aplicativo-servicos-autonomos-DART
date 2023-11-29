import 'package:app_servicos/ContratosPendentes.dart';
import 'package:app_servicos/Feedback.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Contratos extends StatefulWidget {
  final int userId;

  Contratos({Key? key, required this.userId}) : super(key: key);

  @override
  _ContratosState createState() => _ContratosState();
}

class _ContratosState extends State<Contratos> {
  List<Map<String, dynamic>> contratosData = [];

  @override
  void initState() {
    super.initState();
    CarregarContratos();
  }
  // Função assíncrona para carregar os dados dos contratos do banco de dados---

  Future<void> CarregarContratos() async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final results = await connection.query(
        'SELECT * FROM contratos'); // Consultando o banco de dados para selecionar todas as linhas da tabela 'contratos'

    for (var row in results) {
      // Adicionando cada linha à lista contratosData

      contratosData.add(row.fields);
    }

    await connection.close();

    setState(() {}); // Acionando uma reconstrução do widget com os novos dados
  }

  //----------------------------------------------------------------------------

  //Função que atualiza o status do contrato para "concluido"-------------------
  Future<void> ConcluirContrato(int contratoId) async {
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
        ['concluido', contratoId]);

    await connection.close();
  }
  //----------------------------------------------------------------------------

  //Atualizar status do contrato para "recusado"--------------------------------
  Future<void> AtualizarContratoRecusado(int contratoId) async {
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
  //-----------------------------------------------------------------------------

  //função que leva a pagina feedback com dados como parametro-------------------
  void _NavegarparaFeedback(Map<String, dynamic> contratoData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FeedbackScreen(
          servico: contratoData['servico'],
          trabalhadorId: contratoData['trabalhador_id'],
          clienteId: contratoData['cliente_id'],
        ),
      ),
    );
  }
  //---------------------------------------------------------------------------

  //Função para resgatar "nome" usando o "userid"------------------------------
  Future<String> Obternome(int userId) async {
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

    return 'Nome não encontrado';
  }
  //----------------------------------------------------------------------------

  //Função resgatar nome usando o "clienteId"-----------------------------------
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
      return results.first['nome']; //retornar primeiro resultado obtido
    }

    return 'Nome não encontrado';
  }
  //----------------------------------------------------------------------------

  String formatDate(DateTime date) {
    // Função para formatar um objeto DateTime em uma string personalizada

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year.toString()}";
  }

  // Sobrescrevendo o método build para definir a interface do usuário do widget

  @override
  Widget build(BuildContext context) {
    // Construindo o widget Scaffold
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff808080),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () => Navigator.pop(context, false),
        ),
        centerTitle: true,
        title: Text("Contratos"),
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) =>
                      ContratosPendentes(userId: widget.userId),
                ),
              );
            },
          ),
        ],
      ),

      // Corpo do widget com um ListView.builder

      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: contratosData.length,
        itemBuilder: (context, index) {
          final contrato = contratosData[index];
          Color backgroundColor;

          if (contrato['status'] == 'pendente') {
            return Container();
          }

          if (contrato['status'] == 'ativo') {
            backgroundColor = const Color.fromARGB(255, 0, 140, 255);
          } else if (contrato['status'] == 'concluido') {
            backgroundColor = Colors.green;
          } else if (contrato['status'] == 'cancelado') {
            backgroundColor = Colors.red;
          } else {
            backgroundColor = Colors.white;
          }

          if (widget.userId == contrato['cliente_id']) {
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
                        future: Obternome(contrato['trabalhador_id']),
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
                                ConcluirContrato(contrato['id']);
                                setState(() {
                                  contrato['status'] = 'concluido';
                                });
                                _NavegarparaFeedback(contrato);
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.green),
                              ),
                              child: Text("Concluir"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                AtualizarContratoRecusado(contrato['id']);
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
  // StatelessWidget para exibir uma linha de informações

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
