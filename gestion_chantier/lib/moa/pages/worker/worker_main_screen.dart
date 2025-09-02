import 'package:flutter/material.dart';
import 'home.dart';
import 'tasks.dart';
import 'attendance.dart';
import 'account.dart';

class WorkerMainScreen extends StatefulWidget {
  const WorkerMainScreen({Key? key}) : super(key: key);

  @override
  State<WorkerMainScreen> createState() => _WorkerMainScreenState();
}

class _WorkerMainScreenState extends State<WorkerMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    WorkerHomePage(),
    WorkerTasksPage(),
    WorkerAttendancePage(),
    WorkerAccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist),
            label: 'Mes Tâches',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Pointage'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Mon compte',
          ),
        ],
      ),
    );
  }
}
