import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:liminal_app/components/button_component.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _titulo = false;

  @override
  Widget build(BuildContext context) {
    const colorizeColors = [
      Color(0xFF2E3982),
      Color(0xFFD4B8FF),
      Color.fromARGB(255, 247, 233, 153),
      // Colors.red,
    ];

    const colorizeTextStyle = TextStyle(
      fontFamily: 'Instrument Serif',
      fontSize: 42,
      color: Color(0xFF2E3982),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          // Color de fondo base (verde oliva)
          // color: Color(0xFF9E9E68),
          // Descomenta esto si vas a usar el patrón de fondo como imagen
          image: DecorationImage(
            image: AssetImage('assets/bg1.jpg'),
            fit: BoxFit.cover,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Textos de la Cabecera ---
              Padding(
                padding: EdgeInsets.only(top: 60.0),
                child: Column(
                  children: [
                    AnimatedOpacity(
                      opacity: _titulo
                          ? 1.0
                          : 0.0, // Si es true, opacidad 1 (visible), si no 0 (invisible)
                      duration: const Duration(milliseconds: 2000),
                      child: AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: [
                          ColorizeAnimatedText(
                            'Onironautica',
                            textStyle: colorizeTextStyle,
                            colors: colorizeColors,
                            speed: const Duration(milliseconds: 2000),
                          ),
                        ],
                        isRepeatingAnimation: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: SizedBox(
                        width: 250.0,
                        child: DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontStyle: FontStyle.italic,
                            fontSize: 28,
                            height: 1.2,
                            color: Color(0xFFA7E7FF), // Azul claro / cian
                          ),
                          // speed: const Duration(milliseconds: 2000),
                          child: AnimatedTextKit(
                            totalRepeatCount: 2,
                            isRepeatingAnimation: false,
                            pause: const Duration(milliseconds: 2000),
                            onFinished: () {
                              setState(() {
                                _titulo = true;
                              });
                            },
                            animatedTexts: [
                              TyperAnimatedText(
                                'Soñar es bueno,',
                                textAlign: TextAlign.center,
                              ),
                              TyperAnimatedText(
                                'despertar es necesario...',
                                textAlign: TextAlign.center,
                              ),
                            ],
                            onTap: () {
                              print("Tap Event");
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Botones Centrales (Morados) ---
              Column(
                children: [
                  CustomButton(
                    text: 'Objetivos',
                    backgroundColor: Color(0xFFD4B8FF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/list"),
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: 'Categorias y actividades',
                    backgroundColor: Color(0xFFD4B8FF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/cruds"),
                  ),
                  SizedBox(height: 32),
                  CustomButton(
                    text: '¿Galería?',
                    backgroundColor: Color(0xFFD4B8FF),
                    shadowOffset: Offset(0, 8), // Y = 8
                    onTap: () => Navigator.pushNamed(context, "/gallery"),
                  ),
                ],
              ),

              // --- Botón Inferior (Naranja) ---
              Padding(
                padding: EdgeInsets.only(bottom: 60.0),
                // child: CustomButton(
                //   text: 'Lorem ipsum',
                //   backgroundColor: Color(0xFFFFC6A7),
                //   shadowOffset: Offset(0, 4), // Y = 4
                //   onTap: () => Navigator.pushNamed(context, "/list"),
                // ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
