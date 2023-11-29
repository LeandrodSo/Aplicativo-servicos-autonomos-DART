import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';

class Rank extends StatelessWidget {
  final int idBusca;

  Rank({Key? key, required this.idBusca, required int idlogado})
      : super(key: key);

  Future<List<Map<String, dynamic>>> obterFeedbacks() async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    // Substitua 'feedbacks' pelo nome real da sua tabela no banco de dados
    var results = await conexao.query(
      'SELECT serviço, feedback, datacriação FROM feedbacks WHERE idservidor = ?',
      [idBusca],
    );

    // Converter os resultados para uma lista de mapas
    List<Map<String, dynamic>> feedbacks = [];
    for (var row in results) {
      feedbacks.add(Map<String, dynamic>.from(row.fields));
    }

    // Feche a conexão após a consulta
    await conexao.close();

    return feedbacks;
  }

//Função resgata a pontuação do banco usando o "idBusca"------------------------
  Future<int?> obterPontuacao() async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    // Substitua 'pontuacao_usuario' pelo nome real da sua tabela no banco de dados
    var results = await conexao.query(
      'SELECT pontuacao FROM pontuacao_usuario WHERE id_usuario = ?',
      [idBusca],
    );

    // Feche a conexão após a consulta
    await conexao.close();

    if (results.isNotEmpty) {
      return results.first['pontuacao'] as int?;
    } else {
      return null;
    }
  }
  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff808080),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text("Avaliação"),
      ),
      body: FutureBuilder(
        future: obterFeedbacks(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Erro: ${snapshot.error}');
          } else {
            // Aqui você pode acessar os dados recuperados
            List<Map<String, dynamic>> feedbacks = snapshot.data!;
            // Faça algo com os dados, como exibir em um ListView
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder(
                  future: obterPontuacao(),
                  builder: (context, AsyncSnapshot<int?> pontuacaoSnapshot) {
                    if (pontuacaoSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else {
                      int? pontuacao = pontuacaoSnapshot.data;
                      return pontuacao != null
                          ? ListTile(
                              title: Text(
                                'Pontuação: $pontuacao',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 248, 209, 15),
                                ),
                              ),
                            )
                          : Container(); // Ou outro widget, se preferir.
                    }
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: feedbacks.length,
                  itemBuilder: (context, index) {
                    var feedback = feedbacks[index];
                    // Converter a data para o formato desejado
                    var dataCriacao = DateFormat('dd/MM/yyyy')
                        .format(feedback['datacriação'] as DateTime);

                    return Card(
                      child: ListTile(
                        title: Text('Avaliação: ${feedback['feedback']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Serviço prestado: ${feedback['serviço']}'),
                            Text('Data avaliação: $dataCriacao'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
