import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/stock/Tab2/inventaires/inventaires.dart';
import 'package:intl/intl.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementBloc.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementEvent.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementState.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/repository/MaterialMovementRepository.dart';
import 'package:gestion_chantier/moa/models/MaterialModel.dart';

class DetailsMateriauScreen extends StatefulWidget {
  final Materiau materiau;
  final RealEstateModel projet;

  const DetailsMateriauScreen({
    super.key,
    required this.materiau,
    required this.projet,
  });

  @override
  State<DetailsMateriauScreen> createState() => _DetailsMateriauScreenState();
}

class _DetailsMateriauScreenState extends State<DetailsMateriauScreen> {
  late final ScrollController _scrollController;
  late final MaterialMovementBloc _movementBloc;

  @override
  void initState() {
    super.initState();
    _movementBloc = MaterialMovementBloc(
      repository: MaterialMovementRepository(),
    )..add(LoadMaterialMovements(materialId: widget.materiau.id, reset: true));
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _movementBloc.close();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _movementBloc.add(LoadMaterialMovements(materialId: widget.materiau.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _movementBloc,
      child: BlocListener<MaterialMovementBloc, MaterialMovementState>(
        listener: (context, state) {
          if (state is MaterialMovementError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is MaterialMovementActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.deepOrange,
            child: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _openAddMovementSheet(context),
          ),
          body: BlocBuilder<MaterialMovementBloc, MaterialMovementState>(
            builder: (context, state) {
              // Afficher un loader seulement pour le chargement initial
              if (state is MaterialMovementLoading && state.isInitialLoad) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: _buildContent(context),
                  ),

                  // Afficher un loader transparent pour les actions
                  if (state is MaterialMovementLoading && !state.isInitialLoad)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openAddMovementSheet(BuildContext context) {
    final quantityController = TextEditingController();
    final commentController = TextEditingController();
    MovementType selectedType = MovementType.ENTRY;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return BlocProvider.value(
          value: _movementBloc,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: BlocBuilder<MaterialMovementBloc, MaterialMovementState>(
              builder: (context, state) {
                final isLoading =
                    state is MaterialMovementLoading && !state.isInitialLoad;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ajouter un mouvement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// TYPE
                    DropdownButtonFormField<MovementType>(
                      value: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Type de mouvement',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: MovementType.ENTRY,
                          child: Text('Entrée'),
                        ),
                        DropdownMenuItem(
                          value: MovementType.EXIT,
                          child: Text('Sortie'),
                        ),
                      ],
                      onChanged:
                          isLoading
                              ? null
                              : (value) {
                                if (value != null) selectedType = value;
                              },
                    ),

                    const SizedBox(height: 12),

                    /// QUANTITÉ
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Quantité',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// COMMENTAIRE
                    TextField(
                      controller: commentController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Commentaire (optionnel)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// BOUTON AVEC LOADER
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            isLoading
                                ? null
                                : () {
                                  final quantity = double.tryParse(
                                    quantityController.text,
                                  );

                                  if (quantity == null || quantity <= 0) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Quantité invalide'),
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<MaterialMovementBloc>().add(
                                    AddMaterialMovement(
                                      materialId: widget.materiau.id,
                                      quantity: quantity,
                                      type: selectedType,
                                      comment:
                                          commentController.text.isEmpty
                                              ? null
                                              : commentController.text,
                                    ),
                                  );

                                  // Fermer le modal immédiatement
                                  Navigator.pop(ctx);
                                },
                        child:
                            isLoading
                                ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  'Ajouter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final materiau = widget.materiau;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(materiau),
            const SizedBox(height: 24),
            _buildInfoRow(
              'Stock',
              '${materiau.quantiteActuelle} ${materiau.unite}',
            ),
            _buildInfoRow('Seuil', materiau.seuil.toString()),
            const SizedBox(height: 24),
            _buildMovementTitle(),
            const SizedBox(height: 16),
            _buildMouvementsRecents(),
          ],
        ),
      ),
    );
  }

  Widget _buildMouvementsRecents() {
    return BlocBuilder<MaterialMovementBloc, MaterialMovementState>(
      builder: (context, state) {
        List<MaterialMovementModel> mouvements = [];

        // 🔹 Liste actuelle selon l'état
        if (state is MaterialMovementLoaded) {
          mouvements = state.movements;
        } else if (state is MaterialMovementLoading &&
            state.previousMovements != null) {
          mouvements = state.previousMovements!;
        }

        // 🔹 Si la liste est vide
        if (mouvements.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Aucun mouvement enregistré',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            ...mouvements.map((m) => _buildMouvementCard(context, m)),

            // 🔹 Loader pour le scroll infini
            if (state is MaterialMovementLoading && !state.isInitialLoad)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildMouvementCard(
    BuildContext context,
    MaterialMovementModel movement,
  ) {
    final isEntry = movement.type.name == 'ENTRY';

    return Dismissible(
      key: ValueKey(movement.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Supprimer le mouvement ?'),
                content: const Text('Cette action est irréversible.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        );
      },
      onDismissed: (_) {
        // Notifie le bloc après coup pour la persistance
        context.read<MaterialMovementBloc>().add(
          DeleteMaterialMovement(movement.id,widget.materiau.id),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isEntry ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEntry ? 'Entrée' : 'Sortie',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${movement.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (movement.comment != null && movement.comment!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      movement.comment!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(movement.movementDate),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Materiau materiau) {
    return Row(
      children: [
        Expanded(
          child: Text(
            materiau.nom,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(color: Colors.grey[700])),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMovementTitle() {
    return Row(
      children: [
        Icon(Icons.access_time, color: Colors.grey[700]),
        const SizedBox(width: 8),
        const Text(
          'Mouvements récents',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
