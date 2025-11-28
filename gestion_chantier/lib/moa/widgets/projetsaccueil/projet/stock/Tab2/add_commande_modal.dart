import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/bloc/commades/commandes_bloc.dart';
import 'package:gestion_chantier/moa/bloc/commades/commandes_event.dart';
import 'package:gestion_chantier/moa/bloc/commades/commandes_state.dart';
import 'package:gestion_chantier/moa/models/MaterialModel.dart';
import 'package:gestion_chantier/moa/models/WorkerModel.dart';
import 'package:gestion_chantier/moa/services/Materiaux_service.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/stock/Tab2/add_material_modal.dart';

void showAjouterCommandeModal(BuildContext context, RealEstateModel projet) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => BlocProvider.value(
          value: BlocProvider.of<CommandeBloc>(context),
          child: AjouterCommandeModalContent(projet: projet),
        ),
  );
}

class AjouterCommandeModalContent extends StatefulWidget {
  final RealEstateModel projet;
  const AjouterCommandeModalContent({Key? key, required this.projet})
    : super(key: key);

  @override
  State<AjouterCommandeModalContent> createState() =>
      _AjouterCommandeModalContentState();
}

class AddedMaterial {
  final MaterialModel material;
  final int unitPrice;
  final int quantity;
  AddedMaterial({
    required this.material,
    required this.unitPrice,
    required this.quantity,
  });
  int get total => unitPrice * quantity;
}

