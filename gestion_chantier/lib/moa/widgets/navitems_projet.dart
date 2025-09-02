// widgets/custom_bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/moa/bloc/incidents/incidents_bloc.dart';
import 'package:gestion_chantier/moa/bloc/projets/projet_event.dart';
import 'package:gestion_chantier/moa/bloc/projets/projet_state.dart';
import 'package:gestion_chantier/moa/bloc/projets/projet_bloc.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/pages/projets/detail.dart';
import 'package:gestion_chantier/moa/pages/projets/document.dart';
import 'package:gestion_chantier/moa/pages/projets/signalement.dart';
import 'package:gestion_chantier/moa/pages/projets/stock.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/bloc/Indicator/ConstructionIndicatorBloc.dart';
import 'package:gestion_chantier/moa/services/ConstructionPhaseIndicator_service.dart';

class MainProjectScreenWrapper extends StatefulWidget {
  final RealEstateModel projet;

  const MainProjectScreenWrapper({super.key, required this.projet});

  @override
  State<MainProjectScreenWrapper> createState() =>
      _MainProjectScreenWrapperState();
}

class _MainProjectScreenWrapperState extends State<MainProjectScreenWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F5F7FA'),
      body: _getPage(context),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }

  Widget _getPage(BuildContext context) {
    final state = context.watch<NavigationBloc>().state;
    final index = state.currentIndex;

    final pages = [
      // Page 0: Project details avec tabs (wrap avec le bloc requis)
      BlocProvider<ConstructionIndicatorBloc>(
        create:
            (_) => ConstructionIndicatorBloc(
              service: ConstructionIndicatorService(),
            ),
        child: ProjectDetailWidget(
          projet: widget.projet,
          onBackPressed: () => Navigator.of(context).pop(),
        ),
      ),
      // Page 1: Stocks
      StockPage(projet: widget.projet),
      // Page 2: Documents
      DocumentsPage(projet: widget.projet),
      // Page 3: Signalements
      BlocProvider(
        create:
            (context) =>
                IncidentsBloc()
                  ..add(LoadIncidentsEvent(propertyId: widget.projet.id)),
        child: SignalementsPage(projet: widget.projet),
      ),
    ];

    return pages[index];
  }
}

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final navItems = [
      _NavItem(iconName: 'home', label: 'À propos', index: 0),
      _NavItem(iconName: 'stock', label: 'Stocks', index: 1),
      _NavItem(iconName: 'docs', label: 'Documents', index: 2),
      _NavItem(iconName: 'alert', label: 'Signalements', index: 3),
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
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: BlocBuilder<NavigationBloc, NavigationState>(
          builder: (context, state) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  navItems
                      .map((item) => _buildBottomNavItem(context, item, state))
                      .toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    _NavItem item,
    NavigationState state,
  ) {
    final isSelected = item.index == state.currentIndex;
    final iconPath =
        isSelected
            ? 'assets/icons/${item.iconName}_selected.svg'
            : 'assets/icons/${item.iconName}.svg';

    return InkWell(
      onTap: () {
        if (!isSelected) {
          context.read<NavigationBloc>().add(
            NavigationIndexChanged(item.index),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(iconPath, width: 20.0, height: 20.0),
          const SizedBox(height: 2.0),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10.0,
              color:
                  isSelected
                      ? const Color(0xFFFF5C02)
                      : const Color.fromARGB(255, 113, 113, 113),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String iconName;
  final String label;
  final int index;

  const _NavItem({
    required this.iconName,
    required this.label,
    required this.index,
  });
}
