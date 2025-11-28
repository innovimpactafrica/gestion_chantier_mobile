import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_bloc.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_event.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_state.dart';
import 'package:gestion_chantier/moa/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/moa/models/Study.dart';
import 'package:gestion_chantier/moa/models/study_comment.dart';
import 'package:gestion_chantier/moa/services/AuthService.dart';

/// Page de détails d'une étude BET
class EtudeDetailPage extends StatelessWidget {
  const EtudeDetailPage({super.key, required this.study});

  final Study study;

  @override
  Widget build(BuildContext context) {
    // Créer un nouveau bloc pour cette page pour s'assurer qu'il a tous les handlers
    return BlocProvider(
      create:
          (context) =>
              StudyRequestsBloc()
                ..add(LoadStudyComments(studyRequestId: int.parse(study.id))),
      child: _EtudeDetailPageContent(study: study),
    );
  }
}

class _EtudeDetailPageContent extends StatelessWidget {
  const _EtudeDetailPageContent({required this.study});

  final Study study;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A365D),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          study.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StudyHeader(study: study),
                const SizedBox(height: 24),
                if (study.status == StudyStatus.rejected) ...[
                  _RejectionSection(
                    reason: study.rejectionReason ?? 'Aucun motif spécifié',
                  ),
                ] else ...[
                  _ReportsSection(reports: study.reports),
                ],
                const SizedBox(height: 24),
                _CommentsSection(studyId: study.id),
              ],
            ),
          ),
          // Champ de saisie fixé en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _CommentsSectionInput(studyId: study.id),
          ),
        ],
      ),
    );
  }
}

class _StudyHeader extends StatelessWidget {
  const _StudyHeader({required this.study});
  final Study study;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  study.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(status: study.status),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            study.description,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Ligne orange de séparation
          Container(
            height: 3,
            width: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5A00),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                'Créé: ${_formatDate(study.createdAt)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.person_outline,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                'Assigné: ${study.assignedTo}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RejectionSection extends StatelessWidget {
  const _RejectionSection({required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(left: 16, right: 16),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Motif du rejet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF44336).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF44336).withOpacity(0.15),
              ),
            ),
            child: Text(
              reason,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF333333),
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportsSection extends StatelessWidget {
  const _ReportsSection({required this.reports});
  final List<Report> reports;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rapports produits(${reports.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 16),
          if (reports.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 48,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Aucun rapport',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...reports.map(
              (report) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ReportCard(report: report),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({required this.report});
  final Report report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.picture_as_pdf,
              color: Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    Text(
                      report.version,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Créé le ${_formatDateLong(report.createdAt)} • ${report.fileSize}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // TODO: Download or view report
            },
            icon: const Icon(
              Icons.download_outlined,
              color: Color(0xFF64748B),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final StudyStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: status.badgeBg(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.badgeFg(context),
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

String _formatDate(DateTime d) {
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  final day = d.day.toString().padLeft(2, '0');
  final month = months[d.month - 1];
  final year = d.year;
  return '$day/$month/$year';
}

String _formatDateLong(DateTime d) {
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];
  final day = d.day.toString().padLeft(2, '0');
  final month = months[d.month - 1];
  final year = d.year;
  return '$day/$month/$year';
}

/// Section des commentaires
class _CommentsSection extends StatefulWidget {
  const _CommentsSection({required this.studyId});
  final String studyId;

  @override
  State<_CommentsSection> createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<_CommentsSection> {
  final AuthService _authService = AuthService();
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
    context.read<StudyRequestsBloc>().add(
      LoadStudyComments(studyRequestId: int.parse(widget.studyId)),
    );
  }

  Future<void> _loadCurrentUserId() async {
    try {
      // Essayer d'abord avec HomeBloc si disponible
      try {
        final homeBloc = context.read<HomeBloc>();
        final homeState = homeBloc.state;
        if (homeState.currentUser != null && mounted) {
          setState(() {
            _currentUserId = homeState.currentUser!.id;
          });
          print('✅ User ID from HomeBloc: $_currentUserId');
          return;
        }
      } catch (e) {
        print('⚠️ HomeBloc not available: $e');
        // HomeBloc n'est pas disponible, continuer avec AuthService
      }

      // Utiliser AuthService
      final currentUser = await _authService.connectedUser();
      if (currentUser != null && mounted) {
        setState(() {
          // Gérer différents formats d'ID (int ou String)
          final userId = currentUser['id'];
          if (userId is int) {
            _currentUserId = userId;
          } else if (userId is String) {
            _currentUserId = int.tryParse(userId);
          } else {
            _currentUserId = null;
          }
          print('✅ User ID from AuthService: $_currentUserId');
          print('📋 Current user data: $currentUser');
        });
      } else {
        print('❌ No current user found');
      }
    } catch (e) {
      print('❌ Error loading current user ID: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<StudyRequestsBloc, StudyRequestsState>(
            builder: (context, state) {
              if (state is StudyCommentsLoaded) {
                return Text(
                  'Commentaires(${state.comments.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C3E50),
                  ),
                );
              }
              return const Text(
                'Commentaires',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2C3E50),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<StudyRequestsBloc, StudyRequestsState>(
            builder: (context, state) {
              if (state is StudyCommentsLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (state is StudyRequestsError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      state.message,
                      style: const TextStyle(color: Color(0xFFEF4444)),
                    ),
                  ),
                );
              }
              if (state is StudyCommentsLoaded) {
                // Recharger l'ID utilisateur si nécessaire quand les commentaires sont chargés
                if (_currentUserId == null) {
                  _loadCurrentUserId();
                }

                if (state.comments.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 48,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aucun commentaire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.comments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CommentCard(
                        comment: state.comments[index],
                        currentUserId: _currentUserId,
                      ),
                    );
                  },
                );
              }
              return Container();
            },
          ),
        ],
      ),
    );
  }
}

