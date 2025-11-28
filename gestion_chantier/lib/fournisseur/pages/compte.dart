import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/fournisseur/bloc/auth/auth_bloc.dart';
import 'package:gestion_chantier/fournisseur/bloc/auth/auth_event.dart';
import 'package:gestion_chantier/fournisseur/bloc/auth/auth_state.dart';
import 'package:gestion_chantier/fournisseur/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/fournisseur/bloc/home/home_state.dart';
import 'package:gestion_chantier/fournisseur/pages/auth/login.dart';
import 'package:gestion_chantier/fournisseur/utils/HexColor.dart';

class ComptePage extends StatelessWidget {
  const ComptePage({super.key});

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
          final isLoggedIn = state.currentUser != null;

          return Container(
            color: HexColor('#F5F7FA'),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: HexColor('#FF5C02'),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isLoggedIn
                                      ? '${state.currentUser!.prenom} ${state.currentUser!.nom}'
                                      : 'Fournisseur',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: HexColor('#1A365D'),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isLoggedIn ? state.currentUser!.email : '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: HexColor('#8A98A8'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Section Paramètres
                    Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#1A365D'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            context,
                            icon: Icon(
                              Icons.person_outline,
                              color: HexColor('#FF5C02'),
                              size: 24,
                            ),
                            title: 'Informations Personnelles',
                            hasSwitch: false,
                            hasArrow: true,
                            onTap: () {
                              if (isLoggedIn) {
                                // TODO: Naviguer vers la page de profil
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Page de profil en développement',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          const Divider(height: 1),
                          _buildListTile(
                            context,
                            icon: Icon(
                              Icons.notifications_outlined,
                              color: HexColor('#FF5C02'),
                              size: 24,
                            ),
                            title: 'Notifications',
                            hasSwitch: true,
                            hasArrow: false,
                            onTap: () {},
                          ),
                          const Divider(height: 1),
                          _buildListTile(
                            context,
                            icon: Icon(
                              Icons.security_outlined,
                              color: HexColor('#FF5C02'),
                              size: 24,
                            ),
                            title: 'Sécurité',
                            hasSwitch: false,
                            hasArrow: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Page de sécurité en développement',
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Section Support
                    Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: HexColor('#1A365D'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildListTile(
                            context,
                            icon: Icon(
                              Icons.help_outline,
                              color: HexColor('#FF5C02'),
                              size: 24,
                            ),
                            title: 'Aide et Support',
                            hasSwitch: false,
                            hasArrow: true,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Page d\'aide en développement',
                                  ),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          _buildListTile(
                            context,
                            icon: Icon(
                              Icons.info_outline,
                              color: HexColor('#FF5C02'),
                              size: 24,
                            ),
                            title: 'À propos',
                            hasSwitch: false,
                            hasArrow: true,
                            onTap: () {
                              _showAboutDialog(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Bouton de déconnexion
                    if (isLoggedIn)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Se déconnecter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required Widget icon,
    required String title,
    required bool hasSwitch,
    required bool hasArrow,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1A365D),
        ),
      ),
      trailing:
          hasArrow
              ? const Icon(Icons.chevron_right, color: Color(0xFF8A98A8))
              : hasSwitch
              ? Switch(
                value: true, // TODO: Gérer l'état réel
                onChanged: (value) {},
                activeColor: HexColor('#FF5C02'),
              )
              : null,
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('À propos'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gestion Chantier'),
              SizedBox(height: 8),
              Text('Version 1.0.0'),
              SizedBox(height: 8),
              Text('Module Fournisseur'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutEvent());

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Vous avez été déconnecté avec succès.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Déconnexion'),
            ),
          ],
        );
      },
    );
  }
}
