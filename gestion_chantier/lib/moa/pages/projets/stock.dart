import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/repository/delivery_repository.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/delivery/delivery_bloc.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/appbar.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/commandes.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/inventaires/inventaires.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/livraisons.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/statistiques.dart';

class StockPage extends StatefulWidget {
  final RealEstateModel projet;
  final VoidCallback? onBackPressed;

  const StockPage({super.key, required this.projet, this.onBackPressed});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  int _selectedTabIndex = 0;

  final List<Map<String, String>> tabs = [
    {'icon': 'assets/icons/box.svg', 'label': 'Inventaire'},
    {'icon': 'assets/icons/com.svg', 'label': 'Commandes'},
    {'icon': 'assets/icons/bus.svg', 'label': 'Livraisons'},
    {'icon': 'assets/icons/stat.svg', 'label': 'Stat'},
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) => _buildTabItem(index)),
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
        return InventairesTab(projet: widget.projet);
      case 1:
        return CommandesTabWrapper(projet: widget.projet);
      case 2:
        return BlocProvider(
          create: (_) => DeliveryBloc(DeliveryRepository()),
          child: LivraisonsTab(projet: widget.projet),
        );
      case 3:
        return StatistiquesTab(projet: widget.projet);
      default:
        return InventairesTab(projet: widget.projet);
    }
  }
}
