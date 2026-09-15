import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hola Mundo - Flutter'),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Hola Mundo', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
              ),
              SizedBox(height: 16),
              Text(
                'Gerardo Rendón Bibiano', 
                style: TextStyle(fontSize: 20)
              ),
              Text(
                'Boleta: 2022630011', 
                style: TextStyle(fontSize: 20)
              ),
              Text(
                'Grupo: 7CV4', 
                style: TextStyle(fontSize: 20)
              ),
            ],
          ),
        ),
      ),
    );
  }
}