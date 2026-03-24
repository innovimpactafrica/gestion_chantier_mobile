// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/manager/bloc/delivery/delivery_bloc.dart';
import 'package:gestion_chantier/manager/bloc/delivery/delivery_event.dart';
import 'package:gestion_chantier/manager/bloc/delivery/delivery_state.dart';
import 'package:gestion_chantier/manager/models/DeliveryModel.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/services/CommandesService.dart';
import 'package:gestion_chantier/manager/services/MovementsApiService.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class LivraisonsTab extends StatefulWidget {
  final RealEstateModel projet;
  const LivraisonsTab({super.key, required this.projet});

  @override
  State<LivraisonsTab> createState() => _LivraisonsTabState();
}

class _LivraisonsTabState extends State<LivraisonsTab> {
  List<MaterialMovementModel> _mouvements = [];
  final Map<int, List<XFile>> _preuvesParLivraison = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<DeliveryBloc>().add(FetchDeliveries(widget.projet.id));
    });
    _loadMouvements();
  }

  Future<void> _loadMouvements() async {
    try {
      final list = await MovementsApiService().getMovementsByProperty(widget.projet.id);
      if (mounted) setState(() => _mouvements = list.take(10).toList());
    } catch (_) {}
  }

  Future<void> _refresh() async {
    context.read<DeliveryBloc>().add(FetchDeliveries(widget.projet.id));
    await _loadMouvements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor('#F8F9FA'),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(17, 25, 17, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ──────────────────────────────────────────────
              Text(
                'Livraisons',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: HexColor('#333333'),
                ),
              ),
              const SizedBox(height: 20),

              // ── Liste livraisons ───────────────────────────────────
              BlocBuilder<DeliveryBloc, DeliveryState>(
                builder: (context, state) {
                  if (state is DeliveryLoading) return _buildLoading();
                  if (state is DeliveryError) return _buildError(state.message);
                  if (state is DeliveryLoaded) {
                    if (state.deliveries.isEmpty) return _buildEmpty();
                    return _buildList(state.deliveries);
                  }
                  return _buildEmpty();
                },
              ),

              const SizedBox(height: 32),

              // ── Mouvements récents ─────────────────────────────────
              Row(
                children: [
                  Icon(Icons.history, color: Colors.grey[700], size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Mouvements récents',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMouvements(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Liste ──────────────────────────────────────────────────────────────────
  Widget _buildList(List<DeliveryModel> livraisons) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: livraisons.asMap().entries.map((entry) {
          final i = entry.key;
          final liv = entry.value;
          return Column(
            children: [
              _buildTile(liv),
              if (i < livraisons.length - 1)
                Divider(height: 1, thickness: 1, color: HexColor('#F3F4F6')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTile(DeliveryModel liv) {
    final statut = _mapStatus(liv.status);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: HexColor('#777777').withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          'assets/icons/sack.svg',
          width: 22,
          height: 22,
          color: HexColor('#777777'),
        ),
      ),
      title: Text(
        'LIV-${liv.orderDate.year}-${liv.id.toString().padLeft(3, '0')}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HexColor('#1F2937'),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          liv.supplier.nom,
          style: TextStyle(fontSize: 13, color: HexColor('#6B7280')),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBadge(statut),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: HexColor('#9CA3AF'), size: 24),
        ],
      ),
      onTap: () => _openDetail(liv),
    );
  }

  // ── Mouvements récents horizontal ──────────────────────────────────────────
  Widget _buildMouvements() {
    if (_mouvements.isEmpty) {
      return Container(
        height: 107,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Center(
          child: Text(
            'Aucun mouvement récent',
            style: TextStyle(fontSize: 14, color: HexColor('#6B7280')),
          ),
        ),
      );
    }

    return SizedBox(
      height: 107,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _mouvements.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => SizedBox(
          width: 220,
          child: _buildMouvementCard(_mouvements[i]),
        ),
      ),
    );
  }

  Widget _buildMouvementCard(MaterialMovementModel m) {
    final isEntry = m.type == MovementType.ENTRY;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final movDay = DateTime(m.movementDate.year, m.movementDate.month, m.movementDate.day);
    final time = DateFormat('HH:mm').format(m.movementDate);
    final dateStr = movDay == today
        ? "Aujourd'hui, $time"
        : DateFormat('d MMM, HH:mm', 'fr_FR').format(m.movementDate);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isEntry ? const Color(0xFF10B981) : const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEntry ? 'Entrée' : 'Sortie',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  m.material.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '${m.quantity.toInt()} ${m.material.unit.code} de ${m.material.label.toLowerCase()}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  // ── États ──────────────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(HexColor('#FF5C02')),
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: HexColor('#DC2626')),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(color: HexColor('#6B7280'))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#FF5C02'),
              foregroundColor: Colors.white,
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.local_shipping_outlined, size: 48, color: HexColor('#9CA3AF')),
          const SizedBox(height: 12),
          Text(
            'Aucune livraison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HexColor('#1F2937'),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aucune livraison trouvée pour ce projet',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: HexColor('#6B7280')),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  _StatutLivraison _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':   return _StatutLivraison.complete;
      case 'PARTIAL':     return _StatutLivraison.partielle;
      case 'CANCELLED':   return _StatutLivraison.annulee;
      case 'IN_TRANSIT':  return _StatutLivraison.enCours;
      default:            return _StatutLivraison.enAttente;
    }
  }

  Widget _buildBadge(_StatutLivraison statut) {
    Color bg; Color fg; String label;
    switch (statut) {
      case _StatutLivraison.complete:
        bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); label = 'Complète';
        break;
      case _StatutLivraison.partielle:
        bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); label = 'Partielle';
        break;
      case _StatutLivraison.annulee:
        bg = const Color(0xFFFEE2E2); fg = const Color(0xFFDC2626); label = 'Annulée';
        break;
      case _StatutLivraison.enCours:
        bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB); label = 'En cours';
        break;
      case _StatutLivraison.enAttente:
        bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280); label = 'En attente';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  void _openDetail(DeliveryModel liv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => _LivraisonDetailSheet(
          livraison: liv,
          scrollController: scrollController,
          preuves: _preuvesParLivraison[liv.id] ?? [],
          onPreuvesChanged: (photos) {
            setState(() => _preuvesParLivraison[liv.id] = List.from(photos));
          },
        ),
      ),
    );
  }
}

