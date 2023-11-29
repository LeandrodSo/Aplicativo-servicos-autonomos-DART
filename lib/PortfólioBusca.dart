import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PortfolioBusca extends StatefulWidget {
  final int userId;

  PortfolioBusca({required this.userId}); //dado requisitado para acesso

  @override
  _UserGallerySearchState createState() => _UserGallerySearchState();
}

class _UserGallerySearchState extends State<PortfolioBusca> {
  List<File> _imageList = []; //lista vazia para as imagens

  @override
  void initState() {
    super.initState();
    _CarregarImagem();
  }

  //Função para exibir as imagens na tela ---------------------------------------
  Future<void> _CarregarImagem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userImagePaths =
        prefs.getStringList('${widget.userId}_imagePaths') ?? [];

    setState(() {
      _imageList =
          userImagePaths.map((path) => File(path)).toList(); //carregar a lista
    });
  }
  //----------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeria do usuário'), //titulo da tela
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _imageList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(
                    _imageList[index], //
                    height: 200,
                    width: 200,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
