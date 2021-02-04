import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:pie_chart/pie_chart.dart' as circularChart;
import 'package:fl_chart/fl_chart.dart';
import 'package:pathapp/utilities/constants.dart';
import 'package:pathapp/utilities/components/backButton.dart';
import 'package:pathapp/screens/Secciones.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pathapp/utilities/components/fonts.dart';
import 'package:pathapp/utilities/functions/firebaseFunctions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pathapp/utilities/functions/alerta.dart';
import 'package:pathapp/screens/sesion_screen.dart';

class CarreraRes{
  String carrera;
  double resultado;

  String getCarrera(){
    return carrera;
  }

  double getResultado(){
    return resultado;
  }


  CarreraRes(this.carrera, this.resultado);
}

class TestData{
  String test;
  List<CarreraRes> puntajes=[];

  TestData(this.test);

  void addCarrera(String carrera, double puntaje){
    puntajes.add(CarreraRes(carrera, puntaje));
  }

  void printPuntajes(){
    print(test);
    for(int i=0;i<puntajes.length;i++){
      print("Carrera: ${puntajes[i].getCarrera()}, Resultado: ${puntajes[i].getResultado()}");
    }
  }

}



class resultadosScreen extends StatefulWidget {
  static String id = 'resultados_screen';

  @override
  _resultadosScreenState createState() => _resultadosScreenState();
}


class _resultadosScreenState extends State<resultadosScreen> {
  Map<String, dynamic> datos={};
  User loggedUser;
  final _cloud=FirebaseFirestore.instance.collection('/usuarios');
  bool saving = false;
  List<dynamic> procesado;

  void getCurrentUser() async {
    try {
      final author = FirebaseAuth.instance;
      loggedUser = await author.currentUser;
      if (loggedUser != null) {
        print(loggedUser.email);
      }
    } on FirebaseAuthException catch (e) {
      mostrarAlerta(context, "Usuario no identificado", e.message );
      Navigator.pushReplacementNamed(context, sesionScreen.id);
      print(e);
    }
  }




  List<dynamic> procesar(Map<String, dynamic> data){
    Map<String, double> pastel={};
    List<TestData> barras=[TestData("Ramas del Conocimiento: Versatilidad"),TestData("Ramas del Conocimiento: Prestigio"),TestData("Capital de Carrera: Habilidades"),TestData("Capital de Carrera: Personas"),TestData("Impacto Social"), TestData("Personal Fit")];
    for(int i=0; i<data['carreras'].length;i++){

      double aux;
      String carrera=data['carreras'][i];
      double aux2=data["cap_habilidades"][carrera].toDouble();
      barras[2].addCarrera(carrera, aux2);

      aux=data["cap_personas"][carrera].toDouble();
      barras[3].addCarrera(carrera, aux);

      double ramas=(aux2+aux)/2;

      aux2=data["prestigio"][carrera].toDouble();
      barras[1].addCarrera(carrera, aux2);

      aux=data["versatilidad"][carrera].toDouble();
      barras[0].addCarrera(carrera, aux);

      double capital=(aux2+aux)/2;

      aux=data["imp_social"][carrera].toDouble();
      barras[4].addCarrera(carrera, aux);

      aux2=data["personal_fit"][carrera].toDouble();
      barras[5].addCarrera(carrera, aux2);

      pastel[carrera]=ramas+capital+aux+aux2;
    }

    return [pastel, barras];

  }

  void update() async {
    await getCurrentUser();
    datos= await getData(context, loggedUser.email);
    // setState(() {
    //   print(datos["cap_personas"]);
    // });
    procesado= procesar(datos);
    print(procesado[0]);
    for(int i =0; i<procesado[1].length; i++){
      procesado[1][i].printPuntajes();
    }
  }

  @override
  void initState(){
    super.initState();
    print('INIT');
    update();
  }

  //GRÁFICAS---------------------------
  //CIRCULAR---------------------------
  List<Color> colorList=[
    Color(0xFF576EF2),
    Color(0xFFF2B84B),
    Color(0xFFF29544),
    Color(0xFFBF7E78),
  ];

  Map<String, double> dataCircular = {
    "ITC": 100,
    "IRS": 50,
    "IBT": 150,
    "LAD": 200,
  };

