import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementBloc.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementEvent.dart';
import 'package:gestion_chantier/manager/bloc/movment/MaterialMovementState.dart';
import 'package:gestion_chantier/manager/models/MaterialModel.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/repository/MaterialMovementRepository.dart';
import 'package:gestion_chantier/manager/services/Materiaux_service.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/stock/Tab2/inventaires/inventaires.dart';
import 'package:intl/intl.dart';

class DetailsMateriauSheet extends StatefulWidget {
  final Materiau materiau;
  final MaterialModel? materialModel;
  final RealEstateModel projet;
  final ScrollController scrollController;
  final VoidCallback? onRefresh;

  const DetailsMateriauSheet({
    super.key,
    required this.materiau,
    required this.materialModel,
    required this.projet,
    required this.scrollController,
    this.onRefresh,
  });

  @override
  State<DetailsMateriauSheet> createState() => _DetailsMateriauSheetState();
}

class _DetailsMateriauSheetState extends State<DetailsMateriauSheet> {
  late final MaterialMovementBloc _movementBloc;

  @override
  void initState() {
    super.initState();
    _movementBloc = MaterialMovementBloc(
      repository: MaterialMovementRepository(),
    )..add(LoadMaterialMovements(materialId: widget.materiau.id, reset: true));
  }

  @override
  void dispose() {
    _movementBloc.close();
    super.dispose();
  }

  String _formatCreatedAt(List<int> createdAt) {
    if (createdAt.length < 5) return '—';
    final dt = DateTime(
      createdAt[0],
      createdAt[1],
      createdAt[2],
      createdAt[3],
      createdAt[4],
    );
    return DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(dt);
  }

  String _formatMovementDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final movDay = DateTime(dt.year, dt.month, dt.day);
    final time = DateFormat('HH:mm').format(dt);
    if (movDay == today) return "Aujourd'hui, $time";
    if (movDay == today.subtract(const Duration(days: 1))) return "Hier, $time";
    return DateFormat('d MMM, HH:mm', 'fr_FR').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final orange = HexColor('#FF5C02');
    final materiau = widget.materiau;

    return BlocProvider.value(
      value: _movementBloc,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // ── Contenu scrollable ───────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header : icône + nom + badge statut ──────────
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: materiau.iconColor.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            materiau.icon,
                            size: 26,
                            color: materiau.iconColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            materiau.nom,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatutBadge(materiau.statut),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 16),

