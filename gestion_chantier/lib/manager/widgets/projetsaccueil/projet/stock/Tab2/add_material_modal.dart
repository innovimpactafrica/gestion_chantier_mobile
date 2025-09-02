import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/models/MaterialModel.dart';
import 'package:gestion_chantier/manager/services/Materiaux_service.dart';

Future<Map<String, dynamic>?> showAddMaterialModal(
  BuildContext context,
  List<MaterialModel> availableMaterials,
  int propertyId,
) async {
  return await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => AddMaterialModalContent(
          availableMaterials: availableMaterials,
          propertyId: propertyId,
        ),
  );
}

class AddMaterialModalContent extends StatefulWidget {
  final List<MaterialModel> availableMaterials;
  final int propertyId;
  const AddMaterialModalContent({
    Key? key,
    required this.availableMaterials,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<AddMaterialModalContent> createState() =>
      _AddMaterialModalContentState();
}

class _AddMaterialModalContentState extends State<AddMaterialModalContent> {
  MaterialModel? selectedMaterial;
  int quantity = 0;
  int unitPrice = 0;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController _labelController = TextEditingController();
  List<Unit> _units = [];
  Unit? _selectedUnit;
  bool _isLoadingUnits = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final units = await MaterialsApiService().getUnits();
      setState(() {
        _units = units;
        _isLoadingUnits = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUnits = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des unités'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
                  'Ajouter un matériau',
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
                      'Nom du matériau',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      controller: _labelController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Ciment Portland',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Champ obligatoire'
                                  : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Unité',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    _isLoadingUnits
                        ? Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<Unit>(
                          value: _selectedUnit,
                          items:
                              _units
                                  .map(
                                    (unit) => DropdownMenuItem(
                                      value: unit,
                                      child: Text(unit.label),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedUnit = val),
                          decoration: InputDecoration(
                            hintText: 'Sélectionner',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (value) =>
                                  value == null ? 'Champ obligatoire' : null,
                        ),
                    SizedBox(height: 16),
                    Text(
                      'Prix unitaire (FCFA)',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 1000',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty)
                          return 'Champ obligatoire';
                        if (int.tryParse(val) == null) return 'Nombre invalide';
                        if (int.tryParse(val)! <= 0) return 'Doit être > 0';
                        return null;
                      },
                      onChanged:
                          (val) => setState(
                            () => unitPrice = int.tryParse(val) ?? 0,
                          ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Qté à commander',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 4,
                          activeTrackColor:
                              quantity > 0
                                  ? Color(0xFFFF5C02)
                                  : Color(0xFFE5E7EB),
                          inactiveTrackColor: Color(0xFFE5E7EB),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withOpacity(0.2),
                          valueIndicatorColor: Colors.white,
                        ),
                        child: Slider(
                          value: quantity.toDouble(),
                          min: 0,
                          max: 100,
                          divisions: 100,
                          label: quantity.toString(),
                          onChanged:
                              (val) => setState(() => quantity = val.toInt()),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          quantity.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF183153),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed:
                            _isLoading
                                ? null
                                : () async {
                                  if (!_formKey.currentState!.validate() ||
                                      quantity <= 0 ||
                                      _selectedUnit == null)
                                    return;
                                  setState(() => _isLoading = true);
                                  try {
                                    final material = await MaterialsApiService()
                                        .addMaterialToInventory(
                                          label: _labelController.text.trim(),
                                          quantity: quantity,
                                          criticalThreshold: 0,
                                          unitId: _selectedUnit!.id,
                                          propertyId: widget.propertyId,
                                        );
                                    Navigator.of(context).pop({
                                      'material': material,
                                      'unitPrice': unitPrice,
                                      'quantity': quantity,
                                    });
                                  } catch (e) {
                                    setState(() => _isLoading = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Erreur lors de l\'ajout du matériau: '
                                          '${e.toString()}',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Ajouter',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
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
    );
  }
}
