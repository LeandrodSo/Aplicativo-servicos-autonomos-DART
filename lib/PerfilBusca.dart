import 'dart:async';
import 'package:app_servicos/Chat.dart';
import 'package:app_servicos/Portf%C3%B3lioBusca.dart';
import 'package:app_servicos/Rank.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilBusca extends StatefulWidget {
  final String cidade;
  final String profissao;
  final String atuacao;
  final String numero;
  final int id;
  final int userId;
  String nomeDoUsuario = '';
  String bioDoUsuario = ''; // Variável para a bio do usuário.

  PerfilBusca({
    required this.id,
    required this.cidade,
    required this.profissao,
    required this.atuacao,
    required this.numero,
    required this.userId,
  });

  @override
  _PerfilBuscaState createState() => _PerfilBuscaState();
}

class _PerfilBuscaState extends State<PerfilBusca> {
  late String imagePath = '';

  @override
  void initState() {
    super.initState();
    carregarImagemPerfil();

    consultarUsuario(widget.id);
    consultarBio(widget.id);
  }

  Future<void> carregarImagemPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('${widget.id}perfilbusca');

    if (savedImagePath != null) {
      setState(() {
        imagePath = savedImagePath;
        print('Caminho da imagem: $imagePath');
      });
    } else {
      // Adicione este trecho para carregar a imagem localmente
      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      final localImagePath =
          '${appDocumentsDirectory.path}/perfil_${widget.id}.png';

      if (File(localImagePath).existsSync()) {
        setState(() {
          imagePath = localImagePath;
        });
      }
    }
  }

  Future<String> consultarUsuario(int id) async {
    final MySqlConnection connection = await MySqlConnection.connect(
      ConnectionSettings(
        //host: '172.22.87.199',
        host: '192.168.99.105',
        port: 3306,
        user: 'dart_user',
        password: 'dart_pass',
        db: 'dart',
      ),
    );

    final results = await connection.query(
      'SELECT nome FROM usuarios WHERE id = ?',
      [id],
    );

    if (results.isNotEmpty) {
      final userData = results.first;
      final nome = userData['nome'];
      setState(() {
        widget.nomeDoUsuario = nome;
      });

      print('Nome do usuário ${widget.nomeDoUsuario}');
    } else {
      print('Usuário não encontrado.');
    }
    await connection.close();
    return widget.nomeDoUsuario;
  }

//Função verificar se ha bio na tebala do usuario------------------------------
  Future<void> consultarBio(int id) async {
    final MySqlConnection connection = await MySqlConnection.connect(
      ConnectionSettings(
        //host: '172.22.87.199',
        host: '192.168.99.105',
        port: 3306,
        user: 'dart_user',
        password: 'dart_pass',
        db: 'dart',
      ),
    );

    final results = await connection.query(
      'SELECT bio FROM sua_tabela WHERE id = ?',
      [id],
    );

    if (results.isNotEmpty) {
      final userData = results.first;
      final bio = userData['bio'];
      setState(() {
        widget.bioDoUsuario = bio;
      });

      print('Bio do usuário: ${widget.bioDoUsuario}');
    } else {
      setState(() {
        widget.bioDoUsuario = '';
      });
    }
  }
  //----------------------------------------------------------------------------

//Função enviar solicitação ao Db com status "pendente"-------------------------
  Future<void> enviarSolicitacaoDeAmizade(
      BuildContext context, int userId, int friendId) async {
    if (userId == friendId) {
      //Consulta se o id do usuario é igual ao do perfil buscado
      print('Você não pode enviar uma solicitação de amizade para si mesmo.');
      return;
    }

    final MySqlConnection connection = await MySqlConnection.connect(
      ConnectionSettings(
        //host: '172.22.87.199',
        host: '192.168.99.105',
        port: 3306,
        user: 'dart_user',
        password: 'dart_pass',
        db: 'dart',
      ),
    );

    try {
      // Verificar se a relação de amizade já existe
      final results = await connection.query(
        'SELECT * FROM amigos WHERE (idSolicitante = ? AND idRecebedor = ?) OR (idSolicitante = ? AND idRecebedor = ?)',
        [userId, friendId, friendId, userId],
      );

      if (results.isNotEmpty) {
        // Exibir um showDialog com a mensagem quando a solicitação já foi enviada
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Solicitação de Amizade Existente'),
              content: Text(
                  'A solicitação de amizade já foi enviada anteriormente.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      } else {
        // Inserir a solicitação de amizade na tabela amigos
        await connection.query(
          'INSERT INTO amigos (idSolicitante, idRecebedor, status) VALUES (?, ?, ?)',
          [userId, friendId, 'pendente'],
        );
        showDialog(
          //Mostrar notificação de sucesso
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Solicitação de Amizade Enviada'),
              content:
                  Text('Sua solicitação de amizade foi enviada com sucesso.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fechar'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Erro ao enviar solicitação de amizade: $e');
    }

    await connection.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Ink.image(
              image: const AssetImage(
                  'assets/images/add.png'), // Substitua pelo caminho da sua imagem
              width: 25, // Largura da imagem
              height: 25, // Altura da imagem
              fit: BoxFit.cover, // Pode ajustar o "fit" conforme necessário
            ),
            onPressed: () {
              enviarSolicitacaoDeAmizade(context, widget.userId, widget.id);
            },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Busca',
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 85, 85, 86),
                        borderRadius: BorderRadius.circular(20)),
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 120),
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 184, 183, 183),
                      radius: 70,
                      child: CircleAvatar(
                        backgroundImage: imagePath.isNotEmpty
                            ? FileImage(File(imagePath)) //resgatar local
                            : AssetImage(
                                    "assets/images/perfil.png") //exibir imagem local
                                as ImageProvider<Object>,
                        radius: 67,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                widget.nomeDoUsuario,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        'Informações',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/maletas.png", //exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    widget.profissao,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/lugar.png", //exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    widget.cidade,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/car.png", //exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    widget.atuacao,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/zap.png", //exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    widget.numero,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                // Exibir a "bio" do usuário abaixo do número.
                ListTile(
                  leading: Icon(Icons
                      .create_rounded), // Ícone de informação (você pode personalizá-lo)
                  title: Text(
                    widget.bioDoUsuario,
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 150,
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              //navegar para outra tela
                              builder: (context) =>
                                  PortfolioBusca(userId: widget.id),
                            ),
                          ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xff808080),
                              borderRadius: BorderRadius.circular(20)),
                          height: 40,
                          width: 90,
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              "Galeria",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Rank(
                                  //navegar para outra tela
                                  idBusca: widget.id,
                                  idlogado: widget.userId),
                            ),
                          ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xff808080),
                              borderRadius: BorderRadius.circular(20)),
                          height: 40,
                          width: 100,
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              "Avaliação",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                  //navegar para outra tela
                                  idreceptor: widget.id,
                                  idemissor: widget.userId),
                            ),
                          ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color(0xff808080),
                              borderRadius: BorderRadius.circular(20)),
                          height: 40,
                          width: 90,
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: Text(
                              "Chat",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
