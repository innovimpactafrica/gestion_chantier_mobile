import 'package:flutter/material.dart';

class WorkerAttendancePage extends StatelessWidget {
  const WorkerAttendancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pointage Ouvrier')),
      body: const Center(
        child: Text('Page de pointage (présence, heures, etc.).'),
      ),
    );
  }
}
