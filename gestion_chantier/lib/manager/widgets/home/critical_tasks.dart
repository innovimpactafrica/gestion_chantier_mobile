import 'package:flutter/material.dart';
import 'package:gestion_chantier/manager/models/Taskcritical.dart';
import 'package:gestion_chantier/manager/services/CriticalsTask.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';

class CriticalTasksWidget extends StatefulWidget {
  const CriticalTasksWidget({super.key});

  @override
  State<CriticalTasksWidget> createState() => _CriticalTasksWidgetState();
}

class _CriticalTasksWidgetState extends State<CriticalTasksWidget> {
  final CriticalTasksService _criticalTasksService = CriticalTasksService();
  List<Task>? _tasks;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCriticalTasks();
  }

  Future<void> _loadCriticalTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Utilisation du service tel que défini
      final tasks = await _criticalTasksService.getCriticalTasksSafely();

      if (mounted) {
        setState(() {
          _tasks = tasks ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _getErrorMessage(e.toString());
          _isLoading = false;
          _tasks = []; // Assurer qu'on a une liste vide en cas d'erreur
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    // Gestion des messages d'erreur basée sur votre service
    if (error.contains('Utilisateur non connecté')) {
      return 'Veuillez vous reconnecter à votre compte.';
    } else if (error.contains('connexion') ||
        error.contains('Connection') ||
        error.contains('SocketException') ||
        error.contains('Impossible de se connecter au serveur')) {
      return 'Problème de connexion réseau. Vérifiez votre connexion internet.';
    } else if (error.contains('timeout') ||
        error.contains('Timeout') ||
        error.contains('Délai')) {
      return 'Délai d\'attente dépassé. Le serveur met trop de temps à répondre.';
    } else if (error.contains('404') || error.contains('Endpoint non trouvé')) {
      return 'Service non trouvé. Contactez l\'administrateur.';
    } else if (error.contains('401') || error.contains('Non autorisé')) {
      return 'Erreur d\'authentification. Reconnectez-vous.';
    } else if (error.contains('403') || error.contains('Accès interdit')) {
      return 'Accès non autorisé. Vérifiez vos permissions.';
    } else if (error.contains('500') || error.contains('Erreur serveur')) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else if (error.contains('503') ||
        error.contains('Service indisponible')) {
      return 'Service temporairement indisponible. Réessayez plus tard.';
    } else {
      return 'Une erreur inattendue s\'est produite.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tâches critiques à échéance',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: HexColor('#2C3E50'),
                ),
              ),

              // Bouton de rafraîchissement
            ],
          ),

          const SizedBox(height: 24),

          // Content
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_errorMessage != null)
            _buildErrorWidget()
          else if (_tasks == null || _tasks!.isEmpty)
            _buildEmptyWidget()
          else
            _buildTasksList(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final isConnectionError = _errorMessage?.contains('connexion') ?? false;
    final isAuthError = _errorMessage?.contains('authentification') ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            isConnectionError
                ? Icons.wifi_off
                : isAuthError
                ? Icons.lock_outline
                : Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            isConnectionError
                ? 'Problème de connexion'
                : isAuthError
                ? 'Problème d\'authentification'
                : 'Erreur lors du chargement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Une erreur inattendue s\'est produite',
            style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _loadCriticalTasks,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
              if (isConnectionError) ...[
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _showConnectionTips,
                  icon: const Icon(Icons.help_outline, size: 18),
                  label: const Text('Aide'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showConnectionTips() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Conseils de connexion'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Vérifiez votre connexion WiFi ou données mobiles'),
                SizedBox(height: 8),
                Text('• Assurez-vous d\'être connecté à internet'),
                SizedBox(height: 8),
                Text('• Redémarrez votre connexion si nécessaire'),
                SizedBox(height: 8),
                Text(
                  '• Contactez votre administrateur si le problème persiste',
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _loadCriticalTasks();
                },
                child: const Text('Réessayer'),
              ),
            ],
          ),
    );
  }

  Widget _buildEmptyWidget() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Colors.green[400]),
          const SizedBox(height: 16),
          Text(
            'Aucune tâche critique',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HexColor('#2C3E50'),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Toutes vos tâches critiques sont à jour !',
            style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList() {
    return Stack(
      children: [
        // Connecting lines
        if (_tasks!.length > 1)
          Positioned(
            left: 4,
            top: 14,
            child: CustomPaint(
              size: Size(2, _calculateTotalHeight()),
              painter: ConnectingLinesPainter(
                taskCount: _tasks!.length,
                itemHeight: 94,
              ),
            ),
          ),

        // Task items
        Column(
          children:
              _tasks!.asMap().entries.map((entry) {
                final index = entry.key;
                final task = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < _tasks!.length - 1 ? 20 : 0,
                  ),
                  child: _buildTaskItem(task),
                );
              }).toList(),
        ),
      ],
    );
  }

  double _calculateTotalHeight() {
    if (_tasks == null || _tasks!.length <= 1) return 0;
    return (_tasks!.length - 1) * 84.0;
  }

  Widget _buildTaskItem(Task task) {
    // Détermine le statut
    String badgeLabel;
    Color badgeColor;
    if (task.criticalStatus == TaskStatus.delayed) {
      badgeLabel = 'En retard';
      badgeColor = Color(0xFFEF4444);
    } else if (task.criticalStatus == TaskStatus.urgent) {
      badgeLabel = 'Urgent';
      badgeColor = Color(0xFFF59E42);
    } else {
      badgeLabel = 'À jour';
      badgeColor = Color(0xFF22C55E);
    }

    // Calcul du nombre de jours restants
    String echeanceText = 'Échéance : ${_formatDate(task.endDate)}';
    int? daysLeft = task.daysRemaining;
    if (daysLeft != null) {
      echeanceText += ' ($daysLeft j restants)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pastille
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getStatusColor(task.criticalStatus),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
          const SizedBox(width: 16),
          // Texte principal
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: HexColor('#34495E'),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  echeanceText,
                  style: TextStyle(fontSize: 12, color: HexColor('#7F8C8D')),
                ),
              ],
            ),
          ),
          // Badge à droite
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              badgeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.delayed:
        return const Color(0xFFDC2626); // Rouge
      case TaskStatus.urgent:
        return const Color(0xFFF59E0B); // Orange
      case TaskStatus.upToDate:
        return const Color(0xFF10B981); // Vert
      default:
        return const Color(0xFF6B7280); // Gris
    }
  }
}

class ConnectingLinesPainter extends CustomPainter {
  final int taskCount;
  final double itemHeight;

  ConnectingLinesPainter({required this.taskCount, required this.itemHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = HexColor('#F5F7FA')
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final double x = 6;
    // La barre tient sur la hauteur réelle du conteneur avec un léger dépassement
    final double lineHeight = size.height + 12;
    canvas.drawLine(Offset(x, 0), Offset(x, lineHeight), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
