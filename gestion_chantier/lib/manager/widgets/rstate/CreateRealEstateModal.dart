import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:gestion_chantier/bet/utils/constant.dart';
import 'package:gestion_chantier/manager/repository/RealEstateRepository.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/PropertyType.dart' show PropertyType;
import 'package:intl/intl.dart';

class CreateRealEstateBottomSheet extends StatefulWidget {
  final int promoterId;
  final String profil;


  const CreateRealEstateBottomSheet({super.key, required this.promoterId, required this.profil});

  @override
  State<CreateRealEstateBottomSheet> createState() =>
      _CreateRealEstateBottomSheetState();
}

class _CreateRealEstateBottomSheetState
    extends State<CreateRealEstateBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final RealEstateRepository _repository = RealEstateRepository();

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _areaCtrl = TextEditingController();
  final TextEditingController _numberOfLotsCtrl = TextEditingController();
  final TextEditingController _descriptionCtrl = TextEditingController();
  final TextEditingController _managerIdCtrl = TextEditingController();
  final TextEditingController _moaIdCtrl = TextEditingController();

  File? _planImage;
  int? _propertyTypeId;
  List<PropertyType> _propertyTypes = [];

  DateTime? _startDate;
  DateTime? _endDate;

  // options bool
  bool _hasGym = false;
  bool _hasElevator = false;
  bool _hasGarden = false;
  bool _hasSwimmingPool = false;
  bool _hasSharedTerrace = false;
  bool _hasHall = true;
  bool _hasPlayground = false;
  bool _hasBicycleStorage = false;
  bool _hasStorageRooms = false;
  bool _mezzanine = false;
  bool _hasSecurityService = false;
  bool _hasWasteDisposalArea = false;
  bool _hasLaundryRoom = false;
  bool _hasParking = false;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPropertyTypes();
  }

  Future<void> _loadPropertyTypes() async {
    _propertyTypes = await _repository.getPropertyTypes();
    setState(() {});
  }

  Future<void> _pickImage() async {
    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _planImage = File(picked.path));
    }
  }

  Future<void> _selectDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() ||
        _propertyTypeId == null ||
        _startDate == null ||
        _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _repository.createRealEstate(
        promoterId:widget.profil=="PROMOTEUR" ?widget.promoterId:widget.promoterId,
        name: _nameCtrl.text,
        address: _addressCtrl.text,
        latitude: 12.0,
        longitude: 12.0,
        area: double.tryParse(_areaCtrl.text) ?? 0,
        price: double.tryParse(_priceCtrl.text) ?? 0,
        propertyTypeId: _propertyTypeId!,
        startDate: _startDate!,
        endDate: _endDate!,
        planImage: _planImage,

        // options supplémentaires
        hasGym: _hasGym,
        hasElevator: _hasElevator,
        hasGarden: _hasGarden,
        hasSwimmingPool: _hasSwimmingPool,
        hasSharedTerrace: _hasSharedTerrace,
        hasHall: _hasHall,
        hasPlayground: _hasPlayground,
        hasBicycleStorage: _hasBicycleStorage,
        hasStorageRooms: _hasStorageRooms,
        mezzanine: _mezzanine,
        hasSecurityService: _hasSecurityService,
        hasWasteDisposalArea: _hasWasteDisposalArea,
        hasLaundryRoom: _hasLaundryRoom,
        hasParking: _hasParking,
        numberOfLots: int.tryParse(_numberOfLotsCtrl.text) ?? 1,
        managerId: widget.profil=="SITE_MANAGER" ?widget.promoterId:0,
        moaId: widget.profil=="MOA" ?widget.promoterId:0,
        description: _descriptionCtrl.text,
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    } finally {
      setState(() => _loading = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      minChildSize: 0.5,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text("Créer un chantier",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: "Nom"),
                      validator: (v) => v!.isEmpty ? "Champ requis" : null,
                    ),
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: const InputDecoration(labelText: "Adresse"),
                    ),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Budget prévu"),
                    ),
                    TextFormField(
                      controller: _areaCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Surface"),
                    ),
                    TextFormField(
                      controller: _numberOfLotsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Nombre de lots"),
                    ),
                    TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(labelText: "Description"),
                    ),
                 /*   TextFormField(
                      controller: _managerIdCtrl,
                      decoration: const InputDecoration(labelText: "Manager ID"),
                    ),
                    TextFormField(
                      controller: _moaIdCtrl,
                      decoration: const InputDecoration(labelText: "MOA ID"),
                    ),*/
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      value: _propertyTypeId,
                      items: _propertyTypes
                          .map(
                            (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.typeName),
                        ),
                      )
                          .toList(),
                      onChanged: (v) => setState(() => _propertyTypeId = v),
                      decoration:
                      const InputDecoration(labelText: "Type de bien"),
                      validator: (v) => v == null ? "Sélection obligatoire" : null,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectDate(isStart: true),
                            child: Text(
                              _startDate == null
                                  ? "Date début"
                                  : DateFormat('dd/MM/yyyy').format(_startDate!),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _selectDate(isStart: false),
                            child: Text(
                              _endDate == null
                                  ? "Date fin"
                                  : DateFormat('dd/MM/yyyy').format(_endDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Uploader le plan"),
                      ),
                    ),

                    const SizedBox(height: 10),
                    if (_planImage != null)
                      SizedBox(
                        width: double.infinity, // prend toute la largeur disponible
                        child: Stack(
                          children: [
                            // L'image s'adapte à la largeur et garde son ratio
                            AspectRatio(
                              aspectRatio: 16 / 9, // ou adapte selon le ratio souhaité
                              child: Image.file(
                                _planImage!,
                                fit: BoxFit.cover, // ou BoxFit.contain si tu veux qu'elle soit entièrement visible
                                width: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 14,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.red, size: 16),
                                  onPressed: () => setState(() => _planImage = null),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      children: [
                        _buildCheckbox("Gym", _hasGym, (v) => setState(() => _hasGym = v)),
                        _buildCheckbox("Elevator", _hasElevator, (v) => setState(() => _hasElevator = v)),
                        _buildCheckbox("Garden", _hasGarden, (v) => setState(() => _hasGarden = v)),
                        _buildCheckbox("Swimming Pool", _hasSwimmingPool, (v) => setState(() => _hasSwimmingPool = v)),
                        _buildCheckbox("Shared Terrace", _hasSharedTerrace, (v) => setState(() => _hasSharedTerrace = v)),
                        _buildCheckbox("Hall", _hasHall, (v) => setState(() => _hasHall = v)),
                        _buildCheckbox("Playground", _hasPlayground, (v) => setState(() => _hasPlayground = v)),
                        _buildCheckbox("Bicycle Storage", _hasBicycleStorage, (v) => setState(() => _hasBicycleStorage = v)),
                        _buildCheckbox("Storage Rooms", _hasStorageRooms, (v) => setState(() => _hasStorageRooms = v)),
                        _buildCheckbox("Mezzanine", _mezzanine, (v) => setState(() => _mezzanine = v)),
                        _buildCheckbox("Security Service", _hasSecurityService, (v) => setState(() => _hasSecurityService = v)),
                        _buildCheckbox("Waste Disposal", _hasWasteDisposalArea, (v) => setState(() => _hasWasteDisposalArea = v)),
                        _buildCheckbox("Laundry Room", _hasLaundryRoom, (v) => setState(() => _hasLaundryRoom = v)),
                        _buildCheckbox("Parking", _hasParking, (v) => setState(() => _hasParking = v)),
                      ],
                    ),


                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                            : const Text("Enregistrer", style: TextStyle(fontSize: 16)),
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

  Widget _buildCheckbox(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
        ),
        Text(label),
      ],
    );
  }
}

