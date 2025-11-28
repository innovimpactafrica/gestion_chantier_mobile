import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import '../models/UserModel.dart';
import '../services/AuthService.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class MonCompteOuvrierPage extends StatefulWidget {
  const MonCompteOuvrierPage({Key? key}) : super(key: key);

  @override
  State<MonCompteOuvrierPage> createState() => _MonCompteOuvrierPageState();
}

class _MonCompteOuvrierPageState extends State<MonCompteOuvrierPage> {
  bool notificationsEnabled = true;
  UserModel? currentUser;
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
      final data = await AuthService().connectedUser();
      setState(() {
        currentUser = UserModel.fromJson(data);
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthUnauthenticatedState) {
          // Naviguer vers la page de login
          // Pour l'ouvrier, on navigue vers la route racine qui devrait rediriger vers le login
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1A365D),
          elevation: 0,
          toolbarHeight: 50,
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
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
                ? Center(
                  child: Text(error!, style: TextStyle(color: Colors.red)),
                )
                : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
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
                                  child:
                                      currentUser?.photo != null &&
                                              currentUser!.photo!.isNotEmpty
                                          ? Image.network(
                                            currentUser!.photo!,
                                            fit: BoxFit.cover,
                                            width: 94,
                                            height: 94,
                                          )
                                          : Image.asset(
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
                                currentUser != null
                                    ? '${currentUser!.prenom} ${currentUser!.nom}'
                                    : '',
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
                                currentUser?.profil ?? 'Ouvrier',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFB0B0B0),
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
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
                            // Informations personnelles
                            _buildListTile(
                              icon: SvgPicture.asset(
                                'assets/icons/edit.svg',
                                width: 24,
                                height: 24,
                                color: const Color(0xFFFF5C02),
                              ),
                              title: 'Informations personnelles',
                              onTap: () {},
                            ),
                            const Divider(
                              height: 0.5,
                              thickness: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            // Modifier mon mot de passe
                            _buildListTile(
                              icon: SvgPicture.asset(
                                'assets/icons/lock.svg',
                                width: 24,
                                height: 24,
                                color: const Color(0xFFFF5C02),
                              ),
                              title: 'Modifier mon mot de passe',
                              onTap: () {},
                            ),
                            const Divider(
                              height: 0.5,
                              thickness: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            // Notifications
                            _buildListTile(
                              icon: SvgPicture.asset(
                                'assets/icons/notifs.svg',
                                width: 24,
                                height: 24,
                                color: const Color(0xFFFF5C02),
                              ),
                              title: 'Notifications',
                              trailing: SizedBox(
                                width: 40,
                                height: 22,
                                child: FlutterSwitch(
                                  width: 40,
                                  height: 22,
                                  toggleSize: 18,
                                  value: notificationsEnabled,
                                  onToggle: (val) {
                                    setState(() => notificationsEnabled = val);
                                  },
                                  activeColor: const Color(0xFFFF5C02),
                                  inactiveColor: const Color(0xFFBFC5D2),
                                  toggleColor: Colors.white,
                                  showOnOff: false,
                                  borderRadius: 20.0,
                                  padding: 2.0,
                                ),
                              ),
                            ),
                            const Divider(
                              height: 0.5,
                              thickness: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            // Bulletins de salaire
                            _buildListTile(
                              icon: SvgPicture.asset(
                                'assets/icons/bulletin.svg',
                                width: 24,
                                height: 24,
                                color: const Color(0xFFFF5C02),
                              ),
                              title: 'Bulletins de salaire',
                              onTap: () {},
                            ),
                            const Divider(
                              height: 0.5,
                              thickness: 1,
                              color: Color(0xFFE0E0E0),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildListTile(
                                    icon: SvgPicture.asset(
                                      'assets/icons/logout.svg',
                                      width: 24,
                                      height: 24,
                                      color: const Color(0xFFFF5C02),
                                    ),
                                    title: 'Se déconnecter',
                                    onTap: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => AlertDialog(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(18),
                                              ),
                                              title: const Text(
                                                'Déconnexion',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: const Text(
                                                'Êtes-vous sûr de vouloir vous déconnecter ?',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(false),
                                                  child: const Text('Annuler'),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.of(
                                                        context,
                                                      ).pop(true),
                                                  child: const Text(
                                                    'Se déconnecter',
                                                    style: TextStyle(
                                                      color: Color(0xFFFF5C02),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      );
                                      if (confirmed == true) {
                                        // Déclencher l'événement de déconnexion via AuthBloc
                                        context.read<AuthBloc>().add(
                                          AuthLogoutEvent(),
                                        );

                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Vous avez été déconnecté avec succès.',
                                            ),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
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

  Widget _buildListTile({
    required Widget icon,
    required String title,
    Widget? trailing,
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
          trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Color(0xFF777777),
          ),
      onTap: onTap,
    );
  }
}
