import 'package:flutter/material.dart';
import 'package:pathapp/utilities/components/capital_habilidades.dart';
import 'package:pathapp/utilities/components/instruction_box_widget2.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pathapp/utilities/functions/alerta.dart';
import 'package:pathapp/utilities/models/HabilidadesStructure.dart';
import 'package:pathapp/screens/HabilidadesPersona.dart';
import 'package:pathapp/utilities/textos_about.dart';
import 'package:pathapp/screens/about_screen.dart';

class CapitalHabilidadesScreen extends StatelessWidget {
  static String id = 'cap_habilidades_screen';

  CapitalHabilidadesScreen({@required this.carreras});
  List<dynamic> carreras=[]; //Arreglo con las carreras del usuario

  final List<List<TextEditingController>> matrizControladores = []; //Cada carrera tiene tres controladores, y esos sets se guardan en el arreglo
  final List<HabilidadesPorCarrera> habCarreras = []; //Arreglo a pasar a la pantalla de HabilidadesPersona

  //Crear un set de 3 controladores por cada carrera y agregarlo al arreglo
  void createControladores() {
    for (int i = 0; i < carreras.length; i++) {
      List<TextEditingController> controladores = [
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ];
      matrizControladores.add(controladores);
    }
  }

  //Crear la lista de sets, orientados a la izquierda o derecha, de acuerdo al
  //index de la carrera en el arreglo
  List<Widget> createList() {
    createControladores();
    List<Widget> widgets = [];
    for (int i = 0; i < carreras.length; i++) {
      if (i % 2 == 0) {
        widgets.add(CapitalHabilidadesWidgetLeft(carrera: carreras[i],
          controlador1: matrizControladores[i][0],
          controlador2: matrizControladores[i][1],
          controlador3: matrizControladores[i][2],));
      }
      else {
        widgets.add(CapitalHabilidadesWidgetRight(carrera: carreras[i],
          controlador1: matrizControladores[i][0],
          controlador2: matrizControladores[i][1],
          controlador3: matrizControladores[i][2],));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffC3DA67),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check, color: Colors.white,),
        backgroundColor: Colors.black,
        onPressed: (){
          bool completo=true;

          //Verificar cada controlador para saber si está vacío
          for(int i=0; i < carreras.length;i++) {
            for (int j = 0; j < matrizControladores[i].length; j++) {
              if (matrizControladores[i][j].text == "") {
                completo = false;
                break;
              }
            }
          }

          if(completo==false){
            mostrarAlerta(context,"Contesta por favor", "No has calificado todos los campos, por favor intenta de nuevo");
          }else{
            //Recorrer todas las carreras y formar el arreglo de habilidadesPorCarrera
            for(int i=0;i<carreras.length;i++) {
              List<HabilidadRating> habilidadesRatingList = []; //Lista de objetos con habilidades y puntaje
              for (int j = 0; j < matrizControladores[i].length; j++) {
                habilidadesRatingList.add(HabilidadRating(habilidad: matrizControladores[i][j].text, rating: 0));
              }
              //Agregar al arreglo de habilidades por carrera, un objeto que tiene la carrera y el set de habilidades con puntajes
              habCarreras.add(HabilidadesPorCarrera(carrera: carreras[i], habilidadesRating: habilidadesRatingList));
            }

            //Ir a HabilidadesPersona con el objeto habCarreras
            Navigator.push(
                context,
                MaterialPageRoute(
                builder: (context) => HabilidadesPersona(habilidadesCarreras: habCarreras),
            ),
            );
          }
        },
      ),
      body: Column(
        children: [
          SvgPicture.asset(
              "assets/images/curva_blanca.svg",
              width: MediaQuery.of(context).size.width,
          ),
          Expanded(
            child: ListView(
              children: createList(), //Mostrar el set de rows izquierdas y derechas
            ),
          ),
          InstructionBoxWidget(texto: '¿Qué habilidades te gustaría aprender?',),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: EdgeInsets.only(right: MediaQuery.of(context).size.width*0.05),
              child: RawMaterialButton(
                elevation: 10,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => aboutScreen(
                        titulo: kAboutCapitalHabilidadesTitulo,
                        cuerpo: kAboutCapitalHabilidadesCuerpo,
                      ),
                    ),
                  );
                },
                fillColor: Colors.white,
                child: Icon(
                  Icons.help_outline_sharp,
                  color: Colors.black,
                ),
                shape: CircleBorder(),
              ),
              width: MediaQuery.of(context).size.width * 0.1,
            ),
          ),
        ]
      ),
    );
  }
}


