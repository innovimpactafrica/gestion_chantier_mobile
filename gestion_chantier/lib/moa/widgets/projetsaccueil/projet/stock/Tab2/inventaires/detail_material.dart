import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/services/Materiaux_service.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/inventaires/inventaires.dart';

// Remplacer Materiau, StatutMateriau par les imports réels si besoin

class DetailsMateriauScreen extends StatelessWidget {
  final Materiau materiau;
  final RealEstateModel projet;

  const DetailsMateriauScreen({
    super.key,
    required this.materiau,
    required this.projet,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(materiau.icone, size: 36, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      materiau.nom,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (materiau.statut == StatutMateriau.critique)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Critique',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (materiau.statut == StatutMateriau.avertissement)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Avertissement',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  if (materiau.statut == StatutMateriau.normal)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Normal',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Stock',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    '${materiau.quantiteActuelle} ${materiau.unite}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Seuil',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    '${materiau.seuil}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Fournisseur',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    'BétonPlus',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ), // à remplacer par la vraie valeur si dispo
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Date de création',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Text(
                    '22 mai 2025, 10:15',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ), // à remplacer par la vraie valeur si dispo
                ],
              ),
              SizedBox(height: 24),
              // Titre avec icône horloge
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[700], size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Mouvements récents',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ..._buildMouvementsRecents(context),
              SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {},
                        child: Text(
                          'Modifier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.orange, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        final shouldRefresh = await showModalBottomSheet<bool>(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder:
                              (ctx) => _MaterialOptionsSheet(
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: ctx,
                                    builder:
                                        (ctx2) => AlertDialog(
                                          title: Text(
                                            'Supprimer le matériau ?',
                                          ),
                                          content: Text(
                                            'Cette action est irréversible. Voulez-vous vraiment supprimer ce matériau ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx2,
                                                  ).pop(false),
                                              child: Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.of(
                                                    ctx2,
                                                  ).pop(true),
                                              child: Text(
                                                'Supprimer',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                  );
                                  if (confirm == true) {
                                    try {
                                      // Appel API suppression
                                      await MaterialsApiService()
                                          .deleteMaterial(materiau.id);
                                      Navigator.of(ctx).pop(
                                        true,
                                      ); // Ferme le bottom sheet et signale le refresh
                                    } catch (e) {
                                      Navigator.of(ctx).pop(false);
                                      String message =
                                          e.toString().contains('403')
                                              ? 'Suppression impossible : accès refusé (403). Vérifiez vos droits ou contactez un administrateur.'
                                              : 'Erreur lors de la suppression : $e';
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(message)),
                                      );
                                    }
                                  }
                                },
                              ),
                        );
                        if (shouldRefresh == true) {
                          Navigator.of(context).pop(
                            true,
                          ); // Ferme la fiche détail et signale le refresh à la liste
                        }
                      },
                      child: Icon(
                        Icons.more_horiz,
                        color: Colors.orange,
                        size: 28,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMouvementsRecents(BuildContext context) {
    // Exemple statique, à remplacer par la vraie liste de mouvements
    return [
      _buildMouvementCard(
        context,
        'Sortie',
        '10',
        'Moussa DIOP',
        "Aujourd'hui, 14:30",
        Colors.red,
      ),
      _buildMouvementCard(
        context,
        'Entrée',
        '15',
        'Moussa DIOP',
        "Aujourd'hui, 11:15",
        Colors.green,
      ),
    ];
  }

  Widget _buildMouvementCard(
    BuildContext context,
    String type,
    String quantite,
    String user,
    String date,
    Color badgeColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50], // Fond gris très clair
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne gauche : Badge type + Quantité
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge type (Sortie/Entrée)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(20), // Très arrondi
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              SizedBox(height: 8),
              // Quantité en gras
              Text(
                '$quantite sacs',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(width: 16),
          // Colonne droite : Utilisateur + Date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badge utilisateur
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                SizedBox(height: 6),
                // Date/heure
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialOptionsSheet extends StatelessWidget {
  final VoidCallback onDelete;
  const _MaterialOptionsSheet({Key? key, required this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.swap_horiz, color: Colors.grey[800]),
            title: Text('Gérer les mouvements'),
            onTap: () {
              Navigator.of(context).pop();
              // TODO: Naviguer vers la gestion des mouvements si besoin
            },
          ),
          Divider(height: 0),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Supprimer', style: TextStyle(color: Colors.red)),
            onTap: onDelete,
          ),
        ],
      ),
    );
  }
}