// ── Enum statut ────────────────────────────────────────────────────────────
enum _StatutLivraison { complete, partielle, annulee, enCours, enAttente }

// ── Bottom sheet détail ────────────────────────────────────────────────────
class _LivraisonDetailSheet extends StatefulWidget {
  final DeliveryModel livraison;
  final ScrollController scrollController;
  final List<XFile> preuves;
  final void Function(List<XFile>) onPreuvesChanged;

  const _LivraisonDetailSheet({
    required this.livraison,
    required this.scrollController,
    required this.preuves,
    required this.onPreuvesChanged,
  });

  @override
  State<_LivraisonDetailSheet> createState() => _LivraisonDetailSheetState();
}

class _LivraisonDetailSheetState extends State<_LivraisonDetailSheet> {
  late List<XFile> _preuves;

  @override
  void initState() {
    super.initState();
    _preuves = List.from(widget.preuves);
  }

  String get _numero =>
      'LIV-${widget.livraison.orderDate.year}-${widget.livraison.id.toString().padLeft(3, '0')}';

  String get _commandeNumero =>
      'COM-${widget.livraison.orderDate.year}-${widget.livraison.id.toString().padLeft(3, '0')}';

  _StatutLivraison get _statut {
    switch (widget.livraison.status.toUpperCase()) {
      case 'DELIVERED':  return _StatutLivraison.complete;
      case 'PARTIAL':    return _StatutLivraison.partielle;
      case 'CANCELLED':  return _StatutLivraison.annulee;
      case 'IN_TRANSIT': return _StatutLivraison.enCours;
      default:           return _StatutLivraison.enAttente;
    }
  }

  void _showMoreMenu(BuildContext btnCtx, Color orange) async {
    final box = btnCtx.findRenderObject() as RenderBox;
    final overlay = Overlay.of(btnCtx).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<String>(
      context: btnCtx,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 8,
      items: [
        _menuItem('add_preuve', Icons.note_add_outlined, 'Ajouter une preuve', Colors.black87),
        _menuDivider(),
        _menuItem('valider', Icons.checklist_outlined, 'Valider complète', Colors.black87),
        _menuDivider(),
        _menuItem('annuler', Icons.cancel_outlined, 'Annuler', const Color(0xFFDC2626)),
        _menuDivider(),
        _menuItem('pdf', Icons.picture_as_pdf_outlined, 'Générer un PDF', Colors.black87),
        _menuDivider(),
        _menuItem('probleme', Icons.warning_amber_rounded, 'Signaler un problème', const Color(0xFFDC2626)),
      ],
    );

    if (!mounted) return;
    switch (result) {
      case 'add_preuve':
        _openEditPreuve();
        break;
      case 'valider':
        _updateStatus('DELIVERED');
        break;
      case 'annuler':
        _updateStatus('CANCELLED');
        break;
      case 'pdf':
        _genererPdf();
        break;
      case 'probleme':
        _openSignalerProbleme();
        break;
    }
  }

