import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_chantier/moa/models/ExpensesModel.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/models/BudgetModel.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';
import 'package:gestion_chantier/moa/services/budget_service.dart';

import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'dart:math' as math;

import 'package:gestion_chantier/moa/widgets/CustomFloatingButton.dart';

class BudgetTab extends StatefulWidget {
  final RealEstateModel projet;

  const BudgetTab({super.key, required this.projet});

  @override
  _BudgetTabState createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> {
  final BudgetService _budgetService = BudgetService();
  bool _isSubmitting = false;
  bool _isProjectOwner = false;
  String? _currentUserId;

  BudgetModel? budget;
  List<ExpenseModel> depenses = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  /// Version améliorée de _loadBudgetData avec gestion d'erreur

  Future<void> _loadBudgetData() async {
    // Vérifier si le widget est toujours monté avant de commencer
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('🔄 Chargement des données du budget...');

      // Vérifier l'authentification
      final currentUser = await AuthService().connectedUser();
      if (currentUser == null) {
        throw Exception('Utilisateur non authentifié');
      }

      // Stocker l'ID de l'utilisateur actuel
      _currentUserId = currentUser['id'].toString();

      // Charger le budget
      final budgetData = await _budgetService.getBudgetByPropertyId(
        widget.projet.id,
      );

      // Vérifier à nouveau si le widget est monté après l'opération asynchrone
      if (!mounted) return;

      // Vérifier si l'utilisateur est le propriétaire du projet
      bool isOwner = false;
      if (budgetData != null) {
        final projectOwnerId = budgetData.property.promoter.id.toString();
        isOwner = _currentUserId == projectOwnerId;
        print(
          '🔍 Vérification de propriété: Utilisateur=$_currentUserId, Propriétaire=$projectOwnerId, EstPropriétaire=$isOwner',
        );
        print(
          '🔍 Type Utilisateur: ${_currentUserId.runtimeType}, Type Propriétaire: ${projectOwnerId.runtimeType}',
        );
        print('🔍 Égalité stricte: ${_currentUserId == projectOwnerId}');
        print(
          '🔍 Égalité avec conversion: ${_currentUserId.toString() == projectOwnerId.toString()}',
        );
      } else {
        print('⚠️ Aucun budget trouvé pour vérifier la propriété');
      }

      // Charger l'historique des dépenses
      List<ExpenseModel> expensesData = [];
      if (budgetData != null) {
        try {
          expensesData = await _budgetService.getExpenseHistory(budgetData.id);
          print('✅ ${expensesData.length} dépenses chargées');
        } catch (e) {
          print('⚠️ Erreur lors du chargement des dépenses (non critique): $e');
          expensesData = [];
        }
      } else {
        print('⚠️ Aucun budget trouvé pour ce projet');
      }

      // Vérifier une dernière fois avant setState
      if (!mounted) return;

      setState(() {
        budget = budgetData;
        depenses = expensesData;
        _isProjectOwner = isOwner;
        isLoading = false;
      });

      print('✅ Données du budget chargées avec succès');
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');

      // Vérifier si le widget est toujours monté avant setState
      if (mounted) {
        setState(() {
          errorMessage = _getErrorMessage(e);
          isLoading = false;
        });
      }
    }
  }

