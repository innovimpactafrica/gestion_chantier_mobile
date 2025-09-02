import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/models/MaterialModel.dart';
import 'package:gestion_chantier/moa/services/Materiaux_service.dart';

class AjouterMateriauScreen extends StatefulWidget {
  final RealEstateModel projet;

  const AjouterMateriauScreen({super.key, required this.projet});

  @override
  State<AjouterMateriauScreen> createState() => _AjouterMateriauScreenState();
}

class _AjouterMateriauScreenState extends State<AjouterMateriauScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _quantityController = TextEditingController();
  final _criticalThresholdController = TextEditingController();

  Unit? _selectedUnit;
  List<Unit> _units = [];
  bool _isLoading = false;
  bool _isLoadingUnits = true;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  Future<void> _loadUnits() async {
    try {
      final materialsApiService = MaterialsApiService();
      final units = await materialsApiService.getUnits();
      setState(() {
        _units = units;
        _isLoadingUnits = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUnits = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du chargement des unités'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez sélectionner une unité'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final materialsApiService = MaterialsApiService();
      await materialsApiService.addMaterialToInventory(
        label: _labelController.text.trim(),
        quantity: int.parse(_quantityController.text),
        criticalThreshold: int.parse(_criticalThresholdController.text),
        unitId: _selectedUnit!.id,
        propertyId: widget.projet.id,
      );
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors de l\'ajout du matériau: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                  'Nouveau matériau',
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
                        hintText: 'Ex: Ciment',
                        border: OutlineInputBorder(),
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
                      'Quantité actuelle',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 100',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Champ obligatoire';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Nombre invalide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Seuil critique',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 6),
                    TextFormField(
                      controller: _criticalThresholdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Ex: 20',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Champ obligatoire';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Nombre invalide';
                        }
                        return null;
                      },
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
                        onPressed: _isLoading ? null : _onSubmit,
                        child:
                            _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                  'Enregistrer',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
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
}
