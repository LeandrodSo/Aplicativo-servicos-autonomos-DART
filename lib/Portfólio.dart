import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class Portfolio extends StatefulWidget {
  final int userId;

  Portfolio({required this.userId}); //dado requisitado para acesso

  @override
  _UserGalleryState createState() => _UserGalleryState();
}

class _UserGalleryState extends State<Portfolio> {
  List<File> _imageList = []; //lista de imagens

  @override
  void initState() {
    super.initState();
    _carregarImagem();
  }

  //Função Carregar as imagens salvas nos endereços locais-----------------------
  Future<void> _carregarImagem() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> userImagePaths =
        prefs.getStringList('${widget.userId}_imagePaths') ?? []; //

    setState(() {
      _imageList = userImagePaths.map((path) => File(path)).toList();
    });
  }
  //----------------------------------------------------------------------------

  Future<void> _salvarImagem(List<String> userImagePaths) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.userId}_imagePaths', userImagePaths);
  }

  Future<void> _SelecionarImagem(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      final String path = await _SalvarImagemLocamente(
          File(pickedFile.path)); //chamada da função que salva imagem
      setState(() {
        _imageList.add(File(path));
      });

      List<String> userImagePaths =
          _imageList.map((image) => image.path).toList();
      await _salvarImagem(userImagePaths);
    }
  }

//Função que salva Imgens localmente nos endereços -----------------------------
  Future<String> _SalvarImagemLocamente(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final String fileName = basename(image.path);
    final String filePath = '${appDir.path}/$fileName';

    await image.copy(filePath);
    return filePath;
  }
  //----------------------------------------------------------------------------

  //Função remover a imagem da lista -------------------------------------------
  void _deletarImagem(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Confirmar exclusão"),
          content: Text("Tem certeza de que deseja excluir esta imagem?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _removeImage(index);
                Navigator.pop(dialogContext);
              },
              child: Text("Excluir"),
            ),
          ],
        );
      },
    );
  }
  //----------------------------------------------------------------------------

  void _removeImage(int index) {
    setState(() {
      _imageList.removeAt(index);
    });

    //Incluir imagem a lista de imagens
    List<String> userImagePaths =
        _imageList.map((image) => image.path).toList();
    _salvarImagem(userImagePaths);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sua galeria'),
      ),
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Center(
            child: ElevatedButton(
              onPressed: () => _SelecionarImagem(ImageSource.gallery),
              child: Text('Escolher imagem da galeria'),
            ),
          ),
          SizedBox(height: 16.0), // Adiciona espaço entre o botão e o Wrap
          Expanded(
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: _imageList.map((File image) {
                //mapa para exibir as imagens
                return Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      image,
                      height: 400,
                      width: 400,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => //botão que deleta imagem
                          _deletarImagem(context, _imageList.indexOf(image)),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
