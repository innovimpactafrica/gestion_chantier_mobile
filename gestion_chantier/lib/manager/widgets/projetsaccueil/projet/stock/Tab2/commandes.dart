// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/l10n/app_localizations.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_bloc.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_event.dart';
import 'package:gestion_chantier/manager/bloc/commades/commandes_state.dart';
import 'package:gestion_chantier/manager/models/CommandeModel.dart';
import 'package:gestion_chantier/manager/models/MaterialMovementModel.dart';
import 'package:gestion_chantier/manager/models/MaterialModel.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/models/WorkerModel.dart';
import 'package:gestion_chantier/manager/services/AuthService.dart';
import 'package:gestion_chantier/manager/services/Materiaux_service.dart';
import 'package:gestion_chantier/manager/services/MovementsApiService.dart';
import 'package:gestion_chantier/manager/services/worker_service.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/stock/Tab2/add_commande_modal.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/stock/Tab2/add_material_modal.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class CommandesTab extends StatefulWidget {
  final RealEstateModel projet;
  const CommandesTab({super.key, required this.projet});

  @override
  _CommandesTabState createState() => _CommandesTabState();
}

class CommandesTabWrapper extends StatelessWidget {
  final RealEstateModel projet;
  const CommandesTabWrapper({super.key, required this.projet});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommandeBloc(),
      child: CommandesTab(projet: projet),
    );
  }
}

class _CommandesTabState extends State<CommandesTab> {
  List<MaterialMovementModel> _mouvements = [];

  @override
  void initState() {
    super.initState();
    context.read<CommandeBloc>().add(
      GetPendingOrdersEvent(propertyId: widget.projet.id),
    );
    _loadMouvements();
  }

