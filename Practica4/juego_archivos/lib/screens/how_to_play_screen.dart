import 'package:flutter/material.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cómo jugar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const <Widget>[
          _Rule(
            title: '1. Elige una ruta',
            text: 'Toca una casilla y continúa con casillas adyacentes horizontal o verticalmente. No puedes repetirlas ni moverte en diagonal.',
          ),
          _Rule(
            title: '2. Alcanza el objetivo',
            text: 'Selecciona entre 2 y 4 casillas. Pulsa Comprobar cuando la suma sea exactamente igual al objetivo.',
          ),
          _Rule(
            title: '3. Puntuación',
            text: 'Una ruta correcta da 100 puntos y un bono según el tiempo restante. Los errores restan 10 puntos y las pistas 20.',
          ),
          _Rule(
            title: '4. Niveles',
            text: 'Básico usa un tablero 4×4. Avanzado usa 5×5 y algunas casillas bloqueadas. Ambos niveles siempre tienen solución.',
          ),
        ],
      ),
    );
  }
}

class _Rule extends StatelessWidget {
  const _Rule({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(text),
        ],
      ),
    ),
  );
}
