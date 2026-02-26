import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/repository/WorkerRepository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CreateWorkerBottomSheet extends StatefulWidget {
  final int projetId;

  const CreateWorkerBottomSheet({super.key, required this.projetId});

  @override
  State<CreateWorkerBottomSheet> createState() =>
      _CreateWorkerBottomSheetState();
}

class _CreateWorkerBottomSheetState extends State<CreateWorkerBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final WorkerRepository _repository = WorkerRepository();

  final TextEditingController _prenomCtrl = TextEditingController();
  final TextEditingController _nomCtrl = TextEditingController();
  final TextEditingController _telephoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _adressCtrl = TextEditingController();
  final TextEditingController _lieuNaissanceCtrl = TextEditingController();

  DateTime? _birthDate;
  File? _photo;
  String? _profil;

  bool _loading = false;

  final Map<String, String> _profilMap = {
    'SITE_MANAGER': 'Responsable de site',
    'WORKER': 'Ouvrier',
    'MOA': 'MOA',
  };

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _photo = File(picked.path));
    }
  }

  Future<void> _selectBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _profil == null || _birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir tous les champs obligatoires")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _repository.createWorker(
        id: widget.projetId,
        prenom: _prenomCtrl.text,
        nom: _nomCtrl.text,
        telephone: _telephoneCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        profil: _profil!,
        adress: _adressCtrl.text,
        lieunaissance: _lieuNaissanceCtrl.text,
        date: _birthDate!,
        photo: _photo,
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
      initialChildSize: 0.85,
      minChildSize: 0.5,
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
                      child: Text("Créer un worker",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
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
                      controller: _prenomCtrl,
                      decoration: const InputDecoration(labelText: "Prénom"),
                      validator: (v) => v!.isEmpty ? "Champ requis" : null,
                    ),
                    TextFormField(
                      controller: _nomCtrl,
                      decoration: const InputDecoration(labelText: "Nom"),
                      validator: (v) => v!.isEmpty ? "Champ requis" : null,
                    ),
                    TextFormField(
                      controller: _telephoneCtrl,
                      decoration: const InputDecoration(labelText: "Téléphone"),
                      validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: "Mot de passe"),
                      validator: (v) => v!.isEmpty ? "Champ requis" : null,
                      obscureText: true,
                    ),
                    TextFormField(
                      controller: _adressCtrl,
                      decoration: const InputDecoration(labelText: "Adresse"),
                    ),
                    TextFormField(
                      controller: _lieuNaissanceCtrl,
                      decoration: const InputDecoration(labelText: "Lieu de naissance"),
                    ),

                    const SizedBox(height: 10),

                    // Dropdown profil
                    DropdownButtonFormField<String>(
                      value: _profil,
                      items: _profilMap.entries
                          .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                          .toList(),
                      onChanged: (v) => setState(() => _profil = v),
                      decoration: const InputDecoration(labelText: "Profil"),
                      validator: (v) => v == null ? "Sélection obligatoire" : null,
                    ),
                    const SizedBox(height: 10),




                    // Date de naissance
                    SizedBox(
                        width: double.infinity,
                        child:OutlinedButton(
                      onPressed: _selectBirthDate,
                      child: Text(_birthDate == null
                          ? "Date de naissance"
                          : DateFormat('dd/MM/yyyy').format(_birthDate!)),
                    )),
                    const SizedBox(height: 10),
                    // Photo
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _pickPhoto,
                        icon: const Icon(Icons.image),
                        label: const Text("Uploader une photo"),
                      ),
                    ),
                    if (_photo != null)
                      SizedBox(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 1,
                              child: Image.file(_photo!, fit: BoxFit.cover, width: double.infinity),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.white,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.close, color: Colors.red, size: 16),
                                  onPressed: () => setState(() => _photo = null),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            ? const CircularProgressIndicator(color: Colors.white)
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
}
