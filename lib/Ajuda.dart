import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

void main() {
  runApp(Ajuda(userId: 123)); // Substitua 123 pelo valor real do id do emissor
}

class Ajuda extends StatefulWidget {
  final int userId;

  Ajuda({Key? key, required this.userId}) : super(key: key);

  @override
  _AjudaState createState() => _AjudaState(userId);
}

class _AjudaState extends State<Ajuda> {
  final int userId;
  final int idReceptor = 1;
  final TextEditingController _mensagemController = TextEditingController();
  final List<String> mensagensEmissor = [];

  _AjudaState(this.userId);

  Future<void> enviarMensagem(String mensagem) async {
    final MySqlConnection connection =
        await MySqlConnection.connect(ConnectionSettings(
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    try {
      await connection.query(
        'INSERT INTO mensagem (status, idEmissor, idReceptor, mensagem) VALUES (?, ?, ?, ?)',
        ['naolida', userId, idReceptor, mensagem],
      );
      // Adicione lógica adicional se necessário após o envio da mensagem
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    } finally {
      await connection.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff808080),
          leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => Navigator.pop(context, false),
          ),
          centerTitle: true,
          title: Text("Ajuda"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Frase chamativa no topo
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.blue, // Cor de fundo da barra chamativa
                ),
                child: Center(
                  child: Text(
                    "Envie uma mensagem aos desenvolvedores, com qualquer dúvida, feedback ou sugestão sobre o aplicativo!",
                    style: TextStyle(
                      color: Colors.white, // Cor do texto na barra chamativa
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Widget para exibir mensagens do emissor à esquerda
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.grey[200],
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: mensagensEmissor
                        .map((mensagem) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(mensagem),
                            ))
                        .toList(),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Widget para entrada de nova mensagem
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: _mensagemController,
                      decoration:
                          InputDecoration(labelText: 'Digite sua mensagem'),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        String mensagem = _mensagemController.text;
                        if (mensagem.isNotEmpty) {
                          enviarMensagem(mensagem);
                          setState(() {
                            mensagensEmissor.add(mensagem);
                          });
                          _mensagemController.clear();
                          // Adicione lógica adicional se necessário após o envio da mensagem
                        } else {
                          // Adicione um tratamento para mensagem vazia se necessário
                        }
                      },
                      child: Text('Enviar Mensagem'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
