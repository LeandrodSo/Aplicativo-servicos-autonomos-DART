import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:app_servicos/Rank.dart';
import 'package:flutter/material.dart';
import 'package:app_servicos/Portfólio.dart';
import 'package:mysql1/mysql1.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Perfil extends StatefulWidget {
  // Parâmetros do construtor
  final int userId;
  final String userName;
  final String userEmail;
  final String userCidade;
  final String userProfissao;
  final String userAtuacao;
  final String userNumero;
  final TextEditingController bioController = TextEditingController();
  String? bioFromDatabase;

  Perfil(
      {Key? key,
      required this.userId,
      required this.userEmail,
      required this.userName,
      required this.userCidade,
      required this.userProfissao,
      required this.userAtuacao,
      required this.userNumero})
      : super(key: key) {
    bioFromDatabase = null;
  }

  @override
  _PerfilState createState() => _PerfilState();
}

class ProfileImageProvider extends ChangeNotifier {
  late String _imagePath;

  String get imagePath => _imagePath;

  ProfileImageProvider() {
    _imagePath = ''; // Defina um valor padrão para a imagem
  }

  void setImagePath(String path) {
    _imagePath = path;
    notifyListeners();
  }
}

class _PerfilState extends State<Perfil> {
  late String imagePath = '';
  @override
  void initState() {
    super.initState();
    recuperarBioDoBancoDeDados();
    carregarImagemPerfil();
  }

  //Função para regatar a imagem salva localmente ------------------------------
  Future<void> carregarImagemPerfil() async {
    final prefs = await SharedPreferences.getInstance();
    final savedImagePath = prefs.getString(
        '${widget.userId}perfilbusca'); //salvar local usando o "userId" no endereço

    if (savedImagePath != null) {
      setState(() {
        imagePath = savedImagePath;
      });
    } else {
      // Adicione este trecho para carregar a imagem localmente
      final localImagePath = prefs.getString('perfilLocalPath');
      if (localImagePath != null) {
        setState(() {
          imagePath = localImagePath;
        });
      }
    }
  }
  //-------------------------------------------------------------------------------

  //Função para resgatar imagem da galeria --------------------------------------
  Future<void> selecionarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery); //funçoes do "ImagemPicker"

    if (pickedFile != null && mounted) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }
  //-----------------------------------------------------------------------------

  //Função salvar imagem selecionada localmente em um endereço com o "userid"---
  Future<void> salvarImagemPerfil(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('${widget.userId}perfilbusca', imagePath);

    // Adicione este trecho para salvar a imagem no diretório de documentos
    final appDocumentsDirectory = await getApplicationDocumentsDirectory();
    final localImagePath =
        '${appDocumentsDirectory.path}/perfil_${widget.userId}.png';
    File(imagePath).copySync(localImagePath);

    // Guarde a localização do arquivo na preferência
    prefs.setString('perfilLocalPath', localImagePath);

    print('Imagem salva em: $localImagePath');
  }
  //---------------------------------------------------------------------------

  @override
  void dispose() {
    salvarImagemPerfil(imagePath);
    super.dispose();
  }

//Função exibir bio do DB usando o "userid"-------------------------------------
  void recuperarBioDoBancoDeDados() async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    final results = await conexao.query(
      'SELECT bio FROM sua_tabela WHERE id = ?',
      [widget.userId],
    );

    if (results.isNotEmpty) {
      setState(() {
        widget.bioFromDatabase = results.first['bio'];
        widget.bioController.text = widget.bioFromDatabase!;
      });
    }

    await conexao.close();
  }
  //----------------------------------------------------------------------------

  //Função para salvar bio digitada na bio do usuario respectivo usando o "userId"
  void enviarBioParaBancoDeDados(String bio) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    await conexao.query(
      'UPDATE sua_tabela SET bio = ? WHERE id = ?',
      [bio, widget.userId],
    );

    await conexao.close();

    setState(() {
      widget.bioFromDatabase = bio;
      widget.bioController.clear();
    });
  }
//------------------------------------------------------------------------------

//remover bio salva no DB usando "userId" como parametro------------------------
  void apagarBioNoBancoDeDados() async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    await conexao.query(
      'UPDATE sua_tabela SET bio = NULL WHERE id = ?',
      [widget.userId],
    );

    await conexao.close();

    setState(() {
      widget.bioFromDatabase = null;
      widget.bioController.clear();
      salvarImagemPerfil(
          imagePath); // Salvar o caminho da imagem após a atualização do banco de dados
    });
  }
  //-----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(
              context, false), //navegar de volta para pagina anterior
        ),
        title: Text(
          'Perfil',
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
                alignment: Alignment.center, //alinhamento
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 14, 187, 244),
                        borderRadius: BorderRadius.circular(20)),
                    height: 180,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 120),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 70,
                          child: CircleAvatar(
                            backgroundImage: imagePath
                                    .isNotEmpty //exibição da imagem
                                ? FileImage(File(imagePath))
                                    as ImageProvider<Object>
                                : AssetImage(
                                    "assets/images/perfil.png"), //exibir imagem padrão
                            radius: 67,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_photo_alternate),
                          onPressed: () {
                            selecionarFoto();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "${widget.userName}",
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
                      padding: EdgeInsets.only(left: 15),
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
                    "assets/images/maletas.png", //carregar imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '${widget.userProfissao}',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/lugar.png", //carregar imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '${widget.userCidade}',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/car.png", //carregar imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '${widget.userAtuacao}',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                ListTile(
                  leading: Image.asset(
                    "assets/images/zap.png", //carregar imagem local
                    height: 30,
                    width: 30,
                  ),
                  title: Text(
                    '${widget.userNumero}',
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
            widget.bioFromDatabase != null
                ? Column(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        widget.bioFromDatabase!,
                        style: TextStyle(fontSize: 18),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          apagarBioNoBancoDeDados();
                        },
                        child: Icon(Icons.clear), // Ícone "X"
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.0),
                          child: TextField(
                            controller: widget.bioController,
                            decoration: InputDecoration(
                              hintText: 'Adicione uma bio...',
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.create_rounded),
                        onPressed: () {
                          enviarBioParaBancoDeDados(widget.bioController.text);
                        },
                      ),
                    ],
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
                              builder: (context) => Portfolio(
                                  userId:
                                      widget.userId), //navegar para outra tela
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
                                  //navegar para outra tela
                                  idBusca: widget.userId,
                                  idlogado: widget.userId),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
