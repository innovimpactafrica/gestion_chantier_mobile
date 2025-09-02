import 'package:flutter/material.dart';

class WorkerAccountPage extends StatelessWidget {
  const WorkerAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compte Ouvrier')),
      body: const Center(child: Text('Informations du compte ouvrier.')),
    );
  }
}
