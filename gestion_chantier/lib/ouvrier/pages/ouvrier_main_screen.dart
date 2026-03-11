import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/navitems_ouvrier.dart';
import '../bloc/auth/auth_bloc.dart';
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
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => selectedIndex = index),
          children: [
            AccueilOuvrierPage(
              onVoirPlus: () => _onTabTapped(1),
            ),
            const TachesPage(),
            const PointagePage(),
            const MonCompteOuvrierPage(),
          ],
        ),
        backgroundColor: const Color(0xFFF5F7FA),
        bottomNavigationBar: OuvrierBottomNavigationBar(
          selectedIndex: selectedIndex,
          onItemTapped: _onTabTapped,
        ),
      ),
    );
  }
}
