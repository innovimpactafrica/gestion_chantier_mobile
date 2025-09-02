// widgets/stock_alerts_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gestion_chantier/manager/models/material_kpi.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';

class StockAlertsWidget extends StatelessWidget {
  final int alertCount;
  final List<StockItem> stockItems;

  const StockAlertsWidget({
    super.key,
    required this.alertCount,
    required this.stockItems,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          child: Row(
            children: [
              Container(
                child: SvgPicture.asset(
                  'assets/icons/warning.svg',
                  height: 20,
                  width: 20,
                  color: HexColor('#333333'),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Alertes stock matériaux',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: HexColor('#333333'),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  alertCount.toString(),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: HexColor('#777777'),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF9E9E9E),
                  size: 22,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Stock Items - Scroll horizontal
        SizedBox(
          height: 106,
          child:
              stockItems.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: stockItems.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 220,
                        margin: EdgeInsets.only(
                          right: index < stockItems.length - 1 ? 16 : 0,
                        ),
                        child: _buildStockCard(stockItems[index]),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      height: 106,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 32, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Aucune alerte de stock',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockCard(StockItem item) {
    return Container(
      padding: const EdgeInsets.only(left: 13, top: 13, right: 13, bottom: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with status and site
          Row(
            children: [
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getStatusText(item.status),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              // Site ID
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: HexColor('#F8F9FA'),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  item.propertyName,
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor('#666666'),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Material name
          Text(
            item.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Stock quantity
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${item.quantity} ${item.unitName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const TextSpan(
                  text: ' / seuil: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: '${item.criticalThreshold} ${item.unitName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StockStatus status) {
    switch (status) {
      case StockStatus.critique:
        return const Color(0xFFEF4444); // Rouge
      case StockStatus.faible:
        return const Color(0xFFF59E0B); // Orange
      case StockStatus.normal:
        return const Color(0x1F10B981); // Vert
    }
  }

  String _getStatusText(StockStatus status) {
    switch (status) {
      case StockStatus.critique:
        return 'Critique';
      case StockStatus.faible:
        return 'Faible';
      case StockStatus.normal:
        return 'Normal';
    }
  }
}
