import 'package:flutter/material.dart';

class WorkerHomePage extends StatelessWidget {
  const WorkerHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil Ouvrier')),
      body: const Center(child: Text('Bienvenue sur l\'accueil ouvrier !')),
    );
  }
}
