// Importando pacotes necessários ---------------------------------------------
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'Cadastro.dart';
import 'package:app_servicos/Principal.dart';
//  ----------------------------------------------------------------------------

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

//O estado da tela de login é gerenciado por uma classe de estado chamada _LoginScreenState.
// A função createState() é responsável por criar uma instância dessa classe de estado quando o widget é criado
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

//-----------------------------------------------------------------------------------------------------

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController =
      TextEditingController(); //Cria um controlador de texto chamado emailController. Controladores de texto são usados para interagir com widgets de entrada de texto no Flutter
  final TextEditingController passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    final email =
        emailController.text; //Obtém o texto atual dos controladores de texto
    final password = passwordController.text;

    //CONEXAO COM BD -----------------------------------------------------------
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    final result = await conexao.query(
      'SELECT id, email, nome FROM usuarios WHERE email = ? AND password = ?', // A consulta SQL seleciona as colunas id, email e nome da tabela usuarios
      [email, password],
    );

    //---------------------------------------------------------------------------

    //Atribui os valores obtidos na consulta a variaveis distintas--------------
    if (result.isNotEmpty) {
      final userData = result.first;
      final userId = userData['id'];
      final userEmail = userData['email'];
      final userName = userData['nome'];

      final newresult = await conexao.query(
        'SELECT cidade, profissao, atuacao, numero FROM sua_tabela WHERE id = ?',
        [userId],
      );

      final userProf = newresult.first;
      final userCidade = userProf['cidade'];
      final userProfissao = userProf['profissao'];
      final userAtuacao = userProf['atuacao'];
      final userNumero = userProf['numero'];

      // Credenciais válidas, navegue para a próxima tela-----------------------
      Navigator.push(
        context,
        MaterialPageRoute(
            //define a animação e o layout associados à navegação entre telas.
            builder: (context) => Principal(
                  userId: result.first['id'],
                  userEmail: userEmail,
                  userName: userName,
                  userCidade: userCidade,
                  userProfissao: userProfissao,
                  userAtuacao: userAtuacao,
                  userNumero: userNumero,
                )),
      );
    } else {
      //-----------------------------------------------------------------------
      // Credenciais inválidas, exiba uma mensagem de erro---------------------
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
    //------------------------------------------------------------------------
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
          crossAxisAlignment:
              CrossAxisAlignment.center, // Alinhamento horizontal no centro.
          mainAxisAlignment:
              MainAxisAlignment.center, // Alinhamento horizontal no centro.
          children: <Widget>[
            TextField(
              controller:
                  emailController, // Controlador de texto para gerenciar o estado do campo.
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller:
                  passwordController, // Controlador de texto para gerenciar o estado do campo.
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),

            ElevatedButton(
              onPressed: _handleLogin,
              child: Text('Entrar'),
            ),

            // Adicionando um pequeno espaço entre os botões
            SizedBox(height: 10),

            // Botão para tela cadastro ------------------------------------------
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CadastroScreen()),
                );
              },
              child: Text('Cadastrar novo usuario'),
            )

            //-------------------------------------------------------
          ],
        ),
      ),
    );
  }
}