  /// Helper method to safely show error messages
  void _showErrorSnackBar(BuildContext context, String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Getters pour calculer les valeurs
  double get budgetTotal =>
      budget?.plannedBudget ?? widget.projet.price.toDouble();
  double get budgetUtilise => budget?.consumedBudget ?? 0.0;
  double get budgetRestant => budget?.remainingBudget ?? budgetTotal;
  double get pourcentageUtilise =>
      budgetTotal > 0 ? (budgetUtilise / budgetTotal) * 100 : 0;
  double get pourcentageRestant =>
      budgetTotal > 0 ? (budgetRestant / budgetTotal) * 100 : 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F2F5F9'),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                onRefresh: _loadBudgetData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Column(
                    children: [
                      _buildBudgetCard(),
                      const SizedBox(height: 20),
                      _buildExpensesList(),
                    ],
                  ),
                ),
              ),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/icons/plus.svg',
        onPressed: _showAddExpenseDialog,
        label: '',
        backgroundColor: HexColor('#FF5C02'),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Erreur lors du chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Une erreur inattendue s\'est produite',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBudgetData,
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#FF5C02'),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 20, right: 16),
      child: Column(
        children: [
          // Graphique circulaire avec labels dynamiques
          SizedBox(width: 270, height: 270, child: _buildDynamicPieChart()),

          // Budget prévu
          Text(
            'Budget prévu',
            style: TextStyle(
              fontSize: 10,
              color: HexColor('#6B7280'),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_formatAmount(budgetTotal)} F',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // Budget utilisé et restant
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Budget restant',
                        style: TextStyle(
                          fontSize: 10,
                          color: HexColor('#6B7280'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatAmount(budgetRestant)} F',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HexColor('#FF5C02'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: HexColor('#6B7280').withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Budget utilisé',
                        style: TextStyle(
                          fontSize: 10,
                          color: HexColor('#6B7280'),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatAmount(budgetUtilise)} F',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: HexColor('#14BA6D'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Bouton modifier
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color:
                  _isProjectOwner
                      ? HexColor('#FF5C02').withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: InkWell(
              onTap: _isProjectOwner ? _showModifyBudgetDialog : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color:
                          _isProjectOwner ? HexColor('#FF5C02') : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _isProjectOwner
                            ? 'Modifier le budget'
                            : 'Seul le propriétaire peut modifier',
                        style: TextStyle(
                          color:
                              _isProjectOwner ? HexColor('#FF5C02') : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: HexColor('#EBF3FE').withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 60,
              startDegreeOffset: -90,
              centerSpaceColor: HexColor('#FFF'),
              sections: [
                PieChartSectionData(
                  color: HexColor('#14BA6D'),
                  value: pourcentageUtilise,
                  title: '',
                  radius: 40,
                ),
                PieChartSectionData(
                  color: HexColor('#FF5C02'),
                  value: pourcentageRestant,
                  title: '',
                  radius: 40,
                ),
              ],
            ),
          ),
        ),
        // Labels de pourcentage positionnés dynamiquement
        ..._buildDynamicLabels(),
      ],
    );
  }

  List<Widget> _buildDynamicLabels() {
    List<Widget> labels = [];

    // Vérifier si les pourcentages sont valides pour éviter les divisions par zéro
    if (budgetTotal <= 0) return labels;

    // Calculer l'angle pour le budget utilisé (commence à -90 degrés)
    double angleUtilise = -90 + (pourcentageUtilise * 360 / 100) / 2;
    double angleRestant =
        -90 +
        pourcentageUtilise * 360 / 100 +
        (pourcentageRestant * 360 / 100) / 2;

    // Convertir en radians
    double radiansUtilise = angleUtilise * math.pi / 180;
    double radiansRestant = angleRestant * math.pi / 180;

    // Rayon pour positionner les labels (plus grand que le graphique)
    double radius = 90;

    // Position pour le label "Budget utilisé"
    double xUtilise = radius * math.cos(radiansUtilise);
    double yUtilise = radius * math.sin(radiansUtilise);

    labels.add(
      Positioned(
        left: 125 + xUtilise - 25,
        top: 125 + yUtilise - 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${pourcentageUtilise.toStringAsFixed(3)}%', // ← MODIFICATION ICI
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
        ),
      ),
    );

    // Position pour le label "Budget restant"
    double xRestant = radius * math.cos(radiansRestant);
    double yRestant = radius * math.sin(radiansRestant);

    labels.add(
      Positioned(
        left: 125 + xRestant - 25,
        top: 125 + yRestant - 15,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '${pourcentageRestant.toStringAsFixed(3)}%', // ← MODIFICATION ICI
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF5722),
            ),
          ),
        ),
      ),
    );

    return labels;
  }

  Widget _buildExpensesList() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    'Liste des dépenses',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              // Bouton de tri/filtre seulement si on a des dépenses
              if (depenses.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                  onSelected: (value) {
                    switch (value) {
                      case 'date_asc':
                        _sortExpensesByDate(ascending: true);
                        break;
                      case 'date_desc':
                        _sortExpensesByDate(ascending: false);
                        break;
                      case 'amount_asc':
                        _sortExpensesByAmount(ascending: true);
                        break;
                      case 'amount_desc':
                        _sortExpensesByAmount(ascending: false);
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'date_desc',
                          child: Row(
                            children: [
                              Icon(Icons.date_range, size: 16),
                              SizedBox(width: 8),
                              Text('Plus récent'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'date_asc',
                          child: Row(
                            children: [
                              Icon(Icons.date_range, size: 16),
                              SizedBox(width: 8),
                              Text('Plus ancien'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'amount_desc',
                          child: Row(
                            children: [
                              Icon(Icons.attach_money, size: 16),
                              SizedBox(width: 8),
                              Text('Montant décroissant'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'amount_asc',
                          child: Row(
                            children: [
                              Icon(Icons.attach_money, size: 16),
                              SizedBox(width: 8),
                              Text('Montant croissant'),
                            ],
                          ),
                        ),
                      ],
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (depenses.isEmpty)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aucune dépense disponible',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Les dépenses apparaîtront ici une fois ajoutées',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: depenses.length,
                separatorBuilder:
                    (context, index) =>
                        Divider(height: 1, color: Colors.grey.shade200),
                itemBuilder: (context, index) {
                  final depense = depenses[index];
                  return _buildExpenseItem(depense, index);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseModel depense, int index) {
    return InkWell(
      onTap: () => _showExpenseDetails(depense),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: HexColor('#FF5C02').withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getCategoryIcon(depense.description),
                color: HexColor('#FF5C02'),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    depense.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(depense.date),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_formatAmount(depense.amount)} F',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: HexColor('#FF5C02'),
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes de tri
  void _sortExpensesByDate({required bool ascending}) {
    setState(() {
      depenses.sort((a, b) {
        return ascending ? a.date.compareTo(b.date) : b.date.compareTo(a.date);
      });
    });
  }

  void _sortExpensesByAmount({required bool ascending}) {
    setState(() {
      depenses.sort((a, b) {
        return ascending
            ? a.amount.compareTo(b.amount)
            : b.amount.compareTo(a.amount);
      });
    });
  }

  // Icône en fonction du type de dépense
  IconData _getCategoryIcon(String description) {
    String lowerDescription = description.toLowerCase();
    if (lowerDescription.contains('matériel') ||
        lowerDescription.contains('materiel')) {
      return Icons.build_outlined;
    } else if (lowerDescription.contains('transport')) {
      return Icons.local_shipping_outlined;
    } else if (lowerDescription.contains('salaire') ||
        lowerDescription.contains('personnel')) {
      return Icons.people_outline;
    } else if (lowerDescription.contains('carburant') ||
        lowerDescription.contains('essence')) {
      return Icons.local_gas_station_outlined;
    } else if (lowerDescription.contains('repas') ||
        lowerDescription.contains('nourriture')) {
      return Icons.restaurant_outlined;
    } else {
      return Icons.shopping_cart_outlined;
    }
  }

  // Dialogue de détails de dépense
  void _showExpenseDetails(ExpenseModel depense) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Détail de la dépense',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: HexColor('#FF5C02').withOpacity(0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              _getCategoryIcon(depense.description),
                              color: HexColor('#FF5C02'),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Description',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  depense.description,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                _formatDate(depense.date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Montant',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${_formatAmount(depense.amount)} F',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: HexColor('#FF5C02'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (depense.category.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catégorie',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              depense.category,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor('#FF5C02'),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Fermer',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showModifyBudgetDialog() {
    final TextEditingController amountController = TextEditingController(
      text: budgetTotal.toInt().toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with close button
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Budget',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              _isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: 28,
                            color: HexColor('#231F20'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Montant field
                          Text(
                            'Montant (FCFA)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HexColor('#333333'),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: HexColor('#CBD5E1')),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: amountController,
                              enabled: !_isSubmitting,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: 'Saisir le montant',
                                hintStyle: TextStyle(
                                  color: HexColor('#6B7280'),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Enregistrer button
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmitting
                                      ? null
                                      : () async {
                                        await _handleBudgetUpdate(
                                          amountController,
                                          setModalState,
                                          context,
                                        );
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor('#FF5C02'),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  _isSubmitting
                                      ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Mise à jour...',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                      : Text(
                                        'Mettre à jour',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Fixed version of _handleBudgetUpdate with proper lifecycle management
  Future<void> _handleBudgetUpdate(
    TextEditingController amountController,
    StateSetter setModalState,
    BuildContext context,
  ) async {
    // Validation basique
    if (amountController.text.isEmpty) {
      _showErrorSnackBar(context, 'Veuillez saisir un montant');
      return;
    }

    if (budget == null) {
      _showErrorSnackBar(context, 'Aucun budget trouvé pour ce projet');
      return;
    }

    // Validation et parsing du montant
    final newAmount = double.tryParse(amountController.text);
    if (newAmount == null || newAmount < 0) {
      _showErrorSnackBar(context, 'Veuillez saisir un montant valide');
      return;
    }

    // Vérifier si la valeur a changé
    if (newAmount == budgetTotal) {
      Navigator.of(context).pop();
      return;
    }

    // Mettre à jour l'état pour montrer le loading (avec vérification mounted)
    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

    // Également mettre à jour l'état du modal
    setModalState(() {
      // Update modal state if needed
    });

    try {
      print('🔄 Tentative de mise à jour du budget...');
      print('🔄 Budget ID: ${budget!.id}');
      print('🔄 Ancien montant: $budgetTotal');
      print('🔄 Nouveau montant: $newAmount');

      // Vérifier l'authentification
      final currentUser = await AuthService().connectedUser();
      if (currentUser == null) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      // Appeler le service de mise à jour
      final updatedBudget = await _budgetService.updatePlannedBudget(
        budget!.id,
        newAmount,
      );

      if (updatedBudget == null) {
        throw Exception('Échec de la mise à jour du budget');
      }

      print('✅ Budget mis à jour avec succès');
      print('✅ Nouvelle valeur: ${updatedBudget.plannedBudget}');

      // Recharger les données seulement si le widget est toujours monté
      if (mounted) {
        await _loadBudgetData();
      }

      // Fermer le modal et afficher le succès seulement si le context est valide
      if (context.mounted) {
        Navigator.of(context).pop();

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Budget mis à jour: ${_formatAmount(updatedBudget.plannedBudget)} FCFA',
                  ),
                ),
              ],
            ),
            backgroundColor: Color(0xFF4CAF50),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du budget: $e');

      if (context.mounted) {
        // Gestion spécifique des erreurs
        String errorMessage = _getErrorMessage(e);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action:
                errorMessage.contains('Session expirée') ||
                        errorMessage.contains('non authentifié')
                    ? SnackBarAction(
                      label: 'Se reconnecter',
                      textColor: Colors.white,
                      onPressed: () => _handleReconnection(context),
                    )
                    : SnackBarAction(
                      label: 'Réessayer',
                      textColor: Colors.white,
                      onPressed:
                          () => _handleBudgetUpdate(
                            amountController,
                            setModalState,
                            context,
                          ),
                    ),
          ),
        );
      }
    } finally {
      // Restaurer l'état seulement si le widget est toujours monté
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// Extrait un message d'erreur convivial à partir de l'exception
  String _getErrorMessage(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('session expirée') ||
        errorString.contains('non authentifié')) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    } else if (errorString.contains('propriétaire de ce projet')) {
      return 'Vous n\'êtes pas le propriétaire de ce projet. Seul le propriétaire peut modifier le budget.';
    } else if (errorString.contains('accès refusé') ||
        errorString.contains('403') ||
        errorString.contains('permissions') ||
        errorString.contains('droits')) {
      return 'Vous n\'avez pas les permissions nécessaires pour modifier ce budget. Vérifiez que vous êtes bien le propriétaire de ce projet.';
    } else if (errorString.contains('connexion') ||
        errorString.contains('network') ||
        errorString.contains('timeout')) {
      return 'Problème de connexion. Vérifiez votre connexion internet et réessayez.';
    } else if (errorString.contains('serveur') || errorString.contains('500')) {
      return 'Erreur du serveur. Veuillez réessayer dans quelques instants.';
    } else if (errorString.contains('ressource non trouvée') ||
        errorString.contains('404') ||
        errorString.contains('budget non trouvé')) {
      return 'Ce budget n\'existe plus ou a été supprimé.';
    } else {
      return 'Erreur lors de la mise à jour du budget. Veuillez réessayer.';
    }
  }

  /// Gère la reconnexion de l'utilisateur
  void _handleReconnection(BuildContext context) {
    // Naviguer vers l'écran de connexion
    // Remplacez cette ligne par votre logique de navigation
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login', // Remplacez par votre route de connexion
      (route) => false,
    );
  }

  void _showAddExpenseDialog() {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Header with close button
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nouvelle dépense',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap:
                              isSubmitting
                                  ? null
                                  : () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: 28,
                            color: HexColor('#231F20'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Description field
                          Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HexColor('#333333'),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: HexColor('#CBD5E1')),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: descriptionController,
                              enabled: !isSubmitting,
                              decoration: InputDecoration(
                                hintText: 'Ex: Achat de matériaux',
                                hintStyle: TextStyle(
                                  color: HexColor('#6B7280'),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                          SizedBox(height: 16),

                          // Montant field
                          Text(
                            'Montant (FCFA)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: HexColor('#333333'),
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: HexColor('#CBD5E1')),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: TextField(
                              controller: amountController,
                              enabled: !isSubmitting,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                hintText: 'Ex: 50000',
                                hintStyle: TextStyle(
                                  color: HexColor('#6B7280'),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              style: TextStyle(fontSize: 16),
                            ),
                          ),

                          SizedBox(height: 24),

                          // Enregistrer button
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: 10),
                            child: ElevatedButton(
                              onPressed:
                                  isSubmitting
                                      ? null
                                      : () async {
                                        if (descriptionController.text
                                                .trim()
                                                .isNotEmpty &&
                                            amountController.text.isNotEmpty) {
                                          setModalState(() {
                                            isSubmitting = true;
                                          });

                                          try {
                                            if (budget != null) {
                                              await _budgetService.addExpense(
                                                budget!.id,
                                                double.parse(
                                                  amountController.text,
                                                ),
                                                descriptionController.text
                                                    .trim(),
                                              );

                                              await _loadBudgetData();

                                              Navigator.of(context).pop();
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Dépense ajoutée avec succès',
                                                  ),
                                                  backgroundColor: Color(
                                                    0xFF4CAF50,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              throw Exception(
                                                'Budget non disponible',
                                              );
                                            }
                                          } catch (e) {
                                            setModalState(() {
                                              isSubmitting = false;
                                            });

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Erreur: ${e.toString()}',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Veuillez remplir tous les champs',
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HexColor('#1A365D'),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child:
                                  isSubmitting
                                      ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                      : Text(
                                        'Enregistrer',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatAmount(double amount) {
    // Convertir en entier pour éviter les décimales
    int intAmount = amount.toInt();

    // Formater avec des espaces comme séparateurs de milliers
    String amountStr = intAmount.toString();
    String formatted = '';

    for (int i = 0; i < amountStr.length; i++) {
      if (i > 0 && (amountStr.length - i) % 3 == 0) {
        formatted += ' ';
      }
      formatted += amountStr[i];
    }

    return formatted;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
