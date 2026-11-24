import 'package:flutter/material.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/services/recipe_service.dart';
import 'package:recetas_app/widgets/receta_card.dart';

import 'detalle_receta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  late Future<List<Receta>> _futureRecetas;
  // para el filtro
  List<Receta> _recetasFiltradas = [];
  List<Receta> _todasLasRecetas = [];

  final TextEditingController _buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureRecetas = _recipeService.obtenerRecetas();
  }

  void _filtrarRecetas(String texto) {
    setState(() {
      _recetasFiltradas = _todasLasRecetas.where((receta) {
        return receta.nombre.toLowerCase().contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'RecetasApp',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          //Oswaldo Said Aviles Cruz
        ),
        backgroundColor: const Color.fromARGB(255, 19, 79, 36),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsetsGeometry.all(12),
            child: TextField(
              controller: _buscadorController,
              onChanged: _filtrarRecetas,
              decoration: InputDecoration(
                hintText: 'Buscar receta...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Receta>>(
              future: _futureRecetas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                //condicion para el buscador
                if(_todasLasRecetas.isEmpty) {
                  _todasLasRecetas = snapshot.data!;
                  _recetasFiltradas = snapshot.data!;
                }

                if (_recetasFiltradas.isEmpty) {
                  return const Center(child: Text("No se encontraron recetas"),);
                }

                final recetas = _recetasFiltradas;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: recetas.length,
                  itemBuilder: (context, index) {
                    return RecetaCard(
                      receta: recetas[index],
                      onTap: () async {
                        final bool? esFavorita = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetalleRecetaScreen(receta: recetas[index]),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
