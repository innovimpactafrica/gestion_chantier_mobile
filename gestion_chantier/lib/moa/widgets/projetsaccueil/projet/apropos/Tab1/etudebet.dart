import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_bloc.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_event.dart';
import 'package:gestion_chantier/moa/bloc/study_requests/study_requests_state.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/models/study_request.dart'
    as request_models;
import 'package:gestion_chantier/moa/models/Study.dart' as study_models;
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/apropos/Tab1/etude_detail_page.dart';

class EtudeBetTabWrapper extends StatelessWidget {
  final RealEstateModel projet;
  const EtudeBetTabWrapper({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              StudyRequestsBloc()
                ..add(LoadStudyRequests(propertyId: projet.id)),
      child: EtudeBetTab(projet: projet),
    );
  }
}

class EtudeBetTab extends StatefulWidget {
  final RealEstateModel projet;

  const EtudeBetTab({super.key, required this.projet});

  @override
  State<EtudeBetTab> createState() => _EtudeBetTabState();
}

class _EtudeBetTabState extends State<EtudeBetTab>
    with AutomaticKeepAliveClientMixin {
  String? _filter;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: HexColor('#F1F2F6'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<StudyRequestsBloc, StudyRequestsState>(
                builder: (context, state) {
                  if (state is StudyRequestsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is StudyRequestsError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is StudyRequestsLoaded) {
                    final filtered =
                        _filter == null
                            ? state.studyRequests
                            : state.studyRequests
                                .where((e) => e.status == _filter)
                                .toList();

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 90),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        return _buildStudyRequestListItem(filtered[index]);
                      },
                    );
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingButton(
        imagePath: 'assets/icons/plus.svg',
        onPressed: () {},
        label: '',
        backgroundColor: HexColor('#FF5C02'),
        elevation: 4.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildFilters() {
    Widget buildChip(String label, String? status) {
      final bool selected = _filter == status;
      final Color statusColor =
          status != null ? _statusColorFromString(status) : HexColor('#FF5C02');

      return GestureDetector(
        onTap: () => setState(() => _filter = status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: selected ? statusColor : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  selected
                      ? Colors.white
                      : (status != null ? statusColor : HexColor('#0F172A')),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final List<Map<String, String?>> labels = const [
      {'label': 'Tous', 'key': null},
      {'label': 'En attente', 'key': 'PENDING'},
      {'label': 'En cours', 'key': 'IN_PROGRESS'},
      {'label': 'Livrée', 'key': 'DELIVERED'},
      {'label': 'Validées', 'key': 'VALIDATED'},
      {'label': 'Rejetées', 'key': 'REJECTED'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children:
            labels.map((labelData) {
              final label = labelData['label']!;
              final key = labelData['key'];
              return buildChip(label, key);
            }).toList(),
      ),
    );
  }

  Widget _buildStudyRequestListItem(request_models.StudyRequest item) {
    final statusText = _statusTextFromString(item.status);
    final statusColor = _statusColorFromString(item.status);
    return GestureDetector(
      onTap: () => _navigateToStudyDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description,
                color: HexColor('#1F2937'),
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: HexColor('#163B64'),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Créé le ${_formatDate(item.createdAt)}.',
                    style: TextStyle(fontSize: 14, color: HexColor('#64748B')),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to study detail page
  void _navigateToStudyDetail(request_models.StudyRequest studyRequest) {
    // Convert StudyRequest to Study for the detail page
    final study = _convertStudyRequestToStudy(studyRequest);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: BlocProvider.of<StudyRequestsBloc>(context),
          child: EtudeDetailPage(study: study),
        ),
      ),
    );
  }

  /// Convert StudyRequest to Study model
  study_models.Study _convertStudyRequestToStudy(
    request_models.StudyRequest studyRequest,
  ) {
    // Convert status string to StudyStatus enum
    study_models.StudyStatus status;
    switch (studyRequest.status) {
      case 'PENDING':
        status = study_models.StudyStatus.pending;
        break;
      case 'IN_PROGRESS':
        status = study_models.StudyStatus.inProgress;
        break;
      case 'DELIVERED':
        status = study_models.StudyStatus.delivered;
        break;
      case 'VALIDATED':
        status = study_models.StudyStatus.validated;
        break;
      case 'REJECTED':
        status = study_models.StudyStatus.rejected;
        break;
      default:
        status = study_models.StudyStatus.pending;
    }

    // Convert reports from StudyRequest.Report to Study.Report
    final convertedReports =
        studyRequest.reports.map((report) {
          return study_models.Report(
            id: report.id.toString(),
            title: report.title,
            version: 'v${report.versionNumber}',
            createdAt: report.submittedAt,
            fileSize: _getFormattedFileSize(
              report.fileUrl,
            ), // Estimate file size
            fileUrl: report.fileUrl,
            mimeType: 'application/pdf', // Default to PDF
            studyId: studyRequest.id.toString(),
          );
        }).toList();

    return study_models.Study(
      id: studyRequest.id.toString(),
      title: studyRequest.title,
      description: studyRequest.description,
      type:
          study_models
              .StudyType
              .structure, // Default type, can be enhanced later
      status: status,
      createdAt: studyRequest.createdAt,
      assignedTo: studyRequest.betName,
      reports: convertedReports,
      projectId: studyRequest.propertyId.toString(),
    );
  }

  /// Get formatted file size (estimated)
  String _getFormattedFileSize(String fileUrl) {
    // This is a placeholder - in real app, you'd get actual file size
    return '2.1 MB';
  }

  String _formatDate(DateTime d) {
    const months = [
      '',
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
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]}';
  }

  String _statusTextFromString(String status) {
    switch (status) {
      case 'PENDING':
        return 'En attente';
      case 'IN_PROGRESS':
        return 'En cours';
      case 'VALIDATED':
        return 'Validée';
      case 'REJECTED':
        return 'Rejetée';
      case 'DELIVERED':
        return 'Livrée';
      default:
        return status;
    }
  }

  Color _statusColorFromString(String status) {
    switch (status) {
      case 'PENDING':
        return HexColor('#1F2937');
      case 'IN_PROGRESS':
        return HexColor('#E3A008');
      case 'VALIDATED':
        return HexColor('#22C55E');
      case 'REJECTED':
        return HexColor('#EF4444');
      case 'DELIVERED':
        return HexColor('#6366F1');
      default:
        return Colors.grey;
    }
  }
}
