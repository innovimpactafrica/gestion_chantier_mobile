import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class StudiesSummaryGrid extends StatelessWidget {
  final int pendingCount;
  final int inProgressCount;
  final int validatedCount;
  final int rejectedCount;

  const StudiesSummaryGrid({
    super.key,
    required this.pendingCount,
    required this.inProgressCount,
    required this.validatedCount,
    required this.rejectedCount,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final TextStyle titleStyle = TextStyle(
      color: HexColor('#1A365D'),
      fontSize: 20,
      fontWeight: FontWeight.w700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.85,
          ),
          children: [
            _StatCard(
              color: HexColor('#FF5C02'),
              value: pendingCount,
              label: 'Études en attente',
            ),
            _StatCard(
              color: HexColor('#FF5C02'),
              value: inProgressCount,
              label: 'Études en cours',
            ),
            _StatCard(
              color: HexColor('#FF5C02'),
              value: validatedCount,
              label: 'Études validées',
            ),
            _StatCard(
              color: HexColor('#FF5C02'),
              value: rejectedCount,
              label: 'Études rejetées',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color color;
  final int value;
  final String label;

  const _StatCard({
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              height: 0.9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: HexColor('#777777'),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
