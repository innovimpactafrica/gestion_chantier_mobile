import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/bet/widgets/etude_detail/projet_tab.dart';
import 'package:gestion_chantier/bet/widgets/etude_detail/rapports_tab.dart';
import 'package:gestion_chantier/bet/widgets/etude_detail/commentaires_tab.dart';
import 'package:gestion_chantier/bet/bloc/comments/comments_bloc.dart';
import 'package:gestion_chantier/bet/models/StudyModel.dart';

class BetEtudeDetailPage extends StatefulWidget {
  final Map<String, dynamic> study;
  final int currentUserId;

  const BetEtudeDetailPage({
    Key? key,
    required this.study,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<BetEtudeDetailPage> createState() => _BetEtudeDetailPageState();
}

class _BetEtudeDetailPageState extends State<BetEtudeDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommentsBloc(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          backgroundColor: HexColor('#1A365D'),
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          title: Text(
            widget.study['title'],
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              color: HexColor('#1A365D'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTab(0, 'assets/icons/projet.svg', 'Projet'),
                    _buildTab(1, 'assets/icons/rapport.svg', 'Rapports (2)'),
                    _buildTab(
                      2,
                      'assets/icons/comment.svg',
                      'Commentaires (3)',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            ProjetTab(study: widget.study),
            RapportsTab(
              reports: _convertReportsToList(widget.study['reports']),
              studyRequestId: widget.study['id'] ?? 0,
              authorId: widget.currentUserId,
              onReportAdded: () {
                // Le rafraîchissement est maintenant géré directement dans RapportsTab
                // Pas besoin de retourner à la liste des études
              },
            ),
            CommentairesTab(
              studyRequestId: widget.study['id'] ?? 0,
              currentUserId: widget.currentUserId,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String iconPath, String label) {
    final isSelected = _selectedIndex == index;
    final hasNotification = index == 2; // Commentaires a une notification

    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                SvgPicture.asset(
                  iconPath,
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.white : Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
                if (hasNotification)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 2,
                width: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<BetReportModel> _convertReportsToList(dynamic reportsData) {
    if (reportsData == null) {
      return [];
    }

    if (reportsData is List<BetReportModel>) {
      return reportsData;
    }

    if (reportsData is List) {
      return reportsData
          .map((report) {
            if (report is BetReportModel) {
              return report;
            }
            if (report is Map<String, dynamic>) {
              return BetReportModel.fromJson(report);
            }
            return BetReportModel.fromJson(report as Map<String, dynamic>);
          })
          .toList()
          .cast<BetReportModel>();
    }

    return [];
  }
}
