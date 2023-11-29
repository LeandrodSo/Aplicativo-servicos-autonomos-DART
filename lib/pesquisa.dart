import 'package:app_servicos/Ajuda.dart';
import 'package:app_servicos/PerfilFavorito.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:app_servicos/PerfilBusca.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyApp(),
    );
  }
}

class Pesquisa extends StatefulWidget {
  final int userId;

  Pesquisa({required this.userId});

  @override
  _PesquisaState createState() => _PesquisaState();
}

class _PesquisaState extends State<Pesquisa> {
  TextEditingController searchController = TextEditingController();
  MySqlConnection? connection;
  List<Map<String, dynamic>> ResultadosBusca = [];

  @override
  void initState() {
    super.initState();
    ConexaoComDB();
  }

  //Função conecta com Db-------------------------------------------------------
  Future<void> ConexaoComDB() async {
    connection = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));
  }
  //----------------------------------------------------------------------------

  //Função resgatar nome usando o "userId"---------------------------------------
  Future<void> ProcurarNome(String profissao) async {
    final results = await connection!.query(
      'SELECT id, cidade, profissao, atuacao, numero FROM sua_tabela WHERE profissao LIKE ? AND id != ?',
      ['%$profissao%', widget.userId],
    );

    setState(() {
      ResultadosBusca = results.map((r) => r.fields).toList();
    });
  }
  //----------------------------------------------------------------------------

  void _NavegarPerfil(Map<String, dynamic> result) async {
    int currentUserId = widget.userId;
    int clickedUserId = result['id'];

    // Consultar na tabela "amigos" se existe uma entrada com status "aceito"
    var amigosQuery = await connection!.query(
      'SELECT * FROM amigos WHERE (idSolicitante = ? AND idRecebedor = ? AND status = "aceito") OR (idSolicitante = ? AND idRecebedor = ? AND Status = "aceito")',
      [currentUserId, clickedUserId, clickedUserId, currentUserId],
    );

    // Se a consulta retornar algum resultado, significa que eles são amigos
    if (amigosQuery.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PerfilFavorito(
            //navegar para outra tela com parametros
            userid: currentUserId,
            amigoId: clickedUserId,
          ),
        ),
      );
    } else {
      // Se não forem amigos, o código segue o fluxo normal para a tela de perfil
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PerfilBusca(
            //navegar para outra tela com parametros
            id: result['id'],
            cidade: result['cidade'],
            profissao: result['profissao'],
            atuacao: result['atuacao'],
            numero: result['numero'],
            userId: currentUserId,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    connection?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pesquisa'),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Busque por serviços',
              ),
              onChanged: (text) {
                ProcurarNome(text);
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ResultadosBusca.length,
                itemBuilder: (context, index) {
                  final result = ResultadosBusca[index];
                  return ListTile(
                    title: Text(
                        'Cidade: ${result['cidade']}'), //Exibir dados na tela
                    subtitle: Text(
                        'Profissão: ${result['profissao']}'), //Exibir dados na tela
                    onTap: () {
                      _NavegarPerfil(result);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
