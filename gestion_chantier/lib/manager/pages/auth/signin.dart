// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestion_chantier/manager/pages/auth/login.dart';
import 'package:gestion_chantier/manager/utils/DottedBorderPainter.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';

// Page principale qui gère les étapes d'inscription
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuccessModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SuccessModal();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          CompteScreen(
            onNext: _nextStep,
            onBack: _previousStep,
            currentStep: _currentStep,
          ),
          ProfileInfoScreen(
            onNext: _nextStep,
            onBack: _previousStep,
            currentStep: _currentStep,
          ),
          PhotoUploadScreen(
            onNext: _showSuccessModal,
            onBack: _previousStep,
            currentStep: _currentStep,
          ),
        ],
      ),
    );
  }
}

class CompteScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int currentStep;

  const CompteScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  });

  @override
  _CompteScreenState createState() => _CompteScreenState();
}

class _CompteScreenState extends State<CompteScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre principal
            Text(
              'Créer un compte',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 12),

            // Sous-titre
            Text(
              'Créez votre espace pour mieux gérer vos projets.',
              style: TextStyle(
                fontSize: 13,
                color: HexColor('#6C7278'),
                height: 1.4,
              ),
            ),

            SizedBox(height: 22),

            // Champ Email
            Text(
              'Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HexColor('#CBD5E1')),
              ),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'ex. pro@chantier.com',
                  hintStyle: TextStyle(
                    color: HexColor('#9C9AA5'),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 16),

            // Champ Mot de passe
            Text(
              'Mot de passe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HexColor('#CBD5E1')),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Minimum 8 caractères',
                  hintStyle: TextStyle(
                    color: HexColor('#9C9AA5'),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 13,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: HexColor('#ACB5BB'),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 24),

            // Bouton Créer mon compte
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#FF5C02'),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Créer un Compte',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 22),

            // Séparateur "Ou"
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Ou',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),

            SizedBox(height: 12),

            // Boutons Google et Apple
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {
                        // Action Google
                        print('Connexion avec Google');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.g_mobiledata,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Google',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 42,
                    child: OutlinedButton(
                      onPressed: () {
                        // Action Apple
                        print('Connexion avec Apple');
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apple, color: Colors.black, size: 20),
                          SizedBox(width: 12),
                          Text(
                            'Apple',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Spacer(),

            // Lien de connexion en bas
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Déjà inscrit ? ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Text(
                      'Se connecter',
                      style: TextStyle(
                        color: HexColor('#FF5C02'),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 44),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

// Étape 1: Informations du profil
class ProfileInfoScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int currentStep;

  const ProfileInfoScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  });

  @override
  _ProfileInfoScreenState createState() => _ProfileInfoScreenState();
}

class _ProfileInfoScreenState extends State<ProfileInfoScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  String? _selectedPosition;

  final List<String> _positions = [
    'Chef de projet',
    'Architecte',
    'Ingénieur',
    'Conducteur de travaux',
    'Maître d\'ouvrage',
    'Entrepreneur',
    'Autre',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          // Barre de progression
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: HexColor('#FF5C02')),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: HexColor('#FF5C02'),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300]),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 19),

                  // Titre
                  Text(
                    'Complétez votre profil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: HexColor('#1A1C1E'),
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    'Un profil détaillé facilite vos échanges avec l\'équipe.',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color.fromARGB(255, 48, 48, 48),
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 32),

                  // Prénom
                  Text(
                    'Prénom',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HexColor('#CBD5E1')),
                    ),
                    child: TextField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        hintText: 'Votre prénom',
                        hintStyle: TextStyle(
                          color: HexColor('#9C9AA5'),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Nom
                  Text(
                    'Nom',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HexColor('#CBD5E1')),
                    ),
                    child: TextField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        hintText: 'Votre nom',
                        hintStyle: TextStyle(
                          color: HexColor('#9C9AA5'),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Nom de l'entreprise
                  Text(
                    'Nom de votre entreprise',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HexColor('#CBD5E1')),
                    ),
                    child: TextField(
                      controller: _companyController,
                      decoration: InputDecoration(
                        hintText: 'ex. Groupe BTP Sénégal',
                        hintStyle: TextStyle(
                          color: HexColor('#9C9AA5'),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),

                  SizedBox(height: 18),

                  // Poste
                  Text(
                    'Poste',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: HexColor('#CBD5E1')),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedPosition,
                      decoration: InputDecoration(
                        hintText: 'Sélectionnez votre poste',
                        hintStyle: TextStyle(
                          color: HexColor('#666666'),
                          fontSize: 12,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      items:
                          _positions.map((String position) {
                            return DropdownMenuItem<String>(
                              value: position,
                              child: Text(
                                position,
                                style: TextStyle(fontSize: 12),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPosition = newValue;
                        });
                      },
                      dropdownColor: Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  SizedBox(height: 22),

                  // Bouton Continuer
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#FF5C02'),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Continuer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyController.dispose();
    super.dispose();
  }
}

// Étape 2: Upload de photo
class PhotoUploadScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final int currentStep;

  const PhotoUploadScreen({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.currentStep,
  });

  @override
  _PhotoUploadScreenState createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: widget.onBack,
        ),
      ),
      body: Column(
        children: [
          // Barre de progression
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: HexColor('#FF5C02')),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: HexColor('#FF5C02')),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(color: HexColor('#FF5C02')),
                ),
              ),
            ],
          ),

          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 18),

                  // Titre
                  Text(
                    'Complétez votre profil',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Ajoutez votre photo pour personnaliser votre espace.',
                    style: TextStyle(
                      fontSize: 12,
                      color: HexColor('#6C7278'),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 38),

                  // Zone d'upload de photo
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        print('Sélectionner une photo');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 250,
                        decoration: BoxDecoration(
                          color: HexColor('#FF5C02').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: CustomPaint(
                          painter: DottedBorderPainter(
                            radius: 16,
                            color: HexColor('#FF5C02').withOpacity(0.2),
                            dashPattern: [6, 4],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/image.svg',
                                width: 80,
                                height: 80,
                                color: HexColor('#FF5C02'),
                              ),

                              SizedBox(height: 34),

                              Text(
                                'Télécharger votre photo',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),

                              SizedBox(height: 8),

                              Text(
                                'Formats autorisés : JPG, PNG – max 5Mo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 38),

                  // Bouton Commençons
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor('#FF5C02'),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Commençons',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modal de succès
class SuccessModal extends StatelessWidget {
  const SuccessModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icône de succès
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE6F4EA),
              ),
              child: Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HexColor('#1EA438').withOpacity(0.01),
                  ),
                  child: Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: HexColor('#039855').withOpacity(0.2),
                      ),
                      child: Center(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: HexColor('#ffffff').withOpacity(0.1),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/check.svg',
                              width: 35,
                              height: 35,
                              color: const Color(0xFF1E9B4A),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32),

            // Titre
            Text(
              'Inscription réussie !',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 25),

            // Sous-titre
            Text(
              'Votre compte a été créé avec succès.',
              style: TextStyle(fontSize: 16, color: HexColor('#4F4F4F')),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),

            // Bouton d'accès à l'espace
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor('#FF5C02'),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Accéder à mon espace',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
