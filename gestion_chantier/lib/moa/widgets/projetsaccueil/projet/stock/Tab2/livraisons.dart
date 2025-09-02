// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/bloc/delivery/delivery_bloc.dart';
import 'package:gestion_chantier/moa/bloc/delivery/delivery_event.dart';
import 'package:gestion_chantier/moa/bloc/delivery/delivery_state.dart';
import 'package:gestion_chantier/moa/models/DeliveryModel.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LivraisonsTab extends StatefulWidget {
  final RealEstateModel projet;

  const LivraisonsTab({super.key, required this.projet});
  @override
  _LivraisonsTabState createState() => _LivraisonsTabState();
}

class _LivraisonsTabState extends State<LivraisonsTab> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryBloc>().add(FetchDeliveries(widget.projet.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F9FA'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(left: 17, right: 17, top: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 20),
            BlocBuilder<DeliveryBloc, DeliveryState>(
              builder: (context, state) {
                if (state is DeliveryLoading) {
                  return _buildLoadingState();
                } else if (state is DeliveryLoaded) {
                  final livraisons = state.deliveries;
                  if (livraisons.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildLivraisonsList(livraisons);
                } else if (state is DeliveryError) {
                  return Center(child: Text('Erreur: ${state.message}'));
                }
                return SizedBox.shrink();
              },
            ),
            SizedBox(height: 32),
            // Tu peux ajouter ici une section mouvements si tu veux, mais sans dépendance à MouvementLivraison.
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Livraisons',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: HexColor('#333333'),
      ),
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
              'Chargement des livraisons...',
              style: TextStyle(fontSize: 16, color: HexColor('#6B7280')),
            ),
          ],
        ),
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
          SvgPicture.asset(
            'assets/icons/sack.svg',
            width: 48,
            height: 48,
            color: HexColor('#9CA3AF'),
          ),
          SizedBox(height: 16),
          Text(
            'Aucune livraison',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: HexColor('#1F2937'),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Aucune livraison trouvée pour ce projet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
          ),
        ],
      ),
    );
  }

  Widget _buildLivraisonsList(List<DeliveryModel> livraisons) {
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
            livraisons.asMap().entries.map((entry) {
              int index = entry.key;
              DeliveryModel livraison = entry.value;
              return Column(
                children: [
                  _buildLivraisonListTile(livraison),
                  if (index < livraisons.length - 1)
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

  Widget _buildLivraisonListTile(DeliveryModel livraison) {
    return _buildListTile(
      context,
      icon: SvgPicture.asset(
        'assets/icons/sack.svg',
        width: 20,
        height: 20,
        color: HexColor('#777777'),
      ),
      title: 'LIV-${livraison.id.toString().padLeft(6, '0')}',
      subtitle: livraison.supplier.nom ?? 'Fournisseur inconnu',
      statut: _mapStatusToEnum(livraison.status),
      hasSwitch: false,
      hasArrow: true,
      onTap: () {},
    );
  }

  StatutLivraisonCommande _mapStatusToEnum(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return StatutLivraisonCommande.livree;
      case 'IN_DELIVERY':
        return StatutLivraisonCommande.enLivraison;
      case 'PENDING':
        return StatutLivraisonCommande.enAttente;
      case 'APPROVED':
        return StatutLivraisonCommande.approuvee;
      case 'REJECTED':
        return StatutLivraisonCommande.refusee;
      default:
        return StatutLivraisonCommande.enAttente;
    }
  }

  Widget _buildListTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    String? subtitle,
    StatutLivraisonCommande? statut,
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
            SizedBox.shrink()
          else if (hasArrow)
            Icon(Icons.chevron_right, color: HexColor('#9CA3AF'), size: 24),
        ],
      ),
      onTap: hasSwitch ? () => onChanged!(!value!) : onTap,
    );
  }

  Widget _buildStatutChip(StatutLivraisonCommande statut) {
    Color couleurBackground;
    Color couleurTexte;
    String texte;

    switch (statut) {
      case StatutLivraisonCommande.livree:
        couleurBackground = HexColor('#D1FAE5');
        couleurTexte = HexColor('#059669');
        texte = 'Livrée';
        break;
      case StatutLivraisonCommande.enLivraison:
        couleurBackground = HexColor('#DBEAFE');
        couleurTexte = HexColor('#2563EB');
        texte = 'En livraison';
        break;
      case StatutLivraisonCommande.enAttente:
        couleurBackground = HexColor('#FEF3C7');
        couleurTexte = HexColor('#D97706');
        texte = 'En attente';
        break;
      case StatutLivraisonCommande.approuvee:
        couleurBackground = HexColor('#DBEAFE');
        couleurTexte = HexColor('#2563EB');
        texte = 'Approuvée';
        break;
      case StatutLivraisonCommande.refusee:
        couleurBackground = HexColor('#FEE2E2');
        couleurTexte = HexColor('#DC2626');
        texte = 'Refusée';
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
}

// Enum pour les statuts harmonisés avec commandes
enum StatutLivraisonCommande {
  livree,
  enLivraison,
  enAttente,
  approuvee,
  refusee,
}

// Classes de données
class Livraison {
  final String numero;
  final String fournisseur;
  final StatutLivraison statut;
  final IconData icone;
  final DateTime datePrevue;
  final DateTime? dateReelle;

  Livraison({
    required this.numero,
    required this.fournisseur,
    required this.statut,
    required this.icone,
    required this.datePrevue,
    this.dateReelle,
  });
}

class MouvementLivraison {
  final TypeMouvementLivraison type;
  final int quantite;
  final String materiau;
  final String chantier;
  final DateTime dateHeure;

  MouvementLivraison({
    required this.type,
    required this.quantite,
    required this.materiau,
    required this.chantier,
    required this.dateHeure,
  });
}

enum StatutLivraison { complete, partielle, enCours, annulee }

enum TypeMouvementLivraison { entree, sortie }

// Classes d'écrans à implémenter
class AjouterLivraisonScreen extends StatelessWidget {
  final RealEstateModel projet;

  const AjouterLivraisonScreen({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ajouter une livraison')),
      body: Center(child: Text('Écran d\'ajout de livraison à implémenter')),
    );
  }
}

class DetailsLivraisonScreen extends StatelessWidget {
  final Livraison livraison;
  final RealEstateModel projet;

  const DetailsLivraisonScreen({
    super.key,
    required this.livraison,
    required this.projet,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(livraison.numero)),
      body: Center(child: Text('Détails de la livraison à implémenter')),
    );
  }
}