class _AjouterCommandeModalContentState
    extends State<AjouterCommandeModalContent> {
  int? selectedSupplierId;
  DateTime? selectedDate;
  List<AddedMaterial> materials = [];
  double total = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<WorkerModel> fournisseurs = [];
  List<MaterialModel> materialsFromApi = [];
  bool _isLoadingMaterials = true;
  String? currentUserNom;
  String? currentUserPrenom;

  @override
  void initState() {
    super.initState();
    _initCurrentUser();
    _loadMaterials();
  }

  Future<void> _initCurrentUser() async {
    try {
      final user = await AuthService().connectedUser();
      if (user != null && mounted) {
        setState(() {
          selectedSupplierId = user['id'] ?? user['promoterId'];
          currentUserNom = user['nom']?.toString();
          currentUserPrenom = user['prenom']?.toString();
        });
        print(
          '[DEBUG] Utilisateur connecté: id=${user['id']}, nom=${user['nom']}, prenom=${user['prenom']}, role=${user['profil'] ?? user['role']}',
        );
      }
    } catch (e) {
      print('[DEBUG] Impossible de charger le current user : $e');
    }
  }

  Future<void> _loadMaterials() async {
    try {
      final mats = await MaterialsApiService().getMaterialsByProperty(
        widget.projet.id,
      );
      if (mounted) {
        setState(() {
          materialsFromApi = mats;
          _isLoadingMaterials = false;
        });
      }
    } catch (e) {
      print('[DEBUG] Impossible de charger les matériaux : $e');
      setState(() => _isLoadingMaterials = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    total = materials.fold(0, (sum, m) => sum + m.total);
    return BlocListener<CommandeBloc, CommandeState>(
      listener: (context, state) {
        if (state is CommandeAdded) {
          setState(() => _isLoading = false);
          Navigator.of(
            context,
          ).pop(true); // ferme le modal et signale le succès
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Commande ajoutée avec succès !')),
          );
        } else if (state is CommandeAddError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is CommandeAdding) {
          setState(() => _isLoading = true);
        }
      },
      child: SingleChildScrollView(
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
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Nouvelle commande',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fournisseur',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          color: Colors.grey[100],
                        ),
                        child: Text(
                          (currentUserNom != null && currentUserPrenom != null)
                              ? '${currentUserNom!} ${currentUserPrenom!}'
                              : 'Utilisateur',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Date de livraison souhaitée',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 6),
                      GestureDetector(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (picked != null)
                            setState(() => selectedDate = picked);
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'jj/mm/aaaa',
                              suffixIcon: Icon(Icons.calendar_today_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            controller: TextEditingController(
                              text:
                                  selectedDate == null
                                      ? ''
                                      : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
                            ),
                            validator:
                                (val) =>
                                    selectedDate == null
                                        ? 'Champ obligatoire'
                                        : null,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Matériaux ajoutés',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF5C02).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${materials.length}',
                              style: TextStyle(
                                color: Color(0xFFFF5C02),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: [
                          for (int i = 0; i < materials.length; i++) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        materials[i].material.label,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${materials[i].quantity} ${materials[i].material.unit.label}',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            '${materials[i].unitPrice} FCFA * ${materials[i].quantity}',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    final materialId = materials[i].material.id;
                                    print(
                                      '[SUPPRESSION] ID du matériau envoyé à l\'API : $materialId',
                                    );
                                    setState(() => _isLoading = true);
                                    try {
                                      await MaterialsApiService()
                                          .deleteMaterial(materialId);
                                      setState(() {
                                        materials.removeAt(i);
                                        _isLoading = false;
                                      });
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Matériau supprimé avec succès',
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      setState(() => _isLoading = false);
                                      String errorMsg = e.toString();
                                      print('[SUPPRESSION][ERREUR] $errorMsg');
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Erreur lors de la suppression (ID: $materialId) :\n$errorMsg',
                                          ),
                                          backgroundColor: Colors.red,
                                          duration: Duration(seconds: 5),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                            if (i < materials.length - 1)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Divider(
                                  height: 1,
                                  color: Color(0xFFE5E7EB),
                                ),
                              ),
                          ],
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 10),
                        child: OutlinedButton.icon(
                          icon: Icon(Icons.add, color: Colors.orange),
                          label: Text(
                            'Ajouter un matériau',
                            style: TextStyle(color: Colors.orange),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.orange),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Colors.orange[50],
                          ),
                          onPressed:
                              _isLoadingMaterials
                                  ? null
                                  : () async {
                                    final result = await showAddMaterialModal(
                                      context,
                                      materialsFromApi,
                                      widget.projet.id,
                                    );
                                    if (result != null) {
                                      setState(() {
                                        materials.add(
                                          AddedMaterial(
                                            material: result['material'],
                                            unitPrice: result['unitPrice'],
                                            quantity: result['quantity'],
                                          ),
                                        );
                                      });
                                    }
                                  },
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${total.toStringAsFixed(0)} F CFA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              (_isLoading ||
                                      selectedSupplierId == null ||
                                      materials.isEmpty)
                                  ? () {
                                    if (_isLoading)
                                      print(
                                        '[DEBUG] Bouton désactivé : _isLoading=true',
                                      );
                                    if (selectedSupplierId == null)
                                      print(
                                        '[DEBUG] Bouton désactivé : selectedSupplierId=null',
                                      );
                                    if (materials.isEmpty)
                                      print(
                                        '[DEBUG] Bouton désactivé : materials.isEmpty',
                                      );
                                  }
                                  : () {
                                    print('[DEBUG] onPressed déclenché');
                                    if (!_formKey.currentState!.validate() ||
                                        selectedSupplierId == null ||
                                        materials.isEmpty) {
                                      print('[DEBUG] Validation échouée');
                                      return;
                                    }
                                    print(
                                      '[ENREGISTRER COMMANDE] supplierId: '
                                      'supplierId=${selectedSupplierId!},'
                                      '\n\tmaterials=${materials.map((m) => m.material.toJson()).toList()},'
                                      '\n\tpropertyId=${widget.projet.id},'
                                      '\n\tdeliveryDate=$selectedDate',
                                    );
                                    setState(() => _isLoading = true);
                                    BlocProvider.of<CommandeBloc>(context).add(
                                      AddOrderEvent(
                                        supplierId: selectedSupplierId!,
                                        materials:
                                            materials
                                                .map((m) => m.material)
                                                .toList(),
                                        propertyId: widget.projet.id,
                                        deliveryDate: selectedDate,
                                      ),
                                    );
                                  },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF183153),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: Color(0xFF183153),
                            disabledForegroundColor: Colors.white.withOpacity(
                              0.7,
                            ),
                          ),
                          child:
                              _isLoading
                                  ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                  : Text(
                                    'Enregistrer la commande',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