                    // ── Infos ─────────────────────────────────────────
                    _infoRow(
                      'Stock',
                      '${materiau.quantiteActuelle} ${materiau.unite}',
                      bold: true,
                    ),
                    _infoRow('Seuil', '${materiau.seuil}'),
                    if (widget.materialModel != null) ...[
                      _infoRow(
                        'Date de création',
                        _formatCreatedAt(widget.materialModel!.createdAt),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // ── Mouvements récents ────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.history, color: Colors.grey[700], size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Mouvements récents',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    BlocBuilder<MaterialMovementBloc, MaterialMovementState>(
                      builder: (context, state) {
                        List<MaterialMovementModel> movements = [];
                        if (state is MaterialMovementLoaded) {
                          movements = state.movements;
                        } else if (state is MaterialMovementLoading &&
                            state.previousMovements != null) {
                          movements = state.previousMovements!;
                        }

                        if (state is MaterialMovementLoading &&
                            state.isInitialLoad) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (movements.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Aucun mouvement enregistré',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          );
                        }

                        return Column(
                          children: movements
                              .map((m) => _buildMovementCard(m))
                              .toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Boutons bas ──────────────────────────────────────────
            Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () => _openEditSheet(context),
                        child: const Text(
                          'Modifier',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    width: 52,
                    child: Builder(
                      builder: (btnContext) => OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: orange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () => _showMoreOptions(btnContext),
                        child: Icon(Icons.more_horiz, color: orange),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatutBadge(StatutMateriau statut) {
    Color bg;
    Color fg;
    String label;
    switch (statut) {
      case StatutMateriau.critique:
        bg = const Color(0xFFFFE4E4);
        fg = const Color(0xFFDC2626);
        label = 'Critique';
        break;
      case StatutMateriau.avertissement:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        label = 'Avertissement';
        break;
      case StatutMateriau.normal:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        label = 'Normal';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  Widget _buildMovementCard(MaterialMovementModel movement) {
    final isEntry = movement.type == MovementType.ENTRY;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isEntry
                      ? const Color(0xFF10B981)
                      : const Color(0xFFDC2626),
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
              Text(
                movement.material.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${movement.quantity.toInt()} ${movement.material.unit.code} de ${movement.material.label.toLowerCase()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                _formatMovementDate(movement.movementDate),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditMateriauSheet(
        materialModel: widget.materialModel,
        materiau: widget.materiau,
        onUpdated: widget.onRefresh,
      ),
    );
  }

  void _showMoreOptions(BuildContext btnContext) {
    final RenderBox button = btnContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(btnContext).overlay!.context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: overlay);
    final RelativeRect position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy - 110,
      overlay.size.width - offset.dx - button.size.width,
      overlay.size.height - offset.dy,
    );

    showMenu<String>(
      context: btnContext,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem<String>(
          value: 'movements',
          child: Row(
            children: const [
              Icon(Icons.swap_horiz, color: Colors.grey, size: 20),
              SizedBox(width: 12),
              Text(
                'Gérer les mouvements',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: const [
              Icon(Icons.close, color: Colors.red, size: 20),
              SizedBox(width: 12),
              Text(
                'Supprimer',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'movements') _openAddMovementSheet(btnContext);
      if (value == 'delete') _confirmDelete(btnContext);
    });
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer le matériau ?'),
        content: Text(
          'Voulez-vous vraiment supprimer "${widget.materiau.nom}" ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // ferme la dialog
              try {
                await MaterialsApiService()
                    .deleteMaterial(widget.materiau.id);
                if (mounted) {
                  Navigator.pop(context); // ferme le sheet détail
                  widget.onRefresh?.call();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddMovementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider.value(
        value: _movementBloc,
        child: _AddMovementSheet(
          materiau: widget.materiau,
          movementBloc: _movementBloc,
        ),
      ),
    );
  }
}

// ── Sheet "Gérer les mouvements" ─────────────────────────────────────────────
class _AddMovementSheet extends StatefulWidget {
  final Materiau materiau;
  final MaterialMovementBloc movementBloc;

  const _AddMovementSheet({
    required this.materiau,
    required this.movementBloc,
  });

  @override
  State<_AddMovementSheet> createState() => _AddMovementSheetState();
}

class _AddMovementSheetState extends State<_AddMovementSheet> {
  MovementType? _selectedType;
  double _quantity = 0;
  final double _maxQuantity = 500;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Titre + X
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Mouvement',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Type de mouvement
          const Text(
            'Type de mouvement',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          _radioOption(MovementType.ENTRY, 'Entrée'),
          _radioOption(MovementType.EXIT, 'Sortie'),
          _radioOption(null, 'Ajustement'), // valeur null = ADJUSTMENT
          const SizedBox(height: 24),

          // Quantité actuelle
          const Text(
            'Quantité actuelle',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
              thumbColor: Colors.grey[500],
              overlayColor: Colors.grey.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _quantity,
              min: 0,
              max: _maxQuantity,
              onChanged: (v) => setState(() => _quantity = v),
            ),
          ),
          Text(
            _quantity.toInt().toString(),
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 28),

          // Bouton Enregistrer
          BlocBuilder<MaterialMovementBloc, MaterialMovementState>(
            bloc: widget.movementBloc,
            builder: (context, state) {
              final isLoading =
                  state is MaterialMovementLoading && !state.isInitialLoad;
              return SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A365D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _radioOption(MovementType? type, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Radio<MovementType?>(
              value: type,
              groupValue: _selectedType,
              onChanged: (v) => setState(() => _selectedType = v),
              activeColor: const Color(0xFF1A365D),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (_selectedType == null && _quantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un type et une quantité')),
      );
      return;
    }
    final type = _selectedType ?? MovementType.ENTRY;
    widget.movementBloc.add(
      AddMaterialMovement(
        materialId: widget.materiau.id,
        quantity: _quantity,
        type: type,
      ),
    );
    Navigator.pop(context);
  }
}

// ── Sheet "Modifier le matériau" ─────────────────────────────────────────────
class _EditMateriauSheet extends StatefulWidget {
  final MaterialModel? materialModel;
  final Materiau materiau;
  final VoidCallback? onUpdated;

  const _EditMateriauSheet({
    required this.materialModel,
    required this.materiau,
    this.onUpdated,
  });

  @override
  State<_EditMateriauSheet> createState() => _EditMateriauSheetState();
}

class _EditMateriauSheetState extends State<_EditMateriauSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelController;
  late final TextEditingController _quantityController;
  late final TextEditingController _thresholdController;

  Unit? _selectedUnit;
  List<Unit> _units = [];
  bool _isLoading = false;
  bool _isLoadingUnits = true;

  @override
  void initState() {
    super.initState();
    _labelController =
        TextEditingController(text: widget.materiau.nom);
    _quantityController =
        TextEditingController(text: widget.materiau.quantiteActuelle.toString());
    _thresholdController =
        TextEditingController(text: widget.materiau.seuil.toString());
    _loadUnits();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _quantityController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    try {
      final units = await MaterialsApiService().getUnits();
      setState(() {
        _units = units;
        // Pré-sélectionner l'unité actuelle
        if (widget.materialModel != null) {
          _selectedUnit = units.firstWhere(
            (u) => u.id == widget.materialModel!.unit.id,
            orElse: () => units.first,
          );
        } else if (units.isNotEmpty) {
          _selectedUnit = units.first;
        }
        _isLoadingUnits = false;
      });
    } catch (_) {
      setState(() => _isLoadingUnits = false);
    }
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une unité')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final updated = MaterialModel(
        id: widget.materiau.id,
        label: _labelController.text.trim(),
        quantity: int.parse(_quantityController.text),
        criticalThreshold: int.parse(_thresholdController.text),
        createdAt: widget.materialModel?.createdAt ?? [],
        unit: _selectedUnit!,
        property: widget.materialModel!.property,
      );
      await MaterialsApiService().updateMaterial(widget.materiau.id, updated);
      if (mounted) {
        Navigator.pop(context);
        widget.onUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Titre + X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Modifier le matériau',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Nom du matériau'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Ex: Ciment',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Champ obligatoire' : null,
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Unité'),
                    const SizedBox(height: 6),
                    _isLoadingUnits
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<Unit>(
                            value: _selectedUnit,
                            items: _units
                                .map((u) => DropdownMenuItem(
                                    value: u, child: Text(u.label)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedUnit = v),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) =>
                                v == null ? 'Champ obligatoire' : null,
                          ),
                    const SizedBox(height: 16),

                    _fieldLabel('Quantité actuelle'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ obligatoire';
                        if (int.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _fieldLabel('Seuil critique'),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Champ obligatoire';
                        if (int.tryParse(v) == null) return 'Nombre invalide';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A365D),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _isLoading ? null : _onSubmit,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Enregistrer',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style:
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );
}
