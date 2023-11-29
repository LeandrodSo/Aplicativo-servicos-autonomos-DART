import 'dart:io';

import 'package:app_servicos/Chat.dart';
import 'package:app_servicos/CriarContrato.dart';
import 'package:app_servicos/Portf%C3%B3lioBusca.dart';
import 'package:app_servicos/Rank.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilFavorito extends StatefulWidget {
  final int amigoId;
  final int userid;

  PerfilFavorito({required this.amigoId, required this.userid});

  @override
  _PerfilFavoritoState createState() => _PerfilFavoritoState();
}

class _PerfilFavoritoState extends State<PerfilFavorito> {
  late String imagePath = '';

  String profissao = '';
  String cidade = '';
  String atuacao = '';
  String numero = '';
  String nome = '';
  String bio = ''; // Adicione a variável para a bio do usuário.

  @override
  void initState() {
    super.initState();
    carregarImagemPerfil();

    ResgatarInformacoes();
    ResgatarNome();
    fetchBio(); // Chame a função para buscar a bio.
  }

//Função que carrega a imagem salva localmente----------------------------------
  Future<void> carregarImagemPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString('${widget.amigoId}perfilbusca');

    if (savedImagePath != null) {
      setState(() {
        imagePath = savedImagePath;
        print('Caminho da imagem: $imagePath');
      });
    } else {
      // Adicione este trecho para carregar a imagem localmente
      final appDocumentsDirectory = await getApplicationDocumentsDirectory();
      final localImagePath =
          '${appDocumentsDirectory.path}/perfil_${widget.amigoId}.png'; //endereço no qual sera salvo

      if (File(localImagePath).existsSync()) {
        setState(() {
          imagePath = localImagePath; //atualizar o local
        });
      }
    }
  }
  //----------------------------------------------------------------------------

  //Resgatar os dados do DB usando o "amigoId"----------------------------------
  void ResgatarInformacoes() async {
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
        'SELECT profissao, cidade, atuacao, numero FROM sua_tabela WHERE id = ?',
        [widget.amigoId]);

    if (results.isNotEmpty) {
      final row = results.first; //Atribuir os dados resultantes nas variaveis
      setState(() {
        profissao = row['profissao'];
        cidade = row['cidade'];
        atuacao = row['atuacao'];
        numero = row['numero'];
      });
    }

    await connection.close();
  }
//-----------------------------------------------------------------------------

//Resgatar nome do usuario com o "amigoId"-------------------------------------
  void ResgatarNome() async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final resultnome = await connection
        .query('SELECT nome FROM usuarios WHERE id = ?', [widget.amigoId]);

    if (resultnome.isNotEmpty) {
      final row = resultnome.first;
      setState(() {
        nome = row['nome'];
      });
    }

    await connection.close();
  }
  //---------------------------------------------------------------------------

  //Função resgata a bio usando o "amigoId"------------------------------------
  void fetchBio() async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final resultBio = await connection
        .query('SELECT bio FROM sua_tabela WHERE id = ?', [widget.amigoId]);

    if (resultBio.isNotEmpty) {
      final row = resultBio.first;
      setState(() {
        bio = row['bio'];
      });
    }

    await connection.close();
  }
  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back), //Icone para retornar a pagina
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          '',
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
                        color: Color.fromARGB(255, 243, 195, 21),
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
                            ? FileImage(File(
                                imagePath)) //Exibir imagem no endereço salvo
                            : AssetImage("assets/images/perfil.png")
                                as ImageProvider<Object>,
                        radius: 67,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "$nome",
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
                    "assets/images/maletas.png", //Exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '$profissao',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/lugar.png", //Exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '$cidade',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/car.png", //Exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '$atuacao',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/zap.png", //Exibir imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '$numero ',
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
                    bio,
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
                              builder: (context) => PortfolioBusca(
                                //navegar para outra tela com parametros
                                userId: widget.amigoId,
                              ),
                            ),
                          ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 37, 184, 217),
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
                                  //navegar para outra tela com parametros
                                  idBusca: widget.amigoId,
                                  idlogado: widget.userid),
                            ),
                          ),
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 37, 184, 217),
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Chat(
                                //navegar para outra tela com parametros
                                idreceptor: widget.amigoId,
                                idemissor: widget.userid,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 37, 184, 217),
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
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CriarContrato(
                      //navegar para outra tela com parametros
                      amigoId: widget.amigoId,
                      userid: widget.userid,
                    ),
                  ),
                );
                // Lógica para criar contrato
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.blue,
              ),
              child: Text(
                "Criar Contrato",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
