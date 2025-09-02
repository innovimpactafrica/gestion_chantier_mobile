import 'package:flutter/material.dart';

class WorkerTasksPage extends StatelessWidget {
  const WorkerTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tâches Ouvrier')),
      body: const Center(child: Text('Liste des tâches assignées.')),
    );
  }
}
