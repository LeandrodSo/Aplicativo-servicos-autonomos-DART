import 'dart:io'; // Biblioteca para manipulação de arquivos no sistema.
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Biblioteca para selecionar imagens da galeria ou câmera

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Certificados(), //Define a tela Certificados como tela inicial.
    );
  }
}

class Certificados extends StatefulWidget {
  @override
  _CertificadosState createState() => _CertificadosState();
}

class _CertificadosState extends State<Certificados> {
  File? _selectedImage;

  //Função que obtem imagem da galeria ------------------------------------------

  Future _ObterImagemGaleria() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  //----------------------------------------------------------------------------

  //Função que obtem imagem da camera ------------------------------------------
  Future _ObterImagemCamera() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

//------------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Certificados'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, //alinhamento centro
          children: <Widget>[
            _selectedImage != null
                ? Image.file(_selectedImage!) //Exibe a imagem selecionada.
                : Text('Nenhuma imagem selecionada'),
            ElevatedButton(
              onPressed:
                  _ObterImagemGaleria, // Botão para selecionar uma imagem da galeria.

              child: Text('Selecione imagem da galeria'),
            ),
            SizedBox(height: 20), // Espaçamento entre os botões.
            ElevatedButton(
              onPressed:
                  _ObterImagemCamera, // Botão para selecionar tirar uma foto.

              child: Text('Usar a câmera'),
            ),
          ],
        ),
      ),
    );
  }
}
