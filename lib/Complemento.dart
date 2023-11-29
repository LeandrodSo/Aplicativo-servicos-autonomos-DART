import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:app_servicos/main.dart';

class ComplementoScreen extends StatefulWidget {
  @override
  _ComplementoScreenState createState() => _ComplementoScreenState();
}

class _ComplementoScreenState extends State<ComplementoScreen> {
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController profissaoController = TextEditingController();
  final TextEditingController atuacaoController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();

  Future<void> _admCadastro() async {
    final cidade = cidadeController.text;
    final profissao = profissaoController.text;
    final atuacao = atuacaoController.text;
    final numero = numeroController.text;

    bool validarFields() {
      //Função para validar se todos os campos obrigatórios estão preenchidos
      if (cidadeController.text.isEmpty ||
          profissaoController.text.isEmpty ||
          atuacaoController.text.isEmpty ||
          numeroController.text.isEmpty) {
        return false;
      }
      return true; // Todos os campos estão preenchidos
    }

    if (!validarFields()) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Por favor, preencha todos os campos.'),
            actions: <Widget>[
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
      return;
    }
    //Inserir os dadso no DB MYSQL----------------------------------------------
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    final newresult = await conexao.query(
        'INSERT INTO sua_tabela (cidade, profissao, atuacao, numero) VALUES (?, ?, ?, ?)',
        [cidade, profissao, atuacao, numero]);

    //-------------------------------------------------------------------------

    // Verifique se a inserção foi bem-sucedida --------------------------------
    if (newresult.affectedRows != 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Legal!'),
            content: Text('Seus dados foram salvos!'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        // Mostrar um diálogo de erro se os dados não puderem ser salvos

        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Ocorreu um erro completar cadastro'),
            actions: <Widget>[
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

    await conexao.close();
  }
  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Concluir'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, //alinhamento centro
          mainAxisAlignment: MainAxisAlignment.center, //alinhamento centro
          children: <Widget>[
            TextField(
              // Campos de texto para a entrada do usuário

              controller: cidadeController,
              decoration: InputDecoration(
                  labelText:
                      'Em que cidade você mora?'), //Rotulo do campo de texto
            ),
            TextField(
              controller: profissaoController,
              decoration: InputDecoration(
                  labelText:
                      'Qual é a sua profissão?'), //Rotulo do campo de texto
            ),
            TextField(
              controller: atuacaoController,
              decoration: InputDecoration(
                  labelText:
                      'Em qual(is) cidade(s) você atua?'), //Rotulo do campo de texto
            ),
            TextField(
              controller: numeroController,
              decoration: InputDecoration(
                  labelText:
                      'Qual seu número para contato?'), //Rotulo do campo de texto
            ),
            ElevatedButton(
              onPressed: _admCadastro,
              child: Text('Completar meu cadastro'),
            ),
          ],
        ),
      ),
    );
  }
}
