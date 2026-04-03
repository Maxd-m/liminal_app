import 'package:flutter/material.dart';
import 'package:liminal_app/components/button_component.dart';
import 'package:liminal_app/components/objectiveCard_component.dart';
// import 'package:liminal_app/screens/calendar_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  List<Map<String, dynamic>> objetivos = [
    {'titulo': 'Titulo Objetivo', 'fecha': '00/00/00', 'estado': 'En tiempo'},
    {'titulo': 'Titulo objetivo', 'fecha': '00/00/00', 'estado': 'Vencida'},
    {'titulo': 'Titulo objetivo', 'fecha': '00/00/00', 'estado': 'Vencida'},
    {'titulo': 'Titulo objetivo', 'fecha': '00/00/00', 'estado': 'Completada'},
    {'titulo': 'Titulo objetivo', 'fecha': '00/00/00', 'estado': 'Completada'},
  ];

  // ... (Tus métodos de _abrirModalFiltros y _abrirModalNuevoObjetivo se quedan igual) ...
  void _abrirModalFiltros() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 250,
          child: const Center(
            child: Text(
              'Aquí irán los filtros de estado (Pendiente, Completada, etc.)',
            ),
          ),
        );
      },
    );
  }

  void _abrirModalNuevoObjetivo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.6,
          child: const Center(
            child: Text('Aquí irá el formulario para el nuevo objetivo'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        // ... (Tu botón flotante se queda igual)
        onPressed: _abrirModalNuevoObjetivo,
        backgroundColor: const Color(0xFFF4F5DB),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nuevo objetivo',
              style: TextStyle(fontSize: 8, color: Colors.black54),
            ),
            Icon(Icons.add, color: Colors.black87),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg2.jpg'), // Tu imagen de fondo
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- 1. CABECERA FIJA (Fuera de los Slivers) ---
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  children: [
                    const Text(
                      'ONIRONAUTICA',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 42,
                        color: Color(0xFF7CB8C7),
                      ),
                    ),
                    const Text(
                      'Objetivos',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontSize: 32,
                        color: Color(0xFF9EAA78),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          text: 'Ir a Inicio',
                          backgroundColor: const Color(0xFFD3ACFF),
                          shadowOffset: const Offset(0, 4),
                          onTap: () => Navigator.pop(context),
                        ),
                        CustomButton(
                          text: 'Filtros',
                          backgroundColor: const Color(0xFFD3ACFF),
                          shadowOffset: const Offset(0, 4),
                          onTap:
                              _abrirModalFiltros, // Llama a _abrirModalFiltros
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. LISTA CON SLIVERS ---
              // El Expanded crea un límite estricto: las tarjetas desaparecerán al tocar el borde de los botones.
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    if (objetivos.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No hay objetivos',
                            style: TextStyle(
                              fontFamily: 'Instrument Serif',
                              fontSize: 28,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final obj = objetivos[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: ObjectiveCard(
                                titulo: obj['titulo'],
                                fecha: obj['fecha'],
                                estado: obj['estado'],
                                onVerActividades: () {},
                                onEditar: () {},
                                onEliminar: () {},
                              ),
                            );
                          }, childCount: objetivos.length),
                        ),
                      ),
                  ],
                ),
              ),

              // --- 3. BOTÓN CALENDARIO ---
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 10.0),
                child: CustomButton(
                  text: 'Calendario',
                  backgroundColor: const Color(0xFFD3ACFF),
                  shadowOffset: const Offset(0, 4),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
