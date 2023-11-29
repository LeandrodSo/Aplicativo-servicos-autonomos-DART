import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class CriarContrato extends StatefulWidget {
  final int amigoId;
  final int userid;

  CriarContrato({required this.amigoId, required this.userid});

  @override
  _CriarContratoState createState() => _CriarContratoState();
}

class _CriarContratoState extends State<CriarContrato> {
  final _formKey = GlobalKey<FormState>();
  //strings vazias para receber as informaçoes
  String servicoOferecido = "";
  String localRealizado = "";
  String valorNegociado = "";
  String informacoesDetalhadas = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cadastro de Contrato"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.blue.shade200],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Qual serviço será oferecido?'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, preencha este campo.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      servicoOferecido = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Em que local será realizado?'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, preencha este campo.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      localRealizado = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: 'Qual valor negociado?'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Por favor, preencha este campo.';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      valorNegociado = value;
                    });
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Informações detalhadas sobre o trabalho:'),
                  maxLines: 5,
                  onChanged: (value) {
                    setState(() {
                      informacoesDetalhadas = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Chamando a função de criação de contrato
                      createContrato();
                      print('Contrato criado com sucesso');
                      // Volte à tela anterior
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Sucesso"),
                            content: Text(
                                "Contrato enviado ao cliente com sucesso!"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.pop(context); // Feche o AlertDialog
                                  Navigator.pop(
                                      context); // Volte à tela anterior
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Criar Contrato'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Função para criar o contrato no banco de dados
  Future<void> createContrato() async {
    final settings = ConnectionSettings(
      //host: '172.22.87.199',
      host: '192.168.99.105',
      port: 3306,
      user: 'dart_user',
      password: 'dart_pass',
      db: 'dart',
    );

    final MySqlConnection connection = await MySqlConnection.connect(settings);

    final formattedDate =
        DateTime.now().toLocal().toIso8601String(); // Formate a data e hora

    //Inserir as informaçoes na tabela "contratoa"
    final result = await connection.query(
      'INSERT INTO contratos (servico, trabalhador_id, cliente_id, data_contrato, descricao, valor, status) VALUES (?, ?, ?, ?, ?, ?, ?)',
      [
        servicoOferecido,
        widget.userid,
        widget.amigoId,
        formattedDate,
        informacoesDetalhadas,
        valorNegociado,
        'pendente'
      ],
    );

    await connection.close();

    if (result.affectedRows! > 0) {
      // Contrato criado com sucesso
      print('Contrato criado com sucesso');
      // Você pode adicionar lógica adicional aqui, como redirecionar o usuário.
    } else {
      // Erro ao criar o contrato
      print('Erro ao criar o contrato');
    }
  }
}
