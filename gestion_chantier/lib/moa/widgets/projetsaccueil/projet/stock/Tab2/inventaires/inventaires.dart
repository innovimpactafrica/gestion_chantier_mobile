// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/models/MaterialModel.dart';
import 'package:gestion_chantier/moa/services/Materiaux_service.dart';
import 'package:gestion_chantier/moa/services/MovementsApiService.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/CustomFloatingButton.dart';
import 'package:intl/intl.dart';
import 'ajout_material.dart';
import 'detail_material.dart';

class InventairesTab extends StatefulWidget {
  final RealEstateModel projet;
  const InventairesTab({super.key, required this.projet});
  @override
  _InventairesTabState createState() => _InventairesTabState();
}

class _InventairesTabState extends State<InventairesTab> {
  List<Materiau> materiaux = [];
  List<Mouvement> mouvementsRecents = [];
  final MaterialsApiService _materialsApiService = MaterialsApiService();
  final MovementsApiService _movementsApiService = MovementsApiService();
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Future.wait([_loadMateriaux(), _loadMouvementsRecents()]);
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des données: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMateriaux() async {
    try {
      // Ligne de debug à ajouter temporairement
      await _materialsApiService.debugApiResponse(widget.projet.id);

      final List<MaterialModel> materialsFromApi = await _materialsApiService
          .getMaterialsByProperty(widget.projet.id);

      setState(() {
        materiaux =
            materialsFromApi.map((material) => material.toMateriau()).toList();
      });
    } catch (e) {
      print('Erreur lors du chargement des matériaux: $e');
      setState(() {
        materiaux = [];
      });
      rethrow;
    }
  }

  Future<void> _loadMouvementsRecents() async {
    try {
      // Debug de l'API des mouvements
      await _movementsApiService.debugMovementsApiResponse(widget.projet.id);

      final List<MovementModel> movementsFromApi = await _movementsApiService
          .getMovementsByProperty(widget.projet.id);

      setState(() {
        // Convertir les MovementModel en Mouvement et trier par date (plus récent en premier)
        mouvementsRecents =
            movementsFromApi.map((movement) => movement.toMouvement()).toList()
              ..sort((a, b) => b.dateHeure.compareTo(a.dateHeure));

        // Limiter à 10 mouvements récents maximum
        if (mouvementsRecents.length > 10) {
          mouvementsRecents = mouvementsRecents.take(10).toList();
        }
      });

      print('${mouvementsRecents.length} mouvements récents chargés');
    } catch (e) {
      print('Erreur lors du chargement des mouvements récents');
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F9FA'),
      body:
          _isLoading
              ? _buildLoadingWidget()
              : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                onRefresh: _refreshData,
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(left: 17, right: 17, top: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 20),
                      _buildInventaireSection(),
                      SizedBox(height: 32),
                      _buildMouvementsSection(),
                      SizedBox(height: 100), // Espace pour le FAB
                    ],
                  ),
                ),
              ),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/icons/plus.svg',
        onPressed: _ajouterMateriau,
        label: '',
        backgroundColor: HexColor('#FF5C02'),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(HexColor('#FF5C02')),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement des données...',
            style: TextStyle(fontSize: 16, color: HexColor('#6B7280')),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: HexColor('#DC2626')),
            SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: HexColor('#DC2626'),
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Une erreur inattendue s\'est produite',
              style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#FF5C02'),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Inventaire des matériaux',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: HexColor('#333333'),
          ),
        ),
      ],
    );
  }

  Widget _buildInventaireSection() {
    if (materiaux.isEmpty) {
      return _buildEmptyInventaireWidget();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children:
            materiaux.asMap().entries.map((entry) {
              int index = entry.key;
              Materiau materiau = entry.value;
              return Column(
                children: [
                  _buildMateriauListTile(materiau),
                  if (index < materiaux.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: HexColor('#F3F4F6'),
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget _buildEmptyInventaireWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: HexColor('#9CA3AF'),
          ),
          SizedBox(height: 16),
          Text(
            'Aucun matériau trouvé',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HexColor('#374151'),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Commencez par ajouter vos premiers matériaux',
            style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _ajouterMateriau,
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#FF5C02'),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Ajouter un matériau'),
          ),
        ],
      ),
    );
  }

  Widget _buildMateriauListTile(Materiau materiau) {
    return _buildListTile(
      context,
      icon: Icon(materiau.icone, color: HexColor('#777777'), size: 20),
      title: materiau.nom,
      subtitle:
          '${materiau.quantiteActuelle} ${materiau.unite} / seuil: ${materiau.seuil} ${materiau.unite}',
      statut: materiau.statut,
      hasSwitch: false,
      hasArrow: true,
      onTap: () => _ouvrirDetailsMateriau(materiau),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    StatutMateriau? statut,
    bool hasSwitch = true,
    bool? value,
    ValueChanged<bool>? onChanged,
    bool hasArrow = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: HexColor('#777777').withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: icon,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HexColor('#1F2937'),
        ),
      ),
      subtitle:
          subtitle != null
              ? Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: HexColor('#6B7280'),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
              : null,
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasSwitch)
            _buildCustomSwitch(
              context,
              value: value ?? false,
              onChanged: onChanged!,
            )
          else if (hasArrow)
            Icon(Icons.chevron_right, color: HexColor('#9CA3AF'), size: 24),
          SizedBox(width: 12),
          if (statut != null) ...[
            _buildStatutChip(statut),
            SizedBox(width: 12),
          ],
        ],
      ),
      onTap: hasSwitch ? () => onChanged!(!value!) : onTap,
    );
  }

  Widget _buildCustomSwitch(
    BuildContext context, {
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          trackColor: WidgetStateProperty.resolveWith((states) {
            return states.contains(WidgetState.selected)
                ? HexColor('#FF5C02')
                : HexColor('#D0D5DD');
          }),
          thumbColor: WidgetStateProperty.all(Colors.white),
          thumbIcon: WidgetStateProperty.all(null),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          splashRadius: 0,
        ),
      ),
      child: Transform.scale(
        scale: 0.7,
        child: Switch(value: value, onChanged: onChanged),
      ),
    );
  }

  Widget _buildStatutChip(StatutMateriau statut) {
    Color couleurBackground;
    Color couleurTexte;
    String texte;

    switch (statut) {
      case StatutMateriau.critique:
        couleurBackground = HexColor('#FEE2E2');
        couleurTexte = HexColor('#DC2626');
        texte = 'Critique';
        break;
      case StatutMateriau.avertissement:
        couleurBackground = HexColor('#FEF3C7');
        couleurTexte = HexColor('#D97706');
        texte = 'Avertissement';
        break;
      case StatutMateriau.normal:
        couleurBackground = HexColor('#D1FAE5');
        couleurTexte = HexColor('#059669');
        texte = 'Normal';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: couleurBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: couleurTexte,
        ),
      ),
    );
  }

  Widget _buildMouvementsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mouvements récents',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: HexColor('#2C3E50'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 107,
          child:
              mouvementsRecents.isEmpty
                  ? _buildEmptyMouvementsWidget()
                  : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: mouvementsRecents.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: 250,
                        child: _buildMouvementCard(mouvementsRecents[index]),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyMouvementsWidget() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timeline_outlined, size: 32, color: HexColor('#9CA3AF')),
            SizedBox(height: 8),
            Text(
              'Aucun mouvement récent',
              style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMouvementCard(Mouvement mouvement) {
    bool estSortie = mouvement.type == TypeMouvement.sortie;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      estSortie
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  estSortie ? 'Sortie' : 'Entrée',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  mouvement.chantier,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${mouvement.quantite} ${mouvement.materiau}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Text(
            _formatDateTime(mouvement.dateHeure),
            style: TextStyle(
              fontSize: 14,
              color: HexColor('#625F68'),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return "Aujourd'hui, ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } else {
      return "Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}";
    }
  }

  void _ajouterMateriau() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AjouterMateriauScreen(projet: widget.projet),
          ),
    ).then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }

  void _ouvrirDetailsMateriau(Materiau materiau) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: DetailsMateriauScreen(
              materiau: materiau,
              projet: widget.projet,
            ),
          ),
    ).then((result) {
      if (result == true) {
        _refreshData();
      }
    });
  }
}

