import 'package:app_servicos/SuperT%C3%B3picos/AreaTI.dart';
import 'package:app_servicos/SuperT%C3%B3picos/BemEstar.dart';
import 'package:app_servicos/SuperT%C3%B3picos/ConsultoriaFreelancers.dart';
import 'package:app_servicos/SuperT%C3%B3picos/Entrega.dart';
import 'package:app_servicos/SuperT%C3%B3picos/Manutencao.dart';
import 'package:app_servicos/SuperT%C3%B3picos/Saude.dart';
import 'package:flutter/material.dart';

class Cartoes extends StatelessWidget {
  final int userId;

  const Cartoes({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      childAspectRatio: 0.80,
      crossAxisCount: 2,
      shrinkWrap: true,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 8,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 221, 215, 235),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/manutencao.png",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Color.fromARGB(255, 189, 187, 187),
                child: TextButton(
                  child: Text(
                    "Manutenção Residencial",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Manutencao(userId: userId),
                    ));
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 8,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 221, 215, 235),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/coracao.png",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Color(0xffc0c0c0),
                child: TextButton(
                  child: Text(
                    "Saude",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Saude(userId: userId),
                    ));
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 8,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 221, 215, 235),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/tec.png",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Color(0xffc0c0c0),
                child: TextButton(
                  child: Text(
                    "Área de Tecnologia e Informática",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => AreaTI(userId: userId),
                    ));
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 8,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 221, 215, 235),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/yoga.png",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Color(0xffc0c0c0),
                child: TextButton(
                  child: Text(
                    "Beleza e Bem-Estar",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => BemEstar(userId: userId),
                    ));
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 8,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 221, 215, 235),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/motoboy.png",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Color(0xffc0c0c0),
                child: TextButton(
                  child: Text(
                    "Entrega e Transporte",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Entrega(userId: userId),
                    ));
                  },
                ),
              )
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 8,
          ),
          margin: EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 221, 215, 235),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              InkWell(
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Image.asset(
                    "assets/images/freelancer.png",
                    height: 120,
                    width: 120,
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                padding: EdgeInsets.only(
                  left: 15,
                  right: 15,
                ),
                color: Color(0xffc0c0c0),
                child: TextButton(
                  child: Text(
                    "Consultoria e Freelancers",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          Consultoriafreelancer(userId: userId),
                    ));
                  },
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
