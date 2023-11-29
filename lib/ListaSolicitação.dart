import 'dart:async';
import 'package:app_servicos/PerfilFavorito.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class SolicitacoesAmizade extends StatefulWidget {
  final int userId;

  SolicitacoesAmizade({Key? key, required this.userId}) : super(key: key);

  @override
  _SolicitacoesAmizadeState createState() =>
      _SolicitacoesAmizadeState(userId: userId);
}

class _SolicitacoesAmizadeState extends State<SolicitacoesAmizade> {
  final int userId;

  _SolicitacoesAmizadeState({required this.userId});

  List<SolicitacaoAmizade> solicitacoesPendentes = [];

  @override
  void initState() {
    super.initState();
    carregarSolicitacoesPendentes();
  }

  void carregarSolicitacoesPendentes() async {
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
      'SELECT amigos.idSolicitante, usuarios.nome, sua_tabela.profissao, sua_tabela.cidade ' +
          'FROM amigos ' +
          'INNER JOIN usuarios ON amigos.idSolicitante = usuarios.id ' +
          'INNER JOIN sua_tabela ON amigos.idSolicitante = sua_tabela.id ' +
          'WHERE amigos.idRecebedor = ? AND amigos.status = ?',
      [userId, 'pendente'],
    );

    solicitacoesPendentes = results
        .map((row) => SolicitacaoAmizade(
              idLogado: row['idSolicitante'] as int,
              nomeSolicitante: row['nome'] ?? '',
              profissao: row['profissao'] ?? '',
              cidade: row['cidade'] ?? '',
            ))
        .toList();

    await connection.close();

    setState(() {});
  }

  void aceitarSolicitacao(SolicitacaoAmizade solicitacao) async {
    // Remova a solicitação da lista
    solicitacoesPendentes.remove(solicitacao);

    // Atualize o status no banco de dados---------------------------------------
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

    await connection.query(
      'UPDATE amigos SET status = ? WHERE idSolicitante = ? AND idRecebedor = ?',
      ['aceito', solicitacao.idLogado, userId],
    );

    await connection.close();

    setState(() {});
  }

  void recusarSolicitacao(SolicitacaoAmizade solicitacao) async {
    // Remova a solicitação da lista
    solicitacoesPendentes.remove(solicitacao);

    // Atualize o status no banco de dados
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

    await connection.query(
      'UPDATE amigos SET status = ? WHERE idSolicitante = ? AND idRecebedor = ?',
      ['recusado', solicitacao.idLogado, userId],
    );

    await connection.close();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitações de Amizade'),
      ),
      body: ListView.builder(
        itemCount: solicitacoesPendentes.length,
        itemBuilder: (context, index) {
          final solicitacao = solicitacoesPendentes[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solicitacao.nomeSolicitante,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Profissão: ${solicitacao.profissao}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Cidade: ${solicitacao.cidade}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        aceitarSolicitacao(solicitacao);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                      ),
                      child: Text('Aceitar'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        recusarSolicitacao(solicitacao);
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
                      ),
                      child: Text('Recusar'),
                    ),
                    SizedBox(width: 10),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SolicitacaoAmizade {
  final int idLogado;
  final String nomeSolicitante;
  final String profissao;
  final String cidade;

  SolicitacaoAmizade({
    required this.idLogado,
    required this.nomeSolicitante,
    required this.profissao,
    required this.cidade,
  });
}