// Classes de données
class Materiau {
  final int id;
  final String nom;
  final int quantiteActuelle;
  final int seuil;
  final String unite;
  final IconData icone;
  final StatutMateriau statut;

  Materiau({
    required this.id,
    required this.nom,
    required this.quantiteActuelle,
    required this.seuil,
    required this.unite,
    required this.icone,
    required this.statut,
  });
}

class Mouvement {
  final TypeMouvement type;
  final int quantite;
  final String materiau;
  final String unite;
  final String chantier;
  final DateTime dateHeure;

  Mouvement({
    required this.type,
    required this.quantite,
    required this.materiau,
    required this.unite,
    required this.chantier,
    required this.dateHeure,
  });
}

enum StatutMateriau { critique, avertissement, normal }

enum TypeMouvement { entree, sortie }

class HistoriqueMouvementsScreen extends StatelessWidget {
  final RealEstateModel projet;
  final List<Mouvement> mouvements;

  const HistoriqueMouvementsScreen({
    super.key,
    required this.projet,
    required this.mouvements,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique des mouvements'),
        backgroundColor: HexColor('#FF5C02'),
        foregroundColor: Colors.white,
      ),
      body:
          mouvements.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.timeline_outlined,
                      size: 64,
                      color: HexColor('#9CA3AF'),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucun mouvement enregistré',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: HexColor('#374151'),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.all(16),
                itemCount: mouvements.length,
                separatorBuilder: (context, index) => SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final mouvement = mouvements[index];
                  final estSortie = mouvement.type == TypeMouvement.sortie;

                  return Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          spreadRadius: 0,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 60,
                          decoration: BoxDecoration(
                            color:
                                estSortie
                                    ? Color(0xFFDC2626)
                                    : Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          estSortie
                                              ? Color(
                                                0xFFDC2626,
                                              ).withOpacity(0.1)
                                              : Color(
                                                0xFF10B981,
                                              ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      estSortie ? 'Sortie' : 'Entrée',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            estSortie
                                                ? Color(0xFFDC2626)
                                                : Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    mouvement.chantier,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${mouvement.quantite} ${mouvement.materiau}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _formatFullDateTime(
                                  mouvement.dateHeure as List<int>,
                                ),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }

  String _formatFullDateTime(List<int> dateTimeComponents) {
    if (dateTimeComponents.length < 6) {
      return 'Date invalide';
    }

    final date = DateTime(
      dateTimeComponents[0], // year
      dateTimeComponents[1], // month
      dateTimeComponents[2], // day
      dateTimeComponents[3], // hour
      dateTimeComponents[4], // minute
      dateTimeComponents[5], // second
    );

    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Alternative version if you're using a DateTime object directly
  // String _formatFullDateTime(DateTime dateTime) {
  //   return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  // }
}
