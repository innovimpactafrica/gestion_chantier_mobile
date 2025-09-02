import 'package:flutter/material.dart';
import '../widgets/navitems_ouvrier.dart';
import 'accueil_page.dart';
import 'taches_page.dart';
import 'pointage_page.dart';
import 'mon_compte_page.dart';

class OuvrierMainScreen extends StatefulWidget {
  const OuvrierMainScreen({Key? key}) : super(key: key);

  @override
  State<OuvrierMainScreen> createState() => OuvrierMainScreenState();
}

class OuvrierMainScreenState extends State<OuvrierMainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AccueilOuvrierPage(
        onVoirPlus: () {
          setState(() {
            selectedIndex = 1;
          });
        },
      ),
      const TachesPage(),
      const PointagePage(),
      const MonCompteOuvrierPage(),
    ];

    return Scaffold(
      body: pages[selectedIndex],
      backgroundColor: const Color(0xFFF5F7FA),
      bottomNavigationBar: OuvrierBottomNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