  Future<void> _loadMouvements() async {
    try {
      final list = await MovementsApiService()
          .getMovementsByProperty(widget.projet.id);
      if (mounted) {
        setState(() {
          _mouvements = list.take(10).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _refresh() async {
    context.read<CommandeBloc>().add(
      RefreshOrdersEvent(propertyId: widget.projet.id),
    );
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
                AppLocalizations.of(context)!.commandesTitle,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: HexColor('#333333'),
                ),
              ),
              const SizedBox(height: 20),

              // ── Liste commandes ────────────────────────────────────
              BlocBuilder<CommandeBloc, CommandeState>(
                builder: (context, state) {
                  if (state is CommandeLoading) return _buildLoading();
                  if (state is CommandeError) return _buildError(state.message);
                  if (state is CommandeEmpty) return _buildEmpty();
                  if (state is CommandeLoaded) return _buildList(state.commandes);
                  if (state is CommandeAdded) return _buildList(state.allCommandes);
                  if (state is CommandeDeleted) return _buildList(state.allCommandes);
                  if (state is CommandeDuplicated) return _buildList(state.allCommandes);
                  if (state is CommandeUpdated) return _buildList(state.allCommandes);
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
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildMouvements(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: HexColor('#FF5C02'),
        onPressed: _ajouterCommande,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                  color: isEntry
                      ? const Color(0xFF10B981)
                      : const Color(0xFFDC2626),
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

  // ── Liste commandes ────────────────────────────────────────────────────────
  Widget _buildList(List<CommandeModel> commandes) {
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
        children: commandes.asMap().entries.map((entry) {
          final i = entry.key;
          final cmd = entry.value;
          return Column(
            children: [
              _buildCommandeTile(cmd),
              if (i < commandes.length - 1)
                Divider(height: 1, thickness: 1, color: HexColor('#F3F4F6')),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCommandeTile(CommandeModel commande) {
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
        'CMD-${commande.id.toString().padLeft(7, '0')}',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HexColor('#1F2937'),
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          commande.supplier.nom,
          style: TextStyle(fontSize: 13, color: HexColor('#6B7280')),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatutChip(_mapStatus(commande.status)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: HexColor('#9CA3AF'), size: 24),
        ],
      ),
      onTap: () => _ouvrirDetails(commande),
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
            onPressed: () => context.read<CommandeBloc>().add(
                  GetPendingOrdersEvent(propertyId: widget.projet.id),
                ),
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
          Icon(Icons.shopping_bag_outlined, size: 48, color: HexColor('#9CA3AF')),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.commandesEmpty,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: HexColor('#1F2937'),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.commandesEmptySubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: HexColor('#6B7280')),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  StatutCommande _mapStatus(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return StatutCommande.livree;
      case 'IN_TRANSIT':
        return StatutCommande.enLivraison;
      case 'PENDING':
        return StatutCommande.enAttente;
      case 'CANCELLED':
        return StatutCommande.annulee;
      default:
        return StatutCommande.enAttente;
    }
  }

  Widget _buildStatutChip(StatutCommande statut) {
    Color bg;
    Color fg;
    String label;
    switch (statut) {
      case StatutCommande.livree:
        bg = HexColor('#D1FAE5');
        fg = HexColor('#059669');
        label = AppLocalizations.of(context)!.commandesStatusDelivered;
        break;
      case StatutCommande.enLivraison:
        bg = HexColor('#DBEAFE');
        fg = HexColor('#2563EB');
        label = AppLocalizations.of(context)!.commandesStatusInTransit;
        break;
      case StatutCommande.enAttente:
        bg = HexColor('#FEF3C7');
        fg = HexColor('#D97706');
        label = AppLocalizations.of(context)!.commandesStatusPending;
        break;
      case StatutCommande.annulee:
        bg = HexColor('#FEE2E2');
        fg = HexColor('#DC2626');
        label = AppLocalizations.of(context)!.commandesStatusCancelled;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }

  void _ajouterCommande() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: BlocProvider.of<CommandeBloc>(context),
        child: AjouterCommandeModalContent(projet: widget.projet),
      ),
    );
    if (result == true) {
      context.read<CommandeBloc>().add(
            RefreshOrdersEvent(propertyId: widget.projet.id),
          );
    }
  }

  void _ouvrirDetails(CommandeModel commande) {
    final commandeBloc = context.read<CommandeBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => _CommandeDetailSheet(
          commande: commande,
          scrollController: scrollController,
          commandeBloc: commandeBloc,
          propertyId: widget.projet.id,
        ),
      ),
    );
  }
}

// ── Enums ──────────────────────────────────────────────────────────────────
enum StatutCommande { livree, enLivraison, enAttente, annulee }
enum TypeMouvementCommande { entree, sortie }

// ── Modal détail commande ──────────────────────────────────────────────────
class _CommandeDetailSheet extends StatelessWidget {
  final CommandeModel commande;
  final ScrollController scrollController;
  final CommandeBloc commandeBloc;
  final int propertyId;

  const _CommandeDetailSheet({
    required this.commande,
    required this.scrollController,
    required this.commandeBloc,
    required this.propertyId,
  });


  StatutCommande get _statut {
    switch (commande.status.toUpperCase()) {
      case 'DELIVERED': return StatutCommande.livree;
      case 'IN_TRANSIT': return StatutCommande.enLivraison;
      case 'CANCELLED': return StatutCommande.annulee;
      default: return StatutCommande.enAttente;
    }
  }

  int get _total =>
      commande.items.fold(0, (s, i) => s + i.quantity * i.unitPrice);

  String _formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy, HH:mm', 'fr_FR').format(dt);

  String _formatTotal(int total) =>
      NumberFormat('#,###', 'fr_FR').format(total).replaceAll(',', ' ');


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
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header : titre + badge ──────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          'CMD-${commande.id.toString().padLeft(7, '0')}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildBadge(_statut),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Infos ───────────────────────────────────────────
                  _infoRow('Fournisseur', commande.supplier.nom),
                  _infoRow(
                    'Date livraison souhaitée',
                    _formatDate(commande.orderDate),
                  ),
                  _infoRow(
                    'Total',
                    '${_formatTotal(_total)} Fcfa',
                    bold: true,
                  ),

                  const SizedBox(height: 24),

                  // ── Articles ────────────────────────────────────────
                  Row(
                    children: [
                      Icon(Icons.history, color: Colors.grey[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Articles',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  ...commande.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.materialLabel ??
                                'Matériau #${item.materialId}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Text(
                                '${item.quantity} unités',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                              ),
                              const SizedBox(width: 24),
                              Text(
                                '${item.unitPrice} FCFA * ${item.quantity}',
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          // ── Boutons bas ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20, 12, 20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
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
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => _openEditSheet(context),
                      child: const Text(
                        'Modifier',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: Builder(
                    builder: (btnCtx) => OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: orange, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () => _showMoreOptions(btnCtx),
                      child: Icon(Icons.more_horiz, color: orange),
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

  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditCommandeSheet(
        commande: commande,
        commandeBloc: commandeBloc,
        propertyId: propertyId,
      ),
    );
  }

  void _showMoreOptions(BuildContext btnCtx) {
    final RenderBox button = btnCtx.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(btnCtx)
        .overlay!
        .context
        .findRenderObject() as RenderBox;
    final Offset offset =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromLTRB(
      offset.dx,
      offset.dy - 160,
      overlay.size.width - offset.dx - button.size.width,
      overlay.size.height - offset.dy,
    );

    showMenu<String>(
      context: btnCtx,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      items: [
        PopupMenuItem(
          value: 'duplicate',
          child: Row(children: const [
            Icon(Icons.copy_outlined, color: Colors.grey, size: 20),
            SizedBox(width: 12),
            Text('Duppliquer',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'print',
          child: Row(children: const [
            Icon(Icons.print_outlined, color: Colors.grey, size: 20),
            SizedBox(width: 12),
            Text('Imprimer',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ]),
        ),
        const PopupMenuDivider(height: 1),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: const [
            Icon(Icons.close, color: Colors.red, size: 20),
            SizedBox(width: 12),
            Text('Supprimer',
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ],
    ).then((value) {
      if (value == 'duplicate') _duplicate(btnCtx);
      if (value == 'print') _print(btnCtx);
      if (value == 'delete') _confirmDelete(btnCtx);
    });
  }

  void _duplicate(BuildContext context) {
    commandeBloc.add(
      DuplicateOrderEvent(commande: commande, propertyId: propertyId),
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commande dupliquée avec succès')),
    );
  }

  Future<void> _print(BuildContext context) async {
    final total = commande.items
        .fold(0, (s, i) => s + i.quantity * i.unitPrice);
    final dateStr = DateFormat('d MMM yyyy, HH:mm', 'fr_FR')
        .format(commande.orderDate);

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'CMD-${commande.id.toString().padLeft(7, '0')}',
              style: pw.TextStyle(
                  fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 12),
            pw.Text('Fournisseur : ${commande.supplier.nom}'),
            pw.Text('Date livraison souhaitée : $dateStr'),
            pw.Text('Total : $total FCFA'),
            pw.SizedBox(height: 20),
            pw.Text('Articles :',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            ...commande.items.map(
              (item) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 6),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                        item.materialLabel ?? 'Matériau #${item.materialId}'),
                    pw.Text(
                        '${item.quantity} unités × ${item.unitPrice} FCFA'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'CMD-${commande.id.toString().padLeft(7, '0')}.pdf',
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la commande ?'),
        content: Text(
          'Voulez-vous vraiment supprimer CMD-${commande.id.toString().padLeft(7, '0')} ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // ferme dialog
              Navigator.pop(context); // ferme sheet
              commandeBloc.add(DeleteOrderEvent(
                orderId: commande.id,
                propertyId: propertyId,
              ));
            },
            child: const Text('Supprimer',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool bold = false}) {
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
            style: TextStyle(
              fontSize: 15,
              fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(StatutCommande statut) {
    Color bg;
    Color fg;
    String label;
    switch (statut) {
      case StatutCommande.livree:
        bg = const Color(0xFFD1FAE5); fg = const Color(0xFF059669); label = 'Livrée';
        break;
      case StatutCommande.enLivraison:
        bg = const Color(0xFFDBEAFE); fg = const Color(0xFF2563EB); label = 'En livraison';
        break;
      case StatutCommande.enAttente:
        bg = const Color(0xFFFEF3C7); fg = const Color(0xFFD97706); label = 'En attente';
        break;
      case StatutCommande.annulee:
        bg = const Color(0xFFFEE2E2); fg = const Color(0xFFDC2626); label = 'Annulée';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: fg)),
    );
  }
}

// ── Sheet "Edit commande" ──────────────────────────────────────────────────
class _EditCommandeSheet extends StatefulWidget {
  final CommandeModel commande;
  final CommandeBloc commandeBloc;
  final int propertyId;

  const _EditCommandeSheet({
    required this.commande,
    required this.commandeBloc,
    required this.propertyId,
  });

  @override
  State<_EditCommandeSheet> createState() => _EditCommandeSheetState();
}

class _EditCommandeSheetState extends State<_EditCommandeSheet> {
  late DateTime _deliveryDate;
  late List<_EditItem> _items;
  bool _isLoading = false;
  List<MaterialModel> _availableMaterials = [];
  bool _loadingMaterials = true;
  List<WorkerModel> _suppliers = [];
  bool _loadingSuppliers = true;
  WorkerModel? _selectedSupplier;

  @override
  void initState() {
    super.initState();
    _deliveryDate = widget.commande.orderDate;
    _items = widget.commande.items
        .map((i) => _EditItem(
              materialId: i.materialId,
              label: i.materialLabel ?? 'Matériau #${i.materialId}',
              quantity: i.quantity,
              unitPrice: i.unitPrice,
            ))
        .toList();
    _loadMaterials();
    _loadSuppliers();
  }

  Future<void> _loadMaterials() async {
    try {
      final mats = await MaterialsApiService().getMaterialsByProperty(widget.propertyId);
      if (mounted) setState(() { _availableMaterials = mats; _loadingMaterials = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingMaterials = false);
    }
  }

  Future<void> _loadSuppliers() async {
    try {
      final user = await AuthService().connectedUser();
      final managerId = user?['id'] ?? user?['promoterId'];
      if (managerId == null) { setState(() => _loadingSuppliers = false); return; }
      final suppliers = await WorkerService().getSubcontractors(managerId);
      if (mounted) {
        setState(() {
          _suppliers = suppliers;
          _selectedSupplier = suppliers.isEmpty
              ? null
              : suppliers.firstWhere(
                  (s) => s.id == widget.commande.supplier.id,
                  orElse: () => suppliers.first,
                );
          _loadingSuppliers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingSuppliers = false);
    }
  }

  int get _total => _items.fold(0, (s, i) => s + i.quantity * i.unitPrice);

  Future<void> _submit() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins un matériau')),
      );
      return;
    }
    setState(() => _isLoading = true);
    widget.commandeBloc.add(UpdateOrderEvent(
      orderId: widget.commande.id,
      supplierId: _selectedSupplier?.id ?? widget.commande.supplier.id,
      deliveryDate: _deliveryDate,
      items: _items
          .map((i) => {
                'materialId': i.materialId,
                'quantity': i.quantity,
                'unitPrice': i.unitPrice,
              })
          .toList(),
      propertyId: widget.propertyId,
    ));
    if (mounted) {
      Navigator.pop(context); // ferme edit sheet
      Navigator.pop(context); // ferme detail sheet
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commande mise à jour')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = HexColor('#FF5C02');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Titre + X
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Edit commande',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 26),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Fournisseur (dropdown)
              const Text('Fournisseur',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _loadingSuppliers
                  ? const SizedBox(
                      height: 52,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _suppliers.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[50],
                          ),
                          child: Text(
                            widget.commande.supplier.nom,
                            style: const TextStyle(fontSize: 15),
                          ),
                        )
                      : DropdownButtonFormField<WorkerModel>(
                          value: _selectedSupplier,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          items: _suppliers
                              .map((s) => DropdownMenuItem(
                                    value: s,
                                    child: Text('${s.nom} ${s.prenom}'),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedSupplier = v),
                        ),
              const SizedBox(height: 20),

              // Date de livraison souhaitée
              const Text('Date de livraison souhaitée',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deliveryDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _deliveryDate = picked);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_deliveryDate.day.toString().padLeft(2, '0')}/${_deliveryDate.month.toString().padLeft(2, '0')}/${_deliveryDate.year}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      Icon(Icons.calendar_month_outlined, color: Colors.grey[500]),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Matériaux ajoutés
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Matériaux ajoutés',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    width: 28, height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDC2626),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_items.length}',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Liste articles
              ..._items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('${item.quantity} unités',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13)),
                                const SizedBox(width: 16),
                                Text('${item.unitPrice} FCFA * ${item.quantity}',
                                    style: TextStyle(
                                        color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _items.removeAt(i)),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Color(0xFFDC2626), size: 20),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 4),

              // Bouton Ajouter un matériau
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.add, color: orange),
                  label: Text('Ajouter un matériau',
                      style: TextStyle(color: orange, fontWeight: FontWeight.w500)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: orange),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    backgroundColor: orange.withOpacity(0.05),
                  ),
                  onPressed: _loadingMaterials
                      ? null
                      : () async {
                          final result = await showAddMaterialModal(
                            context, _availableMaterials, widget.propertyId);
                          if (result != null) {
                            setState(() {
                              _items.add(_EditItem(
                                materialId: (result['material'] as MaterialModel).id,
                                label: (result['material'] as MaterialModel).label,
                                quantity: result['quantity'] as int,
                                unitPrice: result['unitPrice'] as int,
                              ));
                            });
                          }
                        },
                ),
              ),
              const SizedBox(height: 16),

              // Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total', style: TextStyle(color: Colors.grey[600])),
                    Text(
                      '${NumberFormat('#,###', 'fr_FR').format(_total).replaceAll(',', ' ')} F CFA',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Enregistrer
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A365D),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Enregistrer la commande',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditItem {
  final int materialId;
  final String label;
  int quantity;
  int unitPrice;
  _EditItem({
    required this.materialId,
    required this.label,
    required this.quantity,
    required this.unitPrice,
  });
}
