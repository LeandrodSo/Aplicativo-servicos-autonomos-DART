import 'package:app_servicos/PerfilBusca.dart';
import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class TelaMaquiador extends StatefulWidget {
  final int userId;

  TelaMaquiador({required this.userId});

  @override
  _TelaMaquiadorState createState() => _TelaMaquiadorState();
}

class _TelaMaquiadorState extends State<TelaMaquiador> {
  late MySqlConnection
      conexao; // Declarando como late para inicializar no initState

  List<Map<String, dynamic>> resultados = [];

  @override
  void initState() {
    super.initState();
    _inicializarConexao(); // Chama o método de inicialização no initState
  }

  Future<void> _inicializarConexao() async {
    conexao = await MySqlConnection.connect(ConnectionSettings(
      host: '192.168.99.104',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    ));

    // Após a conexão ser inicializada, você pode chamar a busca
    await _buscarPalavras([
      'maquiador',
      'profissional',
      'eventos',
      'artística',
      'casamento',
      'formatura',
      'social',
      'noivas',
      'festas',
      'noite',
      'fotográficos',
      'debutantes',
      'corporativos',
      'beleza',
      'pele',
      'negra',
      'clara',
      'natural',
      'profissional',
      'cinema',
      'editorial',
      'noivo',
      'madrinhas',
      'ocasiões',
      'especiais',
      'fotos',
      'oleosa',
      'seca',
      'mista',
      'sensível',
      'anti-idade',
      'rosto',
      'redondo',
      'quadrado',
      'triangular',
      'glamourosa',
      '15',
      'infantil',
      'madura',
      'jovem',
      'acneica',
      'sardas',
      'manchas',
      'rugas',
      'olhos',
      'grandes',
      'pequenos',
      'caídos',
      'orientais',
      'amendoados',
      'azuis',
      'verdes',
      'castanhos',
      'pretos',
      'sensíveis'
    ]);
  }

  Future<String?> buscarNomeUsuario(int idUsuario) async {
    Results result = await conexao.query(
      'SELECT nome FROM usuarios WHERE id = ?',
      [idUsuario],
    );

    if (result.isNotEmpty) {
      return result.first['nome'];
    } else {
      return null;
    }
  }

  void _verPerfil(int userId, int idUsuario, String cidade, String profissao,
      String atuacao, String numero) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PerfilBusca(
            id: idUsuario,
            cidade: cidade,
            profissao: profissao,
            atuacao: atuacao,
            numero: numero,
            userId: userId),
      ),
    );
  }

  Future<void> _buscarPalavras(List<String> palavras) async {
    resultados.clear(); // Limpa os resultados anteriores

    for (String palavra in palavras) {
      Results result = await conexao.query(
        'SELECT id, profissao, atuacao, cidade, numero FROM sua_tabela WHERE profissao LIKE ?',
        ['%$palavra%'],
      );

      // Mapeia os objetos ResultRow para Map<String, dynamic>
      for (ResultRow row in result) {
        int idUsuario = row['id'];
        String? nomeUsuario = await buscarNomeUsuario(idUsuario);

        if (nomeUsuario != null) {
          resultados.add({
            'id': idUsuario,
            'profissao': row['profissao'],
            'atuacao': row['atuacao'],
            'cidade': row['cidade'],
            'numero': row['numero'],
            'nomeUsuario': nomeUsuario,
          });
        }
      }
    }

    setState(() {}); // Atualiza a interface com os resultados
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tela de Cabeleireiro'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Exibindo os resultados
          Expanded(
            child: ListView.builder(
              itemCount: resultados.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('${resultados[index]['profissao']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profissão: ${resultados[index]['nomeUsuario']}'),
                      Text('Atuação: ${resultados[index]['atuacao']}'),
                    ],
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      _verPerfil(
                        widget.userId,
                        resultados[index]['id'],
                        resultados[index]['cidade'],
                        resultados[index]['profissao'],
                        resultados[index]['atuacao'],
                        resultados[index]['numero'],
                      );
                    },
                    child: Text('Ver Perfil'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    conexao.close(); // Fecha a conexão com o banco de dados ao sair da tela
    super.dispose();
  }
}
