import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:app_servicos/Complemento.dart';

class CadastroScreen extends StatefulWidget {
  @override
  _CadastroScreenState createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  Future<void> _Cadastro() async {
    final nome = nomeController.text;
    final password = passwordController.text;
    final email = emailController.text;

    bool validarFields() {
      if (nomeController.text.isEmpty ||
          passwordController.text.isEmpty ||
          emailController.text.isEmpty) {
        return false; // Campos em branco
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

    // Conecta ao banco de dados MySQL------------------------------------------

    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    //--------------------------------------------------------------------------

    final result = await conexao.query(
      'INSERT INTO usuarios (nome, password, email) VALUES (?, ?, ?)',
      [nome, password, email],
    );

    // Verifique se a inserção foi bem-sucedida --------------------------------
    if (result.affectedRows != 0) {
      showDialog(
        //notificação de sucesso
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sucesso'),
            content: Text(
                'Novo usuário cadastrado com sucesso! Agora vamos completar seu cadastro'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ComplementoScreen()),
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
        //notificação de erro
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro'),
            content: Text('Ocorreu um erro ao cadastrar o usuário.'),
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
        title: Text('Cadastro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, //alinhamento centro
          mainAxisAlignment: MainAxisAlignment.center, //alinhamento centro
          children: <Widget>[
            TextField(
              controller: nomeController,
              decoration: InputDecoration(
                  labelText: 'Nome de Usuário'), //rotulo  no campo
            ),
            TextField(
              controller: passwordController,
              decoration:
                  InputDecoration(labelText: 'Senha'), //rotulo  no campo
              obscureText: true,
            ),
            TextField(
              controller: emailController,
              decoration:
                  InputDecoration(labelText: 'email'), //rotulo  no campo
            ),
            ElevatedButton(
              onPressed: _Cadastro, //chame a função _Cadastro ao pressionar"
              child: Text('Cadastrar Novo Usuário'),
            ),
          ],
        ),
      ),
    );
  }
}
