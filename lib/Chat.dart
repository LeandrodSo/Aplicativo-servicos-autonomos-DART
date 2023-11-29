import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:async';

// Classe para representar uma mensagem----------------------------------------
class Mensagem {
  final int id;
  final String status;
  final int idemissor;
  final int idreceptor;
  final String mensagem;
  final DateTime dataEnvio;
  final String statusMensagem;

  Mensagem({
    required this.id,
    required this.status,
    required this.idemissor,
    required this.idreceptor,
    required this.mensagem,
    required this.dataEnvio,
    required this.statusMensagem,
  });
}

//------------------------------------------------------------------------------

class Chat extends StatefulWidget {
  final int idemissor;
  final int idreceptor;

  Chat({
    Key? key,
    required this.idemissor,
    required this.idreceptor,
  }) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController mensagemController = TextEditingController();
  String? nomeEmissor;
  String? nomeReceptor;

  //Função que insere as mensagens da tabela SQL com status "naolida"-----------
  Future<void> enviarMensagem(String mensagem) async {
    final MySqlConnection connection =
        await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    try {
      final results = await connection.query(
        'INSERT INTO mensagem (status, idEmissor, idReceptor, mensagem) VALUES (?, ?, ?, ?)',
        ['naolida', widget.idemissor, widget.idreceptor, mensagem],
      );
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    } finally {
      await connection.close();
    }
  }
  //-----------------------------------------------------------------------------

  StreamController<List<Mensagem>> _mensagensStreamController =
      StreamController<List<Mensagem>>();

  Stream<List<Mensagem>> get mensagensStream =>
      _mensagensStreamController.stream;

  Timer?
      _mensagensTimer; //Declara uma variável de temporizador que pode ser nula e será usada para controlar a tarefa periódica.

  void ConsultarMensagensPeriodicamente() {
    _mensagensTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //Cria um temporizador periódico que dispara a cada 1 segundo.
      final mensagens = await carregarMensagens();
      _mensagensStreamController.sink.add(mensagens);
    });
  }

  void PararCarregarMensagensPeriodicamente() {
    _mensagensTimer?.cancel();
    _mensagensStreamController.close();
  }

  //Função que seleciona as mensagem do db -------------------------------------
  Future<List<Mensagem>> carregarMensagens() async {
    final MySqlConnection connection =
        await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    try {
      final results = await connection.query(
        'SELECT id, status, idEmissor, idReceptor, mensagem, data_envio, status AS statusMensagem ' +
            'FROM mensagem ' +
            'WHERE (idEmissor = ? AND idReceptor = ?) OR (idEmissor = ? AND idReceptor = ?) ' +
            'ORDER BY id ASC',
        [
          widget.idemissor,
          widget.idreceptor,
          widget.idreceptor,
          widget.idemissor
        ],
      );

      final mensagens = results
          .map((row) => Mensagem(
                id: row['id'],
                status: row['status'],
                idemissor: row['idEmissor'],
                idreceptor: row['idReceptor'],
                mensagem: row['mensagem'].toString(),
                dataEnvio: row['data_envio'],
                statusMensagem: row['statusMensagem'],
              ))
          .toList();

      return mensagens;
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      return [];
    } finally {
      await connection.close();
    }
  }
  //----------------------------------------------------------------------------

  //Atualiza o status da mensagem para "lida"-----------------------------------
  Future<void> marcarMensagensComoLidas() async {
    final MySqlConnection connection =
        await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    try {
      await connection.query(
        'UPDATE mensagem SET status = ? WHERE idReceptor = ? AND status = ?',
        ['lida', widget.idemissor, 'naolida'],
      );
    } catch (e) {
      print('Erro ao marcar mensagens como lidas: $e');
    } finally {
      await connection.close();
    }
  }
  //---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    marcarMensagensComoLidas();
    ConsultarMensagensPeriodicamente();
  }

  @override
  void dispose() {
    PararCarregarMensagensPeriodicamente();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff808080),
        leading: IconButton(
          icon: Icon(Icons.exit_to_app),
          onPressed: () => Navigator.pop(context, false),
        ),
        centerTitle: true,
        title: Text("Chat"),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: StreamBuilder<List<Mensagem>>(
              stream: mensagensStream,
              builder: (context, snapshot) {
                //snapshot refere-se ao estado atual de um Stream ou Future
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Erro ao carregar mensagens: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text('Nenhuma mensagem disponível.');
                } else {
                  final mensagens = snapshot.data;
                  return ListView.builder(
                    itemCount: mensagens!.length,
                    itemBuilder: (context, index) {
                      final mensagem = mensagens[index];
                      final isEmissor = mensagem.idemissor == widget.idemissor;
                      final isReceptor =
                          mensagem.idreceptor == widget.idreceptor;
                      final alignment = isEmissor
                          ? Alignment
                              .centerLeft // Ajuste o alinhamento para o canto direito para o idemissor
                          : (isReceptor
                              ? Alignment
                                  .centerRight // Ajuste o alinhamento para o canto esquerdo para o idreceptor
                              : Alignment.centerRight);
                      final backgroundColor = isEmissor
                          ? Color.fromARGB(
                              255, 124, 115, 250) // Cor de fundo do emissor
                          : (isReceptor
                              ? Color.fromARGB(
                                  255, 72, 152, 218) // Cor de fundo do receptor
                              : Color.fromARGB(209, 240, 185, 18));
                      final textColor = isEmissor || isReceptor
                          ? Colors.white
                          : Color.fromARGB(255, 255, 255, 255);
                      final messageStyle = TextStyle(
                        color: textColor,
                        fontSize: 16,
                      );
                      final statusColor = mensagem.statusMensagem == 'lida'
                          ? Color.fromARGB(255, 255, 255, 255)
                          : Color.fromARGB(255, 255, 255, 255);
                      final formattedDate = DateFormat(
                              'dd/MM/yyyy HH:mm:ss') //atualizar formato da data
                          .format(mensagem.dataEnvio.toLocal());
                      return Align(
                        alignment: alignment,
                        child: Container(
                          decoration: BoxDecoration(
                            color: backgroundColor,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mensagem.mensagem, style: messageStyle),
                              Text(
                                '$formattedDate\n/ ${mensagem.statusMensagem}',
                                style: TextStyle(color: statusColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: mensagemController,
                    decoration: InputDecoration(
                      hintText: "Digite sua mensagem...",
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String mensagem = mensagemController.text;
                    if (mensagem.isNotEmpty) {
                      enviarMensagem(mensagem);
                      mensagemController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
