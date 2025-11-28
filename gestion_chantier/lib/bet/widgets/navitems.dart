// bet_navitems.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/bet/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/bet/bloc/studies/studies_bloc.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/bloc/home/home_state.dart';
import 'package:gestion_chantier/bet/pages/compte.dart';
import 'package:gestion_chantier/bet/pages/home.dart';
import 'package:gestion_chantier/bet/pages/etudes.dart';

class BetMainScreen extends StatefulWidget {
  final bool off;

  const BetMainScreen({super.key, this.off = false});

  @override
  _BetMainScreenState createState() => _BetMainScreenState();
}

class _BetMainScreenState extends State<BetMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildCurrentPage(),
      backgroundColor: HexColor('#F5F7FA'),
      bottomNavigationBar: BetCustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildCurrentPage() {
    return BlocBuilder<BetHomeBloc, BetHomeState>(
      builder: (context, state) {
        int currentUserId = 0;
        if (state is BetHomeLoaded) {
          currentUserId = state.currentUser.id;
        }

        final List<Widget> pages = [
          const BetHomePage(),
          BlocProvider<BetStudiesBloc>(
            create: (context) => BetStudiesBloc(),
            child: BetEtudesPage(currentUserId: currentUserId),
          ),
          BetComptePage(),
        ];

        return pages[_selectedIndex];
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class BetCustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BetCustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _buildNavItem(context, 0, 'home', 'Accueil'),
      _buildNavItem(context, 1, 'doc', 'Demandes d\'études'),
      _buildNavItem(context, 2, 'user', 'Mon compte'),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(35),
          topRight: Radius.circular(35),
        ),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
          ),
        ],
      ),
      height: 80,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    int index,
    String iconName,
    String label,
  ) {
    final isSelected = index == selectedIndex;
    final iconPath =
        isSelected
            ? 'assets/icons/${iconName}_selected.svg'
            : 'assets/icons/$iconName.svg';

    return InkWell(
      onTap: () {
        if (!isSelected) {
          onItemTapped(index);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 7, left: 7, right: 7),
            child: SvgPicture.asset(iconPath, width: 20.0, height: 20.0),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color:
                  isSelected
                      ? HexColor('#FF5C02')
                      : const Color.fromARGB(255, 113, 113, 113),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
