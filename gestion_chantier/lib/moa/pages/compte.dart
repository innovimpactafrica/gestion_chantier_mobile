// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_bloc.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_event.dart';
import 'package:gestion_chantier/manager/bloc/auth/auth_state.dart';
import 'package:gestion_chantier/moa/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/moa/bloc/home/home_state.dart';
import 'package:gestion_chantier/moa/bloc/home/home_event.dart';
import 'package:gestion_chantier/moa/pages/auth/login.dart';
import 'package:gestion_chantier/moa/pages/profil.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/repository/auth_repository.dart';

class ComptePage extends StatefulWidget {
  const ComptePage({super.key});

  @override
  State<ComptePage> createState() => _ComptePageState();
}

class _ComptePageState extends State<ComptePage> {
  bool notificationsEnabled = true;
  bool locationEnabled = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticatedState) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final bool isLoggedIn = state.currentUser != null;

          return Scaffold(
            backgroundColor: HexColor('#F5F7FA'),
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: HexColor('#1A365D'),
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
            body: SingleChildScrollView(
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
                                color: HexColor('#FF5C02').withOpacity(0.3),
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
                                ? '${state.currentUser?.prenom ?? ''} ${state.currentUser?.nom ?? ''}'
                                : 'Invité',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 8),

                          // Nom de l'entreprise
                          Text(
                            isLoggedIn
                                ? (state.currentUser?.profil ?? 'Profil')
                                : 'Non connecté',

                            style: TextStyle(
                              fontSize: 16,
                              color: HexColor('#797979'),
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
                            color: HexColor('#FF5C02'),
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
                                      (context) => BlocProvider<HomeBloc>(
                                        create:
                                            (_) => HomeBloc(
                                              authRepository: AuthRepository(),
                                            )..add(LoadCurrentUserEvent()),
                                        child: const ProfilePage(),
                                      ),
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
                          icon: Icon(
                            Icons.notifications,
                            color: HexColor('#FF5C02'),
                          ),
                          title: 'Notifications',
                          value: notificationsEnabled,
                          onChanged:
                              (value) =>
                                  setState(() => notificationsEnabled = value),
                        ),

                        const Divider(
                          height: 0.5,
                          thickness: 1,
                          color: Color(0xFFE0E0E0),
                        ),

                        // Localisation
                        _buildListTile(
                          context,
                          icon: Icon(
                            Icons.location_on,
                            color: HexColor('#FF5C02'),
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
                          color: HexColor('#FF5C02').withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          isLoggedIn ? Icons.logout : Icons.login,
                          color: HexColor('#FF5C02'),
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
        },
      ),
    );
  }

  void _navigateToLogin(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );

    // Si l'utilisateur s'est connecté avec succès, on peut actualiser la page
    if (result == true) {
      setState(() {});
    }
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
              style: TextButton.styleFrom(foregroundColor: HexColor('#FF5C02')),
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
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                // Déclencher l'événement de déconnexion en utilisant le contexte parent
                context.read<AuthBloc>().add(AuthLogoutEvent());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vous avez été déconnecté avec succès.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: HexColor('#FF5C02')),
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
        color: HexColor('#FF5C02').withOpacity(0.1),
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
            ? Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: HexColor('#777777'),
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
              ? HexColor('#FF5C02')
              : HexColor('#D0D5DD');
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
