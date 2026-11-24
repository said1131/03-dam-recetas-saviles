import 'package:flutter/material.dart';
import 'package:recetas_app/data/receta_db.dart';
import 'package:recetas_app/models/receta.dart';
import 'package:recetas_app/models/resenia.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final Receta receta;

  const DetalleRecetaScreen({super.key, required this.receta});

  @override
  State<DetalleRecetaScreen> createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reseniaController = TextEditingController();
  late Future<List<Resenia>> _futureResenias;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _futureResenias = _cargarResenias();
  }

  @override
  void didUpdateWidget(covariant DetalleRecetaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.receta.id != widget.receta.id) {
      _futureResenias = _cargarResenias();
    }
  }

  @override
  void dispose() {
    _reseniaController.dispose();
    super.dispose();
  }

  Future<List<Resenia>> _cargarResenias() {
    return RecetaDb.instancia.obtenerResenias(widget.receta.id);
  }

  Future<void> _agregarResenia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await RecetaDb.instancia.insertarResenia(
        Resenia(
          recetaId: widget.receta.id,
          texto: _reseniaController.text.trim(),
          fecha: DateTime.now(),
        ),
      );
      if (!mounted) return;
      _reseniaController.clear();
      setState(() {
        _futureResenias = _cargarResenias();
        _guardando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la reseña: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final receta = widget.receta;
    return Scaffold(
      appBar: AppBar(title: Text("Detalle de la receta")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              receta.imagenUrl,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Image.asset(
                "assets/images/plato-placeholder.jpg",
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 10,
            children: [
              Chip(label: Text('${receta.tiempoTotal} min')),
              Chip(label: Text(receta.dificultad)),
              Chip(label: Text(receta.cocina)),
              Chip(label: Text('${receta.calorias} kcal')),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Ingredientes: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.ingredientes.map(
            (ingrediente) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(ingrediente)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Preparación: ",
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...receta.instrucciones.asMap().entries.map(
            (entrada) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.deepOrange,
                    child: Text(
                      '${entrada.key + 1}',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(entrada.value)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Reseñas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _reseniaController,
                  decoration: const InputDecoration(
                    labelText: 'Escribe una reseña',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Escribe tu reseña antes de guardarla';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: _guardando ? null : _agregarResenia,
                  child: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Agregar reseña'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<Resenia>>(
            future: _futureResenias,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text(
                  'No se pudieron cargar las reseñas: ${snapshot.error}',
                );
              }

              final resenias = snapshot.data ?? [];
              if (resenias.isEmpty) {
                return const Text('Todavía no hay reseñas para esta receta.');
              }
              return Column(
                children: resenias.map((resenia) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.rate_review_outlined),
                      title: Text(resenia.texto),
                      subtitle: Text(
                        resenia.fecha.toLocal().toString().substring(0, 16),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
