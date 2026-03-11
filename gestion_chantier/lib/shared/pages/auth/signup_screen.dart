import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_bloc.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_event.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_state.dart';
import 'package:gestion_chantier/shared/utils/HexColor.dart';
import 'package:intl/intl.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final _lieuNaissanceController = TextEditingController();

  bool _obscurePassword = true;
  String _selectedProfil = 'SITE_MANAGER';
  DateTime? _dateNaissance;

  final List<Map<String, String>> _profilOptions = [
    {'label': 'Manager', 'value': 'SITE_MANAGER'},
    {'label': 'Ouvrier', 'value': 'SUBCONTRACTOR'},
  ];

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _lieuNaissanceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateNaissance ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 10),
    );
    if (picked != null) {
      setState(() => _dateNaissance = picked);
    }
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthSignupEvent(
        firstName: _prenomController.text.trim(),
        lastName: _nomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _telephoneController.text.trim(),
        profil: _selectedProfil,
        adresse: _adresseController.text.trim(),
        dateNaissance: _dateNaissance != null
            ? DateFormat('yyyy-MM-dd').format(_dateNaissance!)
            : '',
        lieuNaissance: _lieuNaissanceController.text.trim(),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HexColor('#CBD5E1')),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: HexColor('#9C9AA5'), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccesState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Inscription réussie ! Vous pouvez vous connecter.'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
            Navigator.pop(context);
          } else if (state is AuthErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoadingState;

          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ListView(
                  children: [
                    const SizedBox(height: 4),

                    // Titre
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remplissez les informations ci-dessous pour vous inscrire.',
                      style: TextStyle(fontSize: 13, color: HexColor('#6C7278'), height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    // Nom
                    _buildLabel('Nom'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _nomController,
                      hintText: 'Votre nom',
                      enabled: !isLoading,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Veuillez saisir votre nom' : null,
                    ),
                    const SizedBox(height: 16),

                    // Prénom
                    _buildLabel('Prénom'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _prenomController,
                      hintText: 'Votre prénom',
                      enabled: !isLoading,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Veuillez saisir votre prénom' : null,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    _buildLabel('Email'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _emailController,
                      hintText: 'ex. pro@chantier.com',
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Veuillez saisir votre email';
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mot de passe
                    _buildLabel('Mot de passe'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HexColor('#CBD5E1')),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Veuillez saisir votre mot de passe';
                          if (v.length < 6) return 'Minimum 6 caractères';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Minimum 6 caractères',
                          hintStyle: TextStyle(color: HexColor('#9C9AA5'), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: HexColor('#ACB5BB'),
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Téléphone
                    _buildLabel('Téléphone'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _telephoneController,
                      hintText: 'Votre numéro de téléphone',
                      keyboardType: TextInputType.phone,
                      enabled: !isLoading,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Veuillez saisir votre téléphone' : null,
                    ),
                    const SizedBox(height: 16),

                    // Profil
                    _buildLabel('Profil'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HexColor('#CBD5E1')),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedProfil,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        ),
                        items: _profilOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option['value'],
                            child: Text(option['label']!),
                          );
                        }).toList(),
                        onChanged: isLoading
                            ? null
                            : (val) {
                                if (val != null) setState(() => _selectedProfil = val);
                              },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Adresse
                    _buildLabel('Adresse'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _adresseController,
                      hintText: 'Votre adresse',
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Date de naissance
                    _buildLabel('Date de naissance'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: isLoading ? null : () => _pickDate(context),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: HexColor('#CBD5E1')),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _dateNaissance != null
                                    ? DateFormat('dd/MM/yyyy').format(_dateNaissance!)
                                    : 'Sélectionner une date',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: _dateNaissance != null
                                      ? Colors.black
                                      : HexColor('#9C9AA5'),
                                ),
                              ),
                            ),
                            Icon(Icons.calendar_today_outlined,
                                size: 18, color: HexColor('#ACB5BB')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lieu de naissance
                    _buildLabel('Lieu de naissance'),
                    const SizedBox(height: 8),
                    _buildField(
                      controller: _lieuNaissanceController,
                      hintText: 'Votre lieu de naissance',
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 32),

                    // Bouton S'inscrire
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isLoading ? Colors.grey[400] : HexColor('#FF5C02'),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "S'inscrire",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lien vers connexion
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Vous avez déjà un compte ?  ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading ? null : () => Navigator.pop(context),
                            child: Text(
                              'Se connecter',
                              style: TextStyle(
                                color: isLoading ? Colors.grey : HexColor('#FF5C02'),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
