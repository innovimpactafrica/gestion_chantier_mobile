import 'package:flutter/material.dart';

import '../../services/AuthService.dart';
import '../../utils/constant.dart';
import '../../models/UserModel.dart';
import '../../services/PointageService.dart';
import '../addresses/add_address_page.dart';

class AddressListPage extends StatefulWidget {
  final int projectId;
  const AddressListPage({Key? key, required this.projectId}) : super(key: key);

  @override
  State<AddressListPage> createState() => _ModernPointagePageState();
}

class _ModernPointagePageState extends State<AddressListPage> {
  int _selectedTab = 0;
  final _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.connectedUser();
      if (userData != null && mounted) {
        setState(() {
          _currentUser = UserModel.fromJson(userData);
        });
      }
    } catch (e) {
      // Ignorer les erreurs silencieusement
    }
  }

  void _goToHistorique() {
    setState(() {
      _selectedTab = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        color: const Color(0xFFF5F7FA),
        child:_AdressesTab(widget.projectId),
      ),
    );
  }
}

class _AppHeader extends StatelessWidget {
  final UserModel? currentUser;

  const _AppHeader({required this.currentUser});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Bonjour';
    } else if (hour < 18) {
      return 'Bon après-midi';
    } else {
      return 'Bonsoir';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFF1A365D)),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Barre supérieure avec logo
            const Text(
              'UKUBHALISA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Section utilisateur avec photo et message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  // Photo de profil
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child:
                        currentUser?.photo != null &&
                                currentUser!.photo!.isNotEmpty
                            ? ClipOval(
                              child: Image.network(
                                '${APIConstants.API_BASE_URL_IMG}${currentUser!.photo!}',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 30,
                                  );
                                },
                              ),
                            )
                            : const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 30,
                            ),
                  ),
                  const SizedBox(width: 16),
                  // Message de bienvenue
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${_getGreeting()} ${currentUser?.prenom ?? 'Utilisateur'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('👋', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointageHeaderTabs extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;
  final UserModel? currentUser;

  const _PointageHeaderTabs({
    required this.selected,
    required this.onChanged,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A365D),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: () => onChanged(0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            color:
                                selected == 0
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pointage',
                            style: TextStyle(
                              color:
                                  selected == 0
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 1,
                        margin: EdgeInsets.only(left: 30, right: 30),
                        //   width: 100,
                        decoration: BoxDecoration(
                          color:
                              selected == 0 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () => onChanged(1),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            color:
                                selected == 1
                                    ? Colors.white
                                    : const Color(0xFFBFC5D2),
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Historique',
                            style: TextStyle(
                              color:
                                  selected == 1
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 1,
                        margin: EdgeInsets.only(left: 30, right: 30),
                        decoration: BoxDecoration(
                          color:
                              selected == 1 ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if ( currentUser!=null && (currentUser!.profil == "PROMOTEUR"|| currentUser!.profil == "SITE_MANAGER"))
                Flexible(
                  child: GestureDetector(
                    onTap: () => onChanged(2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              color:
                                  selected == 2
                                      ? Colors.white
                                      : const Color(0xFFBFC5D2),
                              size: 22,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Adresses',
                              style: TextStyle(
                                color:
                                    selected == 2
                                        ? Colors.white
                                        : const Color(0xFFBFC5D2),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 4,
                          width: 40,
                          decoration: BoxDecoration(
                            color:
                                selected == 2
                                    ? Colors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdressesTab extends StatefulWidget {
  final int projectId;
  _AdressesTab(this.projectId);

  @override
  State<_AdressesTab> createState() => _AdressesTabState();
}

class _AdressesTabState extends State<_AdressesTab> {
  final _pointageService = PointageService();
  List<Map<String, dynamic>> _adresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdresses();
  }

  Future<void> _loadAdresses() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Utiliser l'ID du projet 22 (vous pouvez le rendre dynamique plus tard)
       int projectId = widget.projectId;
      final adressesApi = await _pointageService.getAdressesPointage(projectId);

      // Transformer les données de l'API pour correspondre à notre format d'affichage
      if (mounted) {
        setState(() {
          _adresses =
              adressesApi.map((adresse) {
                return {
                  'id': adresse['id'],
                  'nom': adresse['name'],
                  'latitude': adresse['latitude'],
                  'longitude': adresse['longitude'],
                  'type': _determinerTypeAdresse(adresse['name']),
                  'isActive':
                      true, // Par défaut, toutes les adresses sont actives
                };
              }).toList();
        });
      }

      print(
        '✅ [AdressesTab] ${_adresses.length} adresses chargées depuis l\'API',
      );
    } catch (e) {
      print('❌ [AdressesTab] Erreur lors du chargement des adresses: $e');
      // En cas d'erreur, utiliser des données d'exemple
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Détermine le type d'adresse basé sur le nom
  String _determinerTypeAdresse(String nom) {
    final nomLower = nom.toLowerCase();
    if (nomLower.contains('chantier') || nomLower.contains('construction')) {
      return 'Chantier';
    } else if (nomLower.contains('entrepôt') || nomLower.contains('stockage')) {
      return 'Entrepôt';
    } else if (nomLower.contains('bureau') || nomLower.contains('siège')) {
      return 'Bureau';
    } else {
      return 'chantier'; // Par défaut
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5C02)),
        ),
      );
    }

    return Stack(
      children: [
        /// CONTENU PRINCIPAL
        Positioned.fill(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 120, // important pour éviter chevauchement FAB
            ),
            child: _adresses.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_off, size: 80, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Aucune adresse enregistrée',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _adresses
                  .map((adresse) => _buildAdresseCard(adresse))
                  .toList(),
            ),
          ),
        ),

        /// FLOATING BUTTON
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AddAddressPage()),
              );

              if (result == true) {
                _loadAdresses();
              }
            },
            backgroundColor: const Color(0xFFFF5C02),
            icon: const Icon(Icons.add_location, color: Colors.white),
            label: const Text(
              'Ajouter une adresse',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    )
;
  }

  Widget _buildAdresseCard(Map<String, dynamic> adresse) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getTypeColor(adresse['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getTypeIcon(adresse['type']),
                  color: _getTypeColor(adresse['type']),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      adresse['nom'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A365D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      adresse['type'],
                      style: TextStyle(
                        fontSize: 12,
                        color: _getTypeColor(adresse['type']),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      adresse['isActive']
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  adresse['isActive'] ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color:
                        adresse['isActive']
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFE74C3C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.gps_fixed, size: 16, color: Color(0xFF8A98A8)),
              const SizedBox(width: 8),
              Text(
                '${adresse['latitude'].toStringAsFixed(6)}, ${adresse['longitude'].toStringAsFixed(6)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A98A8),
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'bureau':
        return const Color(0xFF2196F3);
      case 'chantier':
        return const Color(0xFFFF5C02);
      case 'entrepôt':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF8A98A8);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'bureau':
        return Icons.business;
      case 'chantier':
        return Icons.construction;
      case 'entrepôt':
        return Icons.warehouse;
      default:
        return Icons.location_on;
    }
  }
}