  //BARRAS----------------------------
  Widget buildChart(TestData data){
    int maxValue=data.carreras[0].puntaje;
    for(int i=0;i<data.carreras.length;i++){
      if(data.carreras[i].puntaje>maxValue){
        maxValue=data.carreras[i].puntaje;
      }
    }

    List<BarChartGroupData> barrasChart=[];

    void cleanData(int index, int value, Color colore){
      if(value>0){
        barrasChart.add(BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              y: value.toDouble(),
              colors: [colore],
              width: MediaQuery.of(context).size.width*0.1,
              borderRadius: BorderRadius.all(Radius.circular(MediaQuery.of(context).size.width*0.02)),
            )
          ],
          showingTooltipIndicators: [0],
        )
        );
      }
    }

    for(int i=0;i<data.carreras.length;i++){
      cleanData(i, data.carreras[i].puntaje, colorList[i]);
    }


    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxValue*1.3).roundToDouble(), //Valor máximo en y (AJUSTAR)
        barTouchData: BarTouchData(
          enabled: false,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.transparent,
            tooltipPadding: const EdgeInsets.all(0),
            tooltipBottomMargin: 8, //Espacio de valores de arriba con barras
            getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
                ) {
              return BarTooltipItem( //Estilo de los números de arriba
                rod.y.round().toString(),
                GoogleFonts.adventPro(
                    fontSize: MediaQuery.of(context).size.height*0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles( //Estilo de los títulos de las columnas
            showTitles: true,
            getTextStyles: (value) => const TextStyle(
              color: Color(0xff7589a2),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            margin: 10,
            getTitles: (double value) {
              switch (value.toInt()) {
                case 0:
                  if(data.carreras[0].carrera.length>5){
                    return data.carreras[0].carrera.substring(0,4)+"...";
                  }
                  return data.carreras[0].carrera;
                case 1:
                  if(data.carreras[1].carrera.length>5){
                    return data.carreras[1].carrera.substring(0,4)+"...";
                  }
                  return data.carreras[1].carrera;
                case 2:
                  if(data.carreras.length>=3){
                    if(data.carreras[2].carrera.length>5){
                      return data.carreras[2].carrera.substring(0,4)+"...";
                    }
                    return data.carreras[2].carrera;
                  }else{
                    break;
                  }
                 return '';
                  case 3:
                if(data.carreras.length==4){
                  if(data.carreras[3].carrera.length>5){
                    return data.carreras[3].carrera.substring(0,4)+"...";
                  }
                  return data.carreras[3].carrera;
                }else{
                  break;
                }
                return '';
                default:
                  return '';
              }
            },
          ),
          leftTitles: SideTitles(
            showTitles: true,
            interval: (maxValue/4).roundToDouble(),
            reservedSize: 20, //Espacio reservado para la barra lateral de escala
          ),
        ),
        borderData: FlBorderData( //Marco que encierra las barras
          show: false,
        ),
        barGroups: barrasChart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreenPercentage = MediaQuery.of(context).size.width;
    final double heightScreenPercentage = MediaQuery.of(context).size.height;
    List<TestData> tests=[
      TestData(name: "Prueba 1"),
      TestData(name: "Prueba 2"),
      TestData(name: "Prueba 3"),
      TestData(name: "Prueba 4"),
      TestData(name: "Prueba 5"),
      TestData(name: "Prueba 6"),
    ];
    return Scaffold(
      backgroundColor: kColorBlancoOpaco,
      body: SafeArea(
        child: Stack(
          children: [
            backButton(
                on_pressed: () {
                  Navigator.pushReplacementNamed(context, SeccionesScreen.id);
                },
                screenWidth: widthScreenPercentage),
            Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: heightScreenPercentage * 0.07),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                            right: widthScreenPercentage * 0.025),
                        child: SvgPicture.asset(
                          'assets/images/star.svg',
                          width: widthScreenPercentage * 0.13,
                        ),
                      ),
                      fontStyleAmaticSC(
                        text: 'RESULTADOS',
                        sizePercentage: 4.5,
                        color: kColorMorado,
                        letterSpacing: widthScreenPercentage * 0.008,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: heightScreenPercentage * 0.05),
                  child: Container(
                    width: widthScreenPercentage * 0.8,
                    height: heightScreenPercentage * 0.17,
                    decoration: BoxDecoration(
                      color: kColorMorado,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          offset: Offset(10, 10),
                          spreadRadius: 2,
                          blurRadius: 7,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        fontStyleDidactGothic(
                            text: 'Puntuación más alta: \n ITC',
                            sizePercentage: 2.8,
                            color: Colors.white),
                        Padding(
                          padding: EdgeInsets.only(
                              left: widthScreenPercentage * 0.04),
                          child: Container(
                            width: widthScreenPercentage * 0.2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: widthScreenPercentage * 0.003,
                              ),
                            ),
                            child: SvgPicture.asset(
                              'assets/images/iconoCarreras.svg',
                              width: widthScreenPercentage * 0.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: heightScreenPercentage * 0.05),
                  child: Container(
                    width: 0.8 * widthScreenPercentage,
                    height: 0.5 * heightScreenPercentage,
                    color: Colors.white60,
                    child: ListView(children: [
                      Container(
                          width: 0.8 * widthScreenPercentage,
                          height: 0.5 * heightScreenPercentage,
                        child: circularChart.PieChart(
                          dataMap: dataCircular,
                          animationDuration: Duration(seconds: 2),
                          chartLegendSpacing: 32,
                          colorList: colorList,
                          legendOptions: circularChart.LegendOptions(
                            showLegendsInRow: true,
                            legendPosition: circularChart.LegendPosition.bottom,
                            showLegends: true,
                            legendShape: BoxShape.circle,
                            legendTextStyle: GoogleFonts.adventPro(
                              fontSize: 20,
                            ),
                          ),
                          chartValuesOptions: circularChart.ChartValuesOptions(
                            showChartValueBackground: true,
                            showChartValues: true,
                            showChartValuesInPercentage: true,
                            showChartValuesOutside: false,
                            chartValueStyle: GoogleFonts.adventPro(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black
                            ),
                          ),
                        ),
                          ),
                      SizedBox(height: 0.05 * heightScreenPercentage,),
                      Container(
                        width: 0.8 * widthScreenPercentage,
                        height: 0.5 * heightScreenPercentage,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            Container(
                              width: 0.8 * widthScreenPercentage,
                              height: 0.5 * heightScreenPercentage,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                      tests[0].name,
                                      style: GoogleFonts.adventPro(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                      ),
                                  ),
                                  Container(
                                    width: 0.7 * widthScreenPercentage,
                                    height: 0.4 * heightScreenPercentage,
                                    child: buildChart(tests[0]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 0.8 * widthScreenPercentage,
                              height: 0.5 * heightScreenPercentage,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    tests[1].name,
                                    style: GoogleFonts.adventPro(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                  Container(
                                    width: 0.7 * widthScreenPercentage,
                                    height: 0.4 * heightScreenPercentage,
                                    child: buildChart(tests[1]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 0.8 * widthScreenPercentage,
                              height: 0.5 * heightScreenPercentage,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    tests[2].name,
                                    style: GoogleFonts.adventPro(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                  Container(
                                    width: 0.7 * widthScreenPercentage,
                                    height: 0.4 * heightScreenPercentage,
                                    child: buildChart(tests[2]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 0.8 * widthScreenPercentage,
                              height: 0.5 * heightScreenPercentage,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                      tests[3].name,
                                      style: GoogleFonts.adventPro(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black
                                      ),
                                  ),
                                  Container(
                                    width: 0.7 * widthScreenPercentage,
                                    height: 0.4 * heightScreenPercentage,
                                    child: buildChart(tests[3]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 0.8 * widthScreenPercentage,
                              height: 0.5 * heightScreenPercentage,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                      tests[4].name,
                                    style: GoogleFonts.adventPro(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                  Container(
                                    width: 0.7 * widthScreenPercentage,
                                    height: 0.4 * heightScreenPercentage,
                                    child: buildChart(tests[4]),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              width: 0.8 * widthScreenPercentage,
                              height: 0.5 * heightScreenPercentage,
                              child: Column(
                                children: <Widget>[
                                  Text(
                                      tests[5].name,
                                    style: GoogleFonts.adventPro(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black
                                    ),
                                  ),
                                  Container(
                                    width: 0.7 * widthScreenPercentage,
                                    height: 0.4 * heightScreenPercentage,
                                    child: buildChart(tests[5]),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TestData{
  String name;
  List<Carrera> carreras=[
    Carrera(carrera: "ITC", puntaje: 87),
    Carrera(carrera: "IRS", puntaje: 100),
    Carrera(carrera: "IMT", puntaje: 120),
    Carrera(carrera: "IPO", puntaje: 200),
  ];

  TestData({this.name});
}

class Carrera{
  String carrera;
  int puntaje;

  Carrera({this.carrera, this.puntaje});
}
