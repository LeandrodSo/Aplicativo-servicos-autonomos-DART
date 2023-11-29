import 'package:app_servicos/ListaSolicita%C3%A7%C3%A3o.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'PerfilFavorito.dart';

class Amigos extends StatefulWidget {
  final int userId;

  Amigos({Key? key, required this.userId}) : super(key: key);

  @override
  _AmigosState createState() => _AmigosState(userId: userId);
}

class _AmigosState extends State<Amigos> {
  final int userId;
  List<int> amigosAceitos = []; //Lista para armazenar as informações de amigo

  _AmigosState({required this.userId});

  //Função atualizar amigos aceitos---------------------------------------------
  Future<void> carregarAmigosAceitos() async {
    final amigos = await listarAmigosAceitos();
    setState(() {
      amigosAceitos = amigos;
    });
  }

  //---------------------------------------------------------------------------

  //Função para filtrar apenas amigos "aceitos" do DB---------------------------
  Future<List<int>> listarAmigosAceitos() async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    final results = await conexao.query('''
      SELECT
        CASE
          WHEN idSolicitante = ? THEN idRecebedor
          WHEN idRecebedor = ? THEN idSolicitante
        END AS amigo
      FROM Amigos
      WHERE Status = 'Aceito'
      AND (idSolicitante = ? OR idRecebedor = ?);
    ''', [userId, userId, userId, userId]);

    final amigosAceitos = results
        .map<int>((row) => row['amigo'] as int)
        .toList(); //atribuir resultados a lista

    await conexao.close();

    return amigosAceitos;
  }
  //---------------------------------------------------------------------------

  //Função resgatar o nome do usuario usando o "userId"------------------------
  Future<String?> obterNomeUsuario(int userId) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    final results = await conexao.query(
      'SELECT nome FROM usuarios WHERE id = ?',
      [userId],
    );

    await conexao.close();

    if (results.isNotEmpty) {
      return results.first['nome'] as String;
    } else {
      return null;
    }
  }

  //----------------------------------------------------------------------------

  //Função selecionar uma profissão baseado no "userId"-------------------------
  Future<String?> obterProfissaoUsuario(int userId) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    final results = await conexao.query(
      'SELECT profissao FROM sua_tabela WHERE id = ?',
      [userId],
    );

    await conexao.close();

    if (results.isNotEmpty) {
      return results.first['profissao'] as String;
    } else {
      return null;
    }
  }
  //-----------------------------------------------------------------------------

  //Função que deleta solicitação que se encaixa nas especificações-------------
  Future<void> excluirAmigo(int amigoId) async {
    final conexao = await MySqlConnection.connect(ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    try {
      await conexao.query('''
        DELETE FROM Amigos
        WHERE (idSolicitante = ? AND idRecebedor = ?) OR (idSolicitante = ? AND idRecebedor = ?)
      ''', [userId, amigoId, amigoId, userId]);

      // Atualize a lista de amigos após a exclusão
      await carregarAmigosAceitos();
    } catch (e) {
      print('Erro ao excluir amigo: $e');
    } finally {
      await conexao.close();
    }
  }

  //-----------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    carregarAmigosAceitos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Lista de amigos"),
        actions: [
          IconButton(
            onPressed: () async {
              carregarAmigosAceitos();
            },
            icon: Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SolicitacoesAmizade(userId: userId),
                ),
              );
            },
            icon: Icon(Icons.list_alt),
          ),
        ],
      ),
      body: Container(
        child: ListView.builder(
          itemCount: amigosAceitos.length,
          itemBuilder: (context, index) {
            final amigoId = amigosAceitos[index];
            return FutureBuilder<String?>(
              future: obterNomeUsuario(amigoId),
              builder: (context, nomeSnapshot) {
                if (nomeSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text('Carregando...'));
                }
                if (nomeSnapshot.hasError) {
                  return ListTile(title: Text('Erro ao carregar nome.'));
                }
                if (nomeSnapshot.hasData) {
                  return FutureBuilder<String?>(
                    future: obterProfissaoUsuario(amigoId),
                    builder: (context, profissaoSnapshot) {
                      if (profissaoSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return ListTile(title: Text('Carregando profissão...'));
                      }
                      if (profissaoSnapshot.hasError) {
                        return ListTile(
                            title: Text('Erro ao carregar profissão.'));
                      }
                      if (profissaoSnapshot.hasData) {
                        return ListTile(
                          title: Text('${nomeSnapshot.data}'),
                          subtitle: Text('${profissaoSnapshot.data}'),
                          trailing: IconButton(
                            icon: Icon(Icons.group_remove),
                            onPressed: () async {
                              // Chame a função para excluir o amigo quando o botão for pressionado
                              await excluirAmigo(amigoId);

                              // Mostre o dialog informando que o usuário foi removido com sucesso
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title:
                                        Text('Usuário removido com sucesso!'),
                                    actions: [
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
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PerfilFavorito(
                                  amigoId: amigoId,
                                  userid: userId,
                                ),
                              ),
                            );
                            print('Clicou no usuário ${nomeSnapshot.data}');
                          },
                        );
                      }
                      return Container();
                    },
                  );
                }
                return Container();
              },
            );
          },
        ),
      ),
    );
  }
}
