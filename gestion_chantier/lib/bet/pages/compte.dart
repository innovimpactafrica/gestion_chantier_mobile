import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestion_chantier/bet/models/UserModel.dart';
import 'package:gestion_chantier/bet/services/AuthService.dart';
import 'package:gestion_chantier/bet/utils/constant.dart';
import 'package:gestion_chantier/bet/pages/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BetComptePage extends StatefulWidget {
  const BetComptePage({super.key});

  @override
  State<BetComptePage> createState() => _BetComptePageState();
}

class _BetComptePageState extends State<BetComptePage> {
  bool notificationsEnabled = true;
  bool locationEnabled = false;
  BetUserModel? currentUser;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await BetAuthService().connectedUser();
      setState(() {
        currentUser = data != null ? BetUserModel.fromJson(data) : null;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = currentUser != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF1A365D),
        elevation: 0,
        toolbarHeight: 70,
        title: Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'Mon compte',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile card
                    Container(
                      width: double.infinity,
                      height: 240,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Photo de profil circulaire
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(
                                    0xFFFF5C02,
                                  ).withOpacity(0.3),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/profil.jpg',
                                  fit: BoxFit.cover,
                                  width: 94,
                                  height: 94,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Nom de l'utilisateur
                            Text(
                              isLoggedIn
                                  ? '${currentUser!.prenom} ${currentUser!.nom}'
                                  : 'Invité',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            // Rôle
                            Text(
                              isLoggedIn
                                  ? (currentUser!.profil)
                                  : 'Non connecté',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF797979),
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Menu options
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          // Informations Personnelles
                          _buildListTile(
                            context,
                            icon: SvgPicture.asset(
                              'assets/icons/user-edit.svg',
                              width: 24,
                              height: 24,
                              color: const Color(0xFFFF5C02),
                            ),
                            title: 'Informations Personnelles',
                            hasSwitch: false,
                            hasArrow: true,
                            onTap: () {
                              if (isLoggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const BetProfilePage(),
                                  ),
                                );
                              } else {
                                _showLoginRequiredDialog(context);
                              }
                            },
                          ),
                          const Divider(
                            height: 0.5,
                            thickness: 1,
                            color: Color(0xFFE0E0E0),
                          ),
                          // Notifications
                          _buildListTile(
                            context,
                            icon: const Icon(
                              Icons.notifications,
                              color: Color(0xFFFF5C02),
                            ),
                            title: 'Notifications',
                            value: notificationsEnabled,
                            onChanged:
                                (value) => setState(
                                  () => notificationsEnabled = value,
                                ),
                          ),
                          const Divider(
                            height: 0.5,
                            thickness: 1,
                            color: Color(0xFFE0E0E0),
                          ),
                          // Localisation
                          _buildListTile(
                            context,
                            icon: const Icon(
                              Icons.location_on,
                              color: Color(0xFFFF5C02),
                            ),
                            title: 'Localisation',
                            value: locationEnabled,
                            onChanged:
                                (value) =>
                                    setState(() => locationEnabled = value),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Bouton de connexion/déconnexion
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF5C02).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isLoggedIn ? Icons.logout : Icons.login,
                            color: const Color(0xFFFF5C02),
                          ),
                        ),
                        title: Text(
                          isLoggedIn ? 'Se déconnecter' : 'Se connecter',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onTap: () {
                          if (isLoggedIn) {
                            _showLogoutConfirmDialog(context);
                          } else {
                            _navigateToLogin(context);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  void _navigateToLogin(BuildContext context) async {
    // Navigation vers la page de login si nécessaire
    // Pour l'instant, on peut juste afficher un message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité de connexion à implémenter'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Connexion requise'),
          content: const Text(
            'Vous devez être connecté pour accéder à cette fonctionnalité.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _navigateToLogin(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF5C02),
              ),
              child: const Text('Se connecter'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Supprimer le token
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(APIConstants.AUTH_TOKEN);
                await prefs.remove(APIConstants.REFRESH_TOKEN);
                // Naviguer vers la page de login (ou root)
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('splashscreen', (route) => false);
                }
                
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF5C02),
              ),
              child: const Text('Déconnecter'),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildListTile(
  BuildContext context, {
  required Widget icon,
  required String title,
  bool hasSwitch = true,
  bool? value,
  ValueChanged<bool>? onChanged,
  bool hasArrow = false,
  VoidCallback? onTap,
}) {
  return ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    leading: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5C02).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: icon,
    ),
    title: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    trailing:
        hasSwitch
            ? _buildCustomSwitch(
              context,
              value: value ?? false,
              onChanged: onChanged!,
            )
            : hasArrow
            ? const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF777777),
            )
            : null,
    onTap: hasSwitch ? () => onChanged!(!value!) : onTap,
  );
}

Widget _buildCustomSwitch(
  BuildContext context, {
  required bool value,
  required ValueChanged<bool> onChanged,
}) {
  return Theme(
    data: Theme.of(context).copyWith(
      switchTheme: SwitchThemeData(
        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        trackColor: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.selected)
              ? const Color(0xFFFF5C02)
              : const Color(0xFFD0D5DD);
        }),
        thumbColor: MaterialStateProperty.all(Colors.white),
        thumbIcon: MaterialStateProperty.all(null),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashRadius: 0,
      ),
    ),
    child: Transform.scale(
      scale: 0.7,
      child: Switch(value: value, onChanged: onChanged),
    ),
  );
}
