import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class FeedbackScreen extends StatefulWidget {
  final String servico;
  final int trabalhadorId;
  final int clienteId;

  FeedbackScreen({
    required this.servico, //dados resititados para acesso
    required this.trabalhadorId,
    required this.clienteId,
  });

  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  int selectedScore = -1; // Valor inicial inválido

  // Função assíncrona para enviar feedback e pontuação para o banco de dados---
  Future<void> enviarFeedbackEPontuacaoParaBancoDeDados(
      String feedback, int pontuacao) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    try {
      await conexao.query(
        'INSERT INTO feedbacks (serviço, idservidor, idcliente, feedback) VALUES (?, ?, ?, ?)',
        [widget.servico, widget.trabalhadorId, widget.clienteId, feedback],
      );

      final result = await conexao.query(
        'SELECT * FROM pontuacao_usuario WHERE id_usuario = ?',
        [widget.trabalhadorId],
      );

      if (result.isNotEmpty) {
        // Se o registro já existe, atualize a pontuação existente somando a nova pontuação.
        final existingPontuacao = result.first['pontuacao'] as int;
        final novaPontuacao =
            existingPontuacao + pontuacao; //somar pontuação a ja existente

        await conexao.query(
          'UPDATE pontuacao_usuario SET pontuacao = ?, data_atualizacao = NOW() WHERE id_usuario = ?',
          [novaPontuacao, widget.trabalhadorId],
        );
      } else {
        // Se o registro não existe, insira um novo registro.
        await conexao.query(
          'INSERT INTO pontuacao_usuario (id_usuario, pontuacao, data_atualizacao) VALUES (?, ?, NOW())',
          [widget.trabalhadorId, pontuacao],
        );
      }

      print('Feedback e pontuação enviados com sucesso para o banco de dados');
    } catch (e) {
      print('Erro ao enviar feedback e pontuação para o banco de dados: $e');
    } finally {
      await conexao.close();
    }
  }

  //----------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text("Feedback"),
          actions: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, //centralizar informação
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: feedbackController,
                  decoration: InputDecoration(labelText: 'Feedback'),
                ),
              ),
              SizedBox(height: 16),
              Text('Escolha uma pontuação:'),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  //opçoes de 0 a 6 para pontuação
                  return ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedScore = index;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedScore == index ? Colors.amber : null,
                    ),
                    child: Text('$index'),
                  );
                }),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (selectedScore != -1) {
                    String feedback = feedbackController.text;
                    enviarFeedbackEPontuacaoParaBancoDeDados(
                        feedback, selectedScore);
                    feedbackController.clear();
                    setState(() {
                      selectedScore = -1; // Reinicia a seleção após o envio
                    });
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Escolha uma pontuação antes de enviar.')));
                  }
                },
                child: Text("Enviar Feedback"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
