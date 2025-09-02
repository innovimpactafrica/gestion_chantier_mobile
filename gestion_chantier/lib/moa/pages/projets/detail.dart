import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/appbar.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/apropos/Tab1/about.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/apropos/Tab1/avancements/avancement.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/apropos/Tab1/budget.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/apropos/Tab1/equipe.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/apropos/Tab1/etudebet.dart';

class ProjectDetailWidget extends StatefulWidget {
  final RealEstateModel projet;
  final VoidCallback? onBackPressed;

  const ProjectDetailWidget({
    super.key,
    required this.projet,
    this.onBackPressed,
  });

  @override
  State<ProjectDetailWidget> createState() => _ProjectDetailWidgetState();
}

class _ProjectDetailWidgetState extends State<ProjectDetailWidget> {
  int _selectedTabIndex = 0;

  final List<Map<String, String>> tabs = [
    {'icon': 'assets/icons/hom.svg', 'label': 'À propos'},
    {'icon': 'assets/icons/chart.svg', 'label': 'Avancement'},
    {'icon': 'assets/icons/money.svg', 'label': 'Budget'},
    {'icon': 'assets/icons/friend.svg', 'label': 'Équipe'},
    {'icon': 'assets/icons/docs.svg', 'label': 'Études BET'},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomProjectAppBar(
          title: widget.projet.name,
          onBackPressed:
              widget.onBackPressed ?? () => Navigator.of(context).pop(),
        ),
        _buildTabBar(),
        Expanded(child: _buildTabContent()),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: HexColor('#1A365D'),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            tabs.length,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _buildTabItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final tab = tabs[index];
    final isSelected = _selectedTabIndex == index;
    final color = isSelected ? Colors.white : Colors.white70;

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              tab['icon']!,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(height: 10),
            Text(
              tab['label']!,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return AProposTab(projet: widget.projet);
      case 1:
        return AvancementTab(projet: widget.projet);
      case 2:
        return BudgetTab(projet: widget.projet);
      case 3:
        return EquipeTab(projet: widget.projet);
      case 4:
        return EtudeBetTab(projet: widget.projet);
      default:
        return AProposTab(projet: widget.projet);
    }
  }
}