/// Widget séparé pour le champ de saisie de commentaire (fixé en bas)
class _CommentsSectionInput extends StatefulWidget {
  const _CommentsSectionInput({required this.studyId});
  final String studyId;

  @override
  State<_CommentsSectionInput> createState() => _CommentsSectionInputState();
}

class _CommentsSectionInputState extends State<_CommentsSectionInput> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _addComment() {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      return;
    }

    // Envoyer le commentaire
    context.read<StudyRequestsBloc>().add(
      AddStudyComment(
        studyRequestId: int.parse(widget.studyId),
        content: content,
      ),
    );

    // Vider le champ de texte
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return _CommentInput(controller: _commentController, onSubmit: _addComment);
  }
}

/// Widget pour afficher un commentaire
class _CommentCard extends StatelessWidget {
  const _CommentCard({required this.comment, this.currentUserId});
  final StudyComment comment;
  final int? currentUserId;

  bool get isCurrentUser {
    if (currentUserId == null) {
      print('⚠️ No currentUserId, comment authorId: ${comment.authorId}');
      return false;
    }
    // Comparaison robuste qui gère les types int
    final isMatch = comment.authorId == currentUserId;
    print(
      '🔍 Comparing: comment.authorId=${comment.authorId} vs currentUserId=$currentUserId => isMatch=$isMatch',
    );
    return isMatch;
  }

  @override
  Widget build(BuildContext context) {
    // Obtenir les initiales pour l'avatar (seulement si ce n'est pas l'utilisateur actuel)
    String initials = '??';
    if (!isCurrentUser && comment.authorName.isNotEmpty) {
      final parts = comment.authorName.trim().split(' ');
      if (parts.length >= 2) {
        initials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else if (parts[0].length >= 2) {
        initials = parts[0].substring(0, 2).toUpperCase();
      } else {
        initials = parts[0].toUpperCase();
      }
    }

    // Style pour les commentaires de l'utilisateur actuel (orange)
    final isUserComment = isCurrentUser;
    final backgroundColor =
        isUserComment
            ? const Color(0xFFFFF4E6) // Orange clair
            : Colors.white; // Blanc pour les autres
    final borderColor =
        isUserComment
            ? const Color(0xFFFF5A00).withOpacity(0.2) // Orange avec opacité
            : Colors.transparent; // Pas de bordure pour les autres
    final textColor =
        isUserComment
            ? const Color(0xFF1E293B) // Noir
            : const Color(0xFF1E293B); // Noir aussi pour les autres

    if (isUserComment) {
      // Message de l'utilisateur actuel - aligné à droite
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                border: Border.all(color: borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'auteur
                  Text(
                    'Vous',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Message
                  Text(
                    comment.content.isNotEmpty
                        ? comment.content
                        : 'Aucun contenu',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Date alignée à droite
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatCommentDate(comment.createdAt),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      // Message des autres - aligné à gauche avec avatar
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 15,
            backgroundColor: const Color(0xFFE5E7EB), // Gris clair
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF374151), // Gris foncé
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Contenu du commentaire
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),

                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'auteur
                  Text(
                    comment.authorName.isNotEmpty
                        ? comment.authorName
                        : 'Utilisateur',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Message
                  Text(
                    comment.content.isNotEmpty
                        ? comment.content
                        : 'Aucun contenu',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Date alignée à gauche
                  Text(
                    _formatCommentDate(comment.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }
}

/// Widget pour saisir un nouveau commentaire
class _CommentInput extends StatelessWidget {
  const _CommentInput({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Colors.white),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Ajouter un commentaire...',
                  hintStyle: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 1),
                ),
                style: const TextStyle(fontSize: 14, color: Color(0xFF777777)),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: () {
                // TODO: Attach file
              },
              icon: const Icon(
                Icons.attach_file_sharp,
                size: 22,
                color: Color(0xFF94A3B8),
              ),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(width: 4),

            IconButton(
              onPressed: onSubmit,
              icon: const Icon(Icons.send, size: 22, color: Color(0xFFFF5A00)),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCommentDate(DateTime date) {
  const months = [
    'janv.',
    'févr.',
    'mars',
    'avr.',
    'mai',
    'juin',
    'juil.',
    'août',
    'sept.',
    'oct.',
    'nov.',
    'déc.',
  ];

  final day = date.day.toString().padLeft(2, '0');
  final month = months[date.month - 1];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day $month, $hour:$minute';
}