  Future<void> _updateStatus(String status) async {
    final label = status == 'DELIVERED' ? 'Valider complète' : 'Annuler';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(label),
        content: Text(status == 'DELIVERED'
            ? 'Confirmer la livraison comme complète ?'
            : 'Confirmer l\'annulation de cette livraison ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Oui', style: TextStyle(
              color: status == 'DELIVERED' ? const Color(0xFF059669) : const Color(0xFFDC2626),
              fontWeight: FontWeight.bold,
            )),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await CommandeService().updateDeliveryStatus(widget.livraison.id, status);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(status == 'DELIVERED' ? 'Livraison validée' : 'Livraison annulée')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> _genererPdf() async {
    final numero = _numero;
    final livraison = widget.livraison;
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final doc = pw.Document();
        doc.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(numero,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text('Fournisseur : ${livraison.supplier.nom}'),
                pw.Text('Commande : ${'COM-${livraison.orderDate.year}-${livraison.id.toString().padLeft(3, '0')}'}'),
                pw.Text('Date : ${DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(livraison.orderDate)}'),
                pw.Text('Statut : ${livraison.status}'),
                pw.SizedBox(height: 20),
                pw.Text('Articles :',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 8),
                ...livraison.items.map((item) => pw.Text(
                  '  - Matériau #${item.materialId} : ${item.quantity} × ${item.unitPrice.toInt()} FCFA',
                )),
              ],
            ),
          ),
        );
        return doc.save();
      },
    );
  }

  void _openSignalerProbleme() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SignalerProblemeSheet(livraison: widget.livraison),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem<String>(
      value: value,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  PopupMenuDivider _menuDivider() => const PopupMenuDivider(height: 1);

  void _openEditPreuve() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditPreuveSheet(
        livraison: widget.livraison,
        initialPhotos: _preuves,
        onPhotosChanged: (photos) {
          if (mounted) setState(() => _preuves = List.from(photos));
          widget.onPreuvesChanged(photos);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = HexColor('#FF5C02');

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ───────────────────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: HexColor('#777777').withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/sack.svg',
                          width: 26,
                          height: 26,
                          color: HexColor('#777777'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _numero,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildBadge(_statut),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Infos ────────────────────────────────────────────
                  _infoRow('Fournisseur', widget.livraison.supplier.nom),
                  _infoRow('Commande', _commandeNumero),
                  _infoRow(
                    'Date livraison',
                    DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(widget.livraison.orderDate),
                  ),

                  const SizedBox(height: 24),

                  // ── Preuves ──────────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.photo_library_outlined, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Preuves',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_preuves.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Aucune preuve disponible',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _preuves.map((xfile) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(xfile.path),
                            width: 130,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),

          // ── Footer ───────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              16, 12, 16,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _openEditPreuve,
                      child: const Text(
                        'Modifier',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Builder(
                  builder: (btnCtx) => SizedBox(
                    width: 52,
                    height: 52,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: orange, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _showMoreMenu(btnCtx, orange),
                      child: Icon(Icons.more_horiz, color: orange, size: 22),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 15, color: Colors.grey[600])),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(_StatutLivraison statut) {
    Color bg; Color fg; String label;
    switch (statut) {
      case _StatutLivraison.complete:
        bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); label = 'Complète';
        break;
      case _StatutLivraison.partielle:
        bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); label = 'Partielle';
        break;
      case _StatutLivraison.annulee:
        bg = const Color(0xFFFEE2E2); fg = const Color(0xFFDC2626); label = 'Annulée';
        break;
      case _StatutLivraison.enCours:
        bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB); label = 'En cours';
        break;
      case _StatutLivraison.enAttente:
        bg = const Color(0xFFF3F4F6); fg = const Color(0xFF6B7280); label = 'En attente';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Edit Preuve Sheet ─────────────────────────────────────────────────────
class _EditPreuveSheet extends StatefulWidget {
  final DeliveryModel livraison;
  final List<XFile> initialPhotos;
  final void Function(List<XFile>) onPhotosChanged;

  const _EditPreuveSheet({
    required this.livraison,
    required this.initialPhotos,
    required this.onPhotosChanged,
  });

  @override
  State<_EditPreuveSheet> createState() => _EditPreuveSheetState();
}

class _EditPreuveSheetState extends State<_EditPreuveSheet> {
  late final List<XFile> _photos;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _photos = List.from(widget.initialPhotos);
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) setState(() => _photos.addAll(picked));
  }

  Future<void> _pickFromCamera() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _photos.add(picked));
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () { Navigator.pop(context); _pickFromCamera(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () { Navigator.pop(context); _pickFromGallery(); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = HexColor('#1A365D');
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40, height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Titre + fermer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Edit preuve',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 26),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Photos',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          // Zone ajout photo
          GestureDetector(
            onTap: _showPickerOptions,
            child: Container(
              width: double.infinity,
              height: 110,
              decoration: BoxDecoration(
                border: Border.all(
                    color: HexColor('#FF5C02'),
                    width: 1.5,
                    style: BorderStyle.solid),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded,
                      color: HexColor('#FF5C02'), size: 36),
                  const SizedBox(height: 6),
                  Text('Photo',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 14)),
                ],
              ),
            ),
          ),
          if (_photos.isNotEmpty) ...
            [
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _photos.asMap().entries.map((e) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(e.value.path),
                          width: 130,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.removeAt(e.key)),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle),
                            child: const Icon(Icons.cancel,
                                color: Color(0xFFDC2626), size: 22),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          const SizedBox(height: 24),
          // Bouton Enregistrer
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: _isSaving ? null : () async {
                setState(() => _isSaving = true);
                // TODO: appel API upload preuves
                await Future.delayed(const Duration(seconds: 1));
                if (mounted) {
                  widget.onPhotosChanged(_photos);
                  Navigator.pop(context);
                }
              },
              child: _isSaving
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Enregistrer',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Signaler Problème Sheet ──────────────────────────────────────────────────
class _SignalerProblemeSheet extends StatefulWidget {
  final DeliveryModel livraison;
  const _SignalerProblemeSheet({required this.livraison});

  @override
  State<_SignalerProblemeSheet> createState() => _SignalerProblemeSheetState();
}

class _SignalerProblemeSheetState extends State<_SignalerProblemeSheet> {
  final _titreCtrl = TextEditingController();
  final _commentaireCtrl = TextEditingController();
  final List<XFile> _photos = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titreCtrl.dispose();
    _commentaireCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) setState(() => _photos.addAll(picked));
  }

  Future<void> _pickFromCamera() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => _photos.add(picked));
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Prendre une photo'),
              onTap: () { Navigator.pop(context); _pickFromCamera(); },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () { Navigator.pop(context); _pickFromGallery(); },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = HexColor('#1A365D');
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey[300]!),
    );

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Signaler un problème',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 26),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Titre',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _titreCtrl,
              decoration: InputDecoration(
                hintText: 'Saisir',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: border,
                enabledBorder: border,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Commentaire',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentaireCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Saisir',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: border,
                enabledBorder: border,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Photos',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                width: double.infinity,
                height: 110,
                decoration: BoxDecoration(
                  border: Border.all(color: HexColor('#FF5C02'), width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_rounded, color: HexColor('#FF5C02'), size: 36),
                    const SizedBox(height: 6),
                    Text('Photo', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
            ),
            if (_photos.isNotEmpty) ...[  
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _photos.asMap().entries.map((e) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(File(e.value.path),
                            width: 130, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 4, right: 4,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.removeAt(e.key)),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.cancel,
                                color: Color(0xFFDC2626), size: 22),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : () async {
                  if (_titreCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Veuillez saisir un titre')),
                    );
                    return;
                  }
                  setState(() => _isSaving = true);
                  // TODO: appel API signalement
                  await Future.delayed(const Duration(seconds: 1));
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signalement envoyé')),
                    );
                  }
                },
                child: _isSaving
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Enregistrer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Classes conservées pour compatibilité ──────────────────────────────────
enum StatutLivraisonCommande { livree, enLivraison, enAttente, approuvee, refusee }
enum StatutLivraison { complete, partielle, enCours, annulee }
enum TypeMouvementLivraison { entree, sortie }

class Livraison {
  final String numero;
  final String fournisseur;
  final StatutLivraison statut;
  final IconData icone;
  final DateTime datePrevue;
  final DateTime? dateReelle;
  Livraison({
    required this.numero,
    required this.fournisseur,
    required this.statut,
    required this.icone,
    required this.datePrevue,
    this.dateReelle,
  });
}

class AjouterLivraisonScreen extends StatelessWidget {
  final RealEstateModel projet;
  const AjouterLivraisonScreen({super.key, required this.projet});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une livraison')),
      body: const Center(child: Text('Écran d\'ajout de livraison à implémenter')),
    );
  }
}
