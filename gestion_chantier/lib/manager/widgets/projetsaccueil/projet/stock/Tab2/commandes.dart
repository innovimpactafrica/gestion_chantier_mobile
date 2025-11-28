import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_bloc.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_event.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_state.dart';
import 'package:gestion_chantier/manager/models/CommandeModel.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/stock/Tab2/add_commande_modal.dart';

class CommandesTab extends StatefulWidget {
  final RealEstateModel projet;
  const CommandesTab({super.key, required this.projet});

  @override
  _CommandesTabState createState() => _CommandesTabState();
}

class CommandesTabWrapper extends StatelessWidget {
  final RealEstateModel projet;
  const CommandesTabWrapper({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommandeBloc(),
      child: CommandesTab(projet: projet),
    );
  }
}

class _CommandesTabState extends State<CommandesTab> {
  // List<MouvementCommande> mouvementsRecents = [];

  @override
  void initState() {
    super.initState();
    // Charger les commandes via le BLoC
    context.read<CommandeBloc>().add(
      GetPendingOrdersEvent(propertyId: widget.projet.id),
    );
    // _loadMouvementsRecents();
  }

  // void _loadMouvementsRecents() {
  //   setState(() {
  //     mouvementsRecents = [
  //       MouvementCommande(
  //         type: TypeMouvementCommande.sortie,
  //         quantite: 10,
  //         materiau: 'sacs de ciment',
  //         chantier: 'Chantier A',
  //         dateHeure: DateTime.now().subtract(Duration(hours: 2, minutes: 30)),
  //       ),
  //       MouvementCommande(
  //         type: TypeMouvementCommande.entree,
  //         quantite: 50,
  //         materiau: 'tuyaux PVC',
  //         chantier: 'Chantier A',
  //         dateHeure: DateTime.now().subtract(Duration(hours: 4, minutes: 45)),
  //       ),
  //     ];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F9FA'),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CommandeBloc>().add(
            RefreshOrdersEvent(propertyId: widget.projet.id),
          );
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: 17, right: 17, top: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20),
              _buildCommandesSection(),
              SizedBox(height: 32),
              // _buildMouvementsSection(),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/icons/plus.svg',
        onPressed: _ajouterCommande,
        label: '',
        backgroundColor: HexColor('#FF5C02'),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader() {
    return Text(
      'Commandes',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: HexColor('#333333'),
      ),
    );
  }

  Widget _buildCommandesSection() {
    return BlocBuilder<CommandeBloc, CommandeState>(
      builder: (context, state) {
        if (state is CommandeLoading) {
          return _buildLoadingState();
        } else if (state is CommandeError) {
          return _buildErrorState(state.message);
        } else if (state is CommandeEmpty) {
          return _buildEmptyState();
        } else if (state is CommandeLoaded) {
          return _buildCommandesList(state.commandes);
        } else if (state is CommandeAdded) {
          return _buildCommandesList(state.allCommandes);
        }

        return _buildEmptyState();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(HexColor('#FF5C02')),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement des commandes...',
              style: TextStyle(fontSize: 16, color: HexColor('#6B7280')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: EdgeInsets.all(16),
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
        children: [
          Icon(Icons.error_outline, size: 48, color: HexColor('#DC2626')),
          SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HexColor('#1F2937'),
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<CommandeBloc>().add(
                GetPendingOrdersEvent(propertyId: widget.projet.id),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#FF5C02'),
              foregroundColor: Colors.white,
            ),
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(24),
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
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 48,
            color: HexColor('#9CA3AF'),
          ),
          SizedBox(height: 16),
          Text(
            'Aucune commande',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HexColor('#1F2937'),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aucune commande en attente pour ce projet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandesList(List<CommandeModel> commandes) {
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
            commandes.asMap().entries.map((entry) {
              int index = entry.key;
              CommandeModel commande = entry.value;
              return Column(
                children: [
                  _buildCommandeListTile(commande),
                  if (index < commandes.length - 1)
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

  Widget _buildCommandeListTile(CommandeModel commande) {
    return _buildListTile(
      context,
      icon: SvgPicture.asset(
        'assets/icons/sack.svg',
        width: 22,
        height: 22,
        color: HexColor('#777777'),
      ),
      title: 'CMD-${commande.id.toString().padLeft(6, '0')}',
      subtitle: commande.supplier.nom,
      statut: _mapStatusToEnum(commande.status),
      hasSwitch: false,
      hasArrow: true,
      onTap: () => _ouvrirDetailsCommande(commande),
    );
  }

  StatutCommande _mapStatusToEnum(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return StatutCommande.livree;
      case 'IN_TRANSIT':
        return StatutCommande.enLivraison;
      case 'PENDING':
        return StatutCommande.enAttente;
      case 'CANCELLED':
        return StatutCommande.annulee;
      default:
        return StatutCommande.enAttente;
    }
  }

  Widget _buildListTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    StatutCommande? statut,
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (statut != null) ...[
            _buildStatutChip(statut),
            SizedBox(width: 12),
          ],
          if (hasSwitch)
            _buildCustomSwitch(
              context,
              value: value ?? false,
              onChanged: onChanged!,
            )
          else if (hasArrow)
            Icon(Icons.chevron_right, color: HexColor('#9CA3AF'), size: 24),
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

  Widget _buildStatutChip(StatutCommande statut) {
    Color couleurBackground;
    Color couleurTexte;
    String texte;

    switch (statut) {
      case StatutCommande.livree:
        couleurBackground = HexColor('#D1FAE5');
        couleurTexte = HexColor('#059669');
        texte = 'Livrée';
        break;
      case StatutCommande.enLivraison:
        couleurBackground = HexColor('#DBEAFE');
        couleurTexte = HexColor('#2563EB');
        texte = 'En livraison';
        break;
      case StatutCommande.enAttente:
        couleurBackground = HexColor('#FEF3C7');
        couleurTexte = HexColor('#D97706');
        texte = 'En attente';
        break;
      case StatutCommande.annulee:
        couleurBackground = HexColor('#FEE2E2');
        couleurTexte = HexColor('#DC2626');
        texte = 'Annulée';
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

  void _ajouterCommande() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BlocProvider.value(
            value: BlocProvider.of<CommandeBloc>(context),
            child: AjouterCommandeModalContent(projet: widget.projet),
          ),
    );
    if (result == true) {
      context.read<CommandeBloc>().add(
        RefreshOrdersEvent(propertyId: widget.projet.id),
      );
    }
  }

  void _ouvrirDetailsCommande(CommandeModel commande) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _CommandeDetailModal(commande: commande);
      },
    );
  }
}

// Classes de données conservées
class MouvementCommande {
  final TypeMouvementCommande type;
  final int quantite;
  final String materiau;
  final String chantier;
  final DateTime dateHeure;

  MouvementCommande({
    required this.type,
    required this.quantite,
    required this.materiau,
    required this.chantier,
    required this.dateHeure,
  });
}

enum StatutCommande { livree, enLivraison, enAttente, annulee }

enum TypeMouvementCommande { entree, sortie }

// Classes d'écrans à implémenter
class DetailsCommandeScreen extends StatelessWidget {
  final CommandeModel commande;
  final RealEstateModel projet;

  const DetailsCommandeScreen({
    super.key,
    required this.commande,
    required this.projet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CMD-${commande.id.toString().padLeft(6, '0')}'),
      ),
      body: Center(child: Text('Détails de la commande à implémenter')),
    );
  }
}

class _CommandeDetailModal extends StatelessWidget {
  final CommandeModel commande;
  final Map<int, String>? materialsMap; // facultatif pour mapping id->label
  const _CommandeDetailModal({required this.commande, this.materialsMap});

  String _formatDate(DateTime date) {
    // Utilise intl si dispo, sinon format simple
    return '${date.day.toString().padLeft(2, '0')} ${_moisFr(date.month)} ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _moisFr(int m) {
    const mois = [
      '',
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];
    return (m >= 1 && m <= 12) ? mois[m] : '';
  }

  int get total => commande.items.fold(
    0,
    (sum, item) => sum + item.quantity * item.unitPrice,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 20,
        right: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SvgPicture.asset(
                    'assets/icons/sack.svg',
                    width: 32,
                    height: 32,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'CMD-${commande.id.toString().padLeft(6, '0')}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 12),
                          _buildStatutChip(_mapStatusToEnum(commande.status)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fournisseur',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                Text(
                  commande.supplier.nom,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date de commande',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                Text(
                  _formatDate(commande.orderDate),
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
                Text(
                  '${total.toString()} Fcfa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                ),
              ],
            ),
            SizedBox(height: 22),
            Row(
              children: [
                Icon(Icons.history, size: 20, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text(
                  'Articles',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
                ),
              ],
            ),
            SizedBox(height: 10),
            ...commande.items.map(
              (article) => Container(
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.materialLabel ??
                          'Matériau #${article.materialId}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${article.quantity} unités',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${article.unitPrice} FCFA * ${article.quantity}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HexColor('#FF5C02'),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Modifier',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: HexColor('#FF5C02'), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.more_horiz, color: HexColor('#FF5C02')),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  StatutCommande _mapStatusToEnum(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return StatutCommande.livree;
      case 'IN_TRANSIT':
        return StatutCommande.enLivraison;
      case 'PENDING':
        return StatutCommande.enAttente;
      case 'CANCELLED':
        return StatutCommande.annulee;
      default:
        return StatutCommande.enAttente;
    }
  }

  Widget _buildStatutChip(StatutCommande statut) {
    String label;
    Color color;
    switch (statut) {
      case StatutCommande.livree:
        label = 'Livrée';
        color = Colors.green.shade200;
        break;
      case StatutCommande.enLivraison:
        label = 'En livraison';
        color = Colors.orange.shade200;
        break;
      case StatutCommande.enAttente:
        label = 'En attente';
        color = Colors.grey.shade300;
        break;
      case StatutCommande.annulee:
        label = 'Annulée';
        color = Colors.red.shade200;
        break;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
