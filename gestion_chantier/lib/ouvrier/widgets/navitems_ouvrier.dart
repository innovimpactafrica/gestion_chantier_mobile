import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class OuvrierBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const OuvrierBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _buildNavItem(context, 0, 'home', 'Accueil'),
      _buildNavItem(context, 1, 'checks', 'Mes Tâches'),
      _buildNavItem(context, 2, 'qr', 'Pointage'),
      _buildNavItem(context, 3, 'user', 'Mon compte'),
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
      height: 90,
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 7, left: 7, right: 7),
            child: SvgPicture.asset(iconPath, width: 24.0, height: 24.0),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              color:
                  isSelected
                      ? const Color(0xFFFF5C02)
                      : const Color(0xFF717171),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
