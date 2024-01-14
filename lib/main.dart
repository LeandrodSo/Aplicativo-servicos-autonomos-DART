// Importando pacotes necessários ---------------------------------------------
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'Cadastro.dart';
import 'package:app_servicos/Principal.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
// ----------------------------------------------------------------------------

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false, //remove o banner de depuração que normalmente é exibido no canto superior direito do aplicativo durante o desenvolvimento
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Função para verificar se a senha fornecida corresponde ao hash armazenado
  bool verifyPassword(String input, String storedHash) {
    var bytes = utf8.encode(input);
    var hash = sha256.convert(bytes);
    return hash.toString() == storedHash;
  }

  Future<void> _handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    // CONEXAO COM BD -----------------------------------------------------------
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      // host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    // Realiza a consulta para obter os dados do usuário, incluindo o hash da senha
    final result = await conexao.query(
      'SELECT id, email, nome, password FROM usuarios WHERE email = ?',
      [email],
    );

    // Atribui os valores obtidos na consulta a variáveis distintas
    if (result.isNotEmpty) {
      final userData = result.first;
      final userId = userData['id'];
      final userEmail = userData['email'];
      final userName = userData['nome'];
      final storedHash = userData['password'];

      // Verifica se a senha fornecida corresponde ao hash armazenado no banco de dados
      if (verifyPassword(password, storedHash)) {
        // Credenciais válidas, navegue para a próxima tela
        final newresult = await conexao.query(
          'SELECT cidade, profissao, atuacao, numero FROM sua_tabela WHERE id = ?',
          [userId],
        );

        final userProf = newresult.first;
        final userCidade = userProf['cidade'];
        final userProfissao = userProf['profissao'];
        final userAtuacao = userProf['atuacao'];
        final userNumero = userProf['numero'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Principal(
              userId: userId,
              userEmail: userEmail,
              userName: userName,
              userCidade: userCidade,
              userProfissao: userProfissao,
              userAtuacao: userAtuacao,
              userNumero: userNumero,
            ),
          ),
        );
      } else {
        // Credenciais inválidas, exiba uma mensagem de erro
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erro de autenticação'),
              content:
                  Text('Credenciais inválidas. Por favor, tente novamente.'),
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
    } else {
      // Credenciais inválidas, exiba uma mensagem de erro
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erro de autenticação'),
            content: Text('Credenciais inválidas. Por favor, tente novamente.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Entrar'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroScreen()),
                );
              },
              child: Text('Cadastrar novo usuário'),
            ),
          ],
        ),
      ),
    );
  }
}
