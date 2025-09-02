import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/models/RealEstateModel.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/CustomFloatingButton.dart';

enum StudyStatus { pending, inProgress, delivered, validated, rejected }

class StudyItem {
  final String title;
  final DateTime createdAt;
  final StudyStatus status;
  final IconData icon;
  final Color iconBg;

  StudyItem({
    required this.title,
    required this.createdAt,
    required this.status,
    required this.icon,
    required this.iconBg,
  });
}

class EtudeBetTab extends StatefulWidget {
  final RealEstateModel projet;

  const EtudeBetTab({super.key, required this.projet});

  @override
  State<EtudeBetTab> createState() => _EtudeBetTabState();
}

class _EtudeBetTabState extends State<EtudeBetTab> {
  StudyStatus? _filter; // null => Tous
  late List<StudyItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      StudyItem(
        title: 'Étude structure – Immeuble A',
        createdAt: DateTime(2025, 8, 12),
        status: StudyStatus.pending,
        icon: Icons.apartment_rounded,
        iconBg: const Color(0xFFF3F4F6),
      ),
      StudyItem(
        title: 'Étude acoustique —',
        createdAt: DateTime(2025, 7, 27),
        status: StudyStatus.inProgress,
        icon: Icons.layers_rounded,
        iconBg: const Color(0xFFFEF3C7),
      ),
      StudyItem(
        title: 'Étude A (réseaux CVC)',
        createdAt: DateTime(2025, 7, 5),
        status: StudyStatus.delivered,
        icon: Icons.ac_unit_rounded,
        iconBg: const Color(0xFFEDE9FE),
      ),
      StudyItem(
        title: 'Étude VRD – Centre commercial',
        createdAt: DateTime(2025, 7, 5),
        status: StudyStatus.validated,
        icon: Icons.holiday_village_rounded,
        iconBg: const Color(0xFFE8F5E9),
      ),
      StudyItem(
        title: 'Étude CVC – Tour bureaux',
        createdAt: DateTime(2025, 7, 5),
        status: StudyStatus.rejected,
        icon: Icons.ac_unit_rounded,
        iconBg: const Color(0xFFFFEBEE),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filtered =
        _filter == null
            ? _items
            : _items.where((e) => e.status == _filter).toList();

    return Scaffold(
      backgroundColor: HexColor('#F1F2F6'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 12),
            ...filtered.map(_buildStudyListItem),
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
    Widget buildChip(String label, StudyStatus? status) {
      final bool selected = _filter == status;
      return GestureDetector(
        onTap: () => setState(() => _filter = status),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: selected ? HexColor('#FF5C02') : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : HexColor('#0F172A'),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final List<Map<String, String?>> labels = const [
      {'label': 'Tous', 'key': null},
      {'label': 'En attente', 'key': 'pending'},
      {'label': 'En cours', 'key': 'inProgress'},
      {'label': 'Validées', 'key': 'validated'},
      {'label': 'Rejetées', 'key': 'rejected'},
    ];

    StudyStatus? _toStatus(String? key) {
      switch (key) {
        case 'pending':
          return StudyStatus.pending;
        case 'inProgress':
          return StudyStatus.inProgress;
        case 'validated':
          return StudyStatus.validated;
        case 'rejected':
          return StudyStatus.rejected;
        default:
          return null;
      }
    }

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        primary: false,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final label = labels[index]['label']!;
          final key = labels[index]['key'];
          final status = _toStatus(key);
          return buildChip(label, status);
        },
      ),
    );
  }

  Widget _buildStudyListItem(StudyItem item) {
    final statusText = _statusText(item.status);
    final statusColor = _statusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: HexColor('#1F2937'), size: 28),
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
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

  String _statusText(StudyStatus s) {
    switch (s) {
      case StudyStatus.pending:
        return 'En attente';
      case StudyStatus.inProgress:
        return 'En cours';
      case StudyStatus.delivered:
        return 'Livrée';
      case StudyStatus.validated:
        return 'Validée';
      case StudyStatus.rejected:
        return 'Rejetée';
    }
  }

  Color _statusColor(StudyStatus s) {
    switch (s) {
      case StudyStatus.pending:
        return HexColor('#1F2937');
      case StudyStatus.inProgress:
        return HexColor('#E3A008');
      case StudyStatus.delivered:
        return HexColor('#6366F1');
      case StudyStatus.validated:
        return HexColor('#22C55E');
      case StudyStatus.rejected:
        return HexColor('#EF4444');
    }
  }
}
