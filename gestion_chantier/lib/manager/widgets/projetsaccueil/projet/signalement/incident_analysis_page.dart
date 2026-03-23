import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gestion_chantier/manager/models/IncidentAnalysisModel.dart';
import 'package:gestion_chantier/manager/models/IncidentModel.dart';
import 'package:gestion_chantier/manager/services/IncidentService.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ─── Couleurs selon sévérité ──────────────────────────────────────────────────
Color severityColor(String severity) {
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      return const Color(0xFFB71C1C);
    case 'HIGH':
      return const Color(0xFFE53935);
    case 'MEDIUM':
      return const Color(0xFFF57C00);
    case 'LOW':
      return const Color(0xFF388E3C);
    default:
      return Colors.grey;
  }
}

String severityLabel(String severity) {
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      return 'Critique';
    case 'HIGH':
      return 'Élevé';
    case 'MEDIUM':
      return 'Moyen';
    case 'LOW':
      return 'Faible';
    default:
      return severity;
  }
}

// ─── Page principale ──────────────────────────────────────────────────────────
class IncidentAnalysisPage extends StatefulWidget {
  final IncidentModel incident;

  const IncidentAnalysisPage({super.key, required this.incident});

  @override
  State<IncidentAnalysisPage> createState() => _IncidentAnalysisPageState();
}

class _IncidentAnalysisPageState extends State<IncidentAnalysisPage> {
  IncidentAnalysisModel? _analysis;
  bool _isLoading = true;
  bool _isGenerating = false;
  String? _error;
  String _lang = 'fr';

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  Future<void> _loadAnalysis() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final analysis = await IncidentService().getIncidentRapport(widget.incident.id);
      if (mounted) setState(() { _analysis = analysis; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  Future<void> _generateRapport() async {
    setState(() { _isGenerating = true; });
    try {
      await IncidentService().generateIncidentRapport(widget.incident.id);
      await Future.delayed(const Duration(seconds: 3));
      await _loadAnalysis();
    } catch (e) {
      if (mounted) {
        setState(() { _isGenerating = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() { _isGenerating = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = HexColor('#1A365D');

    return Scaffold(
      backgroundColor: HexColor('#F5F7FA'),
      body: Column(
        children: [
          // ─── Header ───────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analyse d\'incident',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.incident.title,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (_analysis != null)
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/doc.svg',
                      width: 24,
                      height: 24,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    onPressed: () => _exportPdf(_analysis!),
                    tooltip: 'Exporter PDF',
                  ),
              ],
            ),
          ),

          // ─── Contenu ──────────────────────────────────────────────────────
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: primaryColor))
                : _error != null
                    ? _buildError()
                    : _analysis == null
                        ? _buildNoRapport()
                        : _buildContent(_analysis!),
          ),
        ],
      ),
    );
  }

  Widget _buildNoRapport() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/alert.svg', width: 72, height: 72,
                colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn)),
            const SizedBox(height: 20),
            Text(
              'Aucune analyse disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun rapport n\'a encore été généré pour cet incident.',
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateRapport,
              icon: _isGenerating
                  ? const SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : SvgPicture.asset('assets/icons/stat.svg', width: 18, height: 18,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              label: Text(_isGenerating ? 'Génération en cours...' : 'Générer l\'analyse IA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#1A365D'),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset('assets/icons/warning.svg', width: 64, height: 64,
                colorFilter: ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn)),
            const SizedBox(height: 16),
            Text('Impossible de charger l\'analyse',
                style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(fontSize: 13, color: Colors.grey[500]), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () { setState(() { _isLoading = true; _error = null; }); _loadAnalysis(); },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#1A365D'),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(IncidentAnalysisModel analysis) {
    final color = severityColor(analysis.severity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Carte infos générales ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        analysis.propertyName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C)),
                      ),
                    ),
                    _SeverityBadge(severity: analysis.severity),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SvgPicture.asset('assets/icons/alert.svg', width: 16, height: 16,
                        colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn)),
                    const SizedBox(width: 6),
                    Text(
                      analysis.incidentType,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                    SvgPicture.asset('assets/icons/calendar.svg', width: 16, height: 16,
                        colorFilter: ColorFilter.mode(Colors.grey[600]!, BlendMode.srcIn)),
                    const SizedBox(width: 6),
                    Text(
                      analysis.formattedDate,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ─── Sélecteur de langue ───────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                _LangTab(label: 'Français', value: 'fr', selected: _lang == 'fr', onTap: () => setState(() => _lang = 'fr')),
                _LangTab(label: 'English', value: 'en', selected: _lang == 'en', onTap: () => setState(() => _lang = 'en')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Section Explication ───────────────────────────────────────
          _IncidentHtmlSection(
            title: _lang == 'fr' ? 'EXPLICATION' : 'EXPLANATION',
            htmlContent: analysis.explanation[_lang] ?? '',
            accentColor: color,
            icon: Icons.info_outline,
          ),

          // ─── Section Recommandations ───────────────────────────────────
          _IncidentHtmlSection(
            title: _lang == 'fr' ? 'RECOMMANDATIONS' : 'RECOMMENDATIONS',
            htmlContent: analysis.recommendation[_lang] ?? '',
            accentColor: const Color(0xFFE53935),
            icon: Icons.warning_amber_rounded,
          ),

          const SizedBox(height: 8),

          // ─── Bouton Export PDF ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _exportPdf(analysis),
              icon: SvgPicture.asset('assets/icons/doc.svg', width: 18, height: 18,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
              label: Text(_lang == 'fr' ? 'Exporter en PDF' : 'Export as PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor('#1A365D'),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _exportPdf(IncidentAnalysisModel analysis) async {
    final color = severityColor(analysis.severity);
    final pdfColor = PdfColor.fromInt(color.value);
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('RAPPORT D\'INCIDENT',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: pdfColor)),
              pw.Text('ID: #${analysis.incidentId}',
                  style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: const pw.BoxDecoration(border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300))),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(analysis.propertyName, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
              pw.Text('Page ${ctx.pageNumber} / ${ctx.pagesCount}',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
            ],
          ),
        ),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(color.withOpacity(0.08).value),
              border: pw.Border.all(color: pdfColor),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(analysis.propertyName,
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: pw.BoxDecoration(color: pdfColor),
                      child: pw.Text(analysis.severity,
                          style: const pw.TextStyle(fontSize: 11, color: PdfColors.white)),
                    ),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Row(children: [
                  pw.Text('Type: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text(analysis.incidentType, style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(width: 24),
                  pw.Text('ID: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.Text('#${analysis.incidentId}', style: const pw.TextStyle(fontSize: 11)),
                ]),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          _pdfSection(
            title: _lang == 'fr' ? 'EXPLICATION' : 'EXPLANATION',
            htmlContent: analysis.explanation[_lang] ?? '',
            accentColor: pdfColor,
          ),
          pw.SizedBox(height: 16),
          _pdfSection(
            title: _lang == 'fr' ? 'RECOMMANDATIONS' : 'RECOMMENDATIONS',
            htmlContent: analysis.recommendation[_lang] ?? '',
            accentColor: PdfColors.red700,
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  pw.Widget _pdfSection({required String title, required String htmlContent, required PdfColor accentColor}) {
    final lines = htmlContent
        .replaceAllMapped(RegExp(r'<h3>(.*?)</h3>'), (m) => '\n###${m[1]}###\n')
        .replaceAllMapped(RegExp(r'<h4>(.*?)</h4>'), (m) => '\n##${m[1]}##\n')
        .replaceAllMapped(RegExp(r'<li>(.*?)</li>'), (m) => '- ${m[1]}\n')
        .replaceAll(RegExp(r'<ol>|</ol>|<ul>|</ul>|<div>|</div>'), '')
        .replaceAllMapped(RegExp(r'<p>(.*?)</p>'), (m) => '${m[1]}\n')
        .replaceAllMapped(RegExp(r'<strong>(.*?)</strong>'), (m) => m[1]!)
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: accentColor, width: 4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: accentColor,
            child: pw.Text(title, style: const pw.TextStyle(fontSize: 13, color: PdfColors.white)),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: lines.map((line) {
                if (line.startsWith('###') && line.endsWith('###')) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
                    child: pw.Text(line.replaceAll('###', ''),
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: accentColor)),
                  );
                }
                if (line.startsWith('##') && line.endsWith('##')) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 6, bottom: 2),
                    child: pw.Text(line.replaceAll('##', ''),
                        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                  );
                }
                if (line.trim().startsWith('- ')) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4, left: 8),
                    child: pw.Row(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          width: 5, height: 5,
                          margin: const pw.EdgeInsets.only(top: 5, right: 8),
                          decoration: pw.BoxDecoration(color: accentColor, shape: pw.BoxShape.circle),
                        ),
                        pw.Expanded(
                          child: pw.Text(line.trim().substring(2),
                              style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
                        ),
                      ],
                    ),
                  );
                }
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Text(line.trim(), style: const pw.TextStyle(fontSize: 11, lineSpacing: 2)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widget section HTML ──────────────────────────────────────────────────────
class _IncidentHtmlSection extends StatelessWidget {
  final String title;
  final String htmlContent;
  final Color accentColor;
  final IconData icon;

  const _IncidentHtmlSection({
    required this.title,
    required this.htmlContent,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accentColor, size: 18),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accentColor)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Html(
              data: htmlContent,
              style: {
                'h3': Style(fontSize: FontSize(13), fontWeight: FontWeight.bold, color: accentColor,
                    margin: Margins.only(top: 12, bottom: 4)),
                'h4': Style(fontSize: FontSize(12), fontWeight: FontWeight.bold, color: Colors.black54,
                    margin: Margins.only(top: 8, bottom: 4)),
                'p': Style(fontSize: FontSize(13), lineHeight: LineHeight(1.6), color: Colors.black87),
                'li': Style(fontSize: FontSize(13), lineHeight: LineHeight(1.6), color: Colors.black87,
                    margin: Margins.only(bottom: 4)),
                'strong': Style(fontWeight: FontWeight.bold, color: Colors.black),
                'ul': Style(margin: Margins.only(left: 8)),
                'ol': Style(margin: Margins.only(left: 8)),
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Badge sévérité ───────────────────────────────────────────────────────────
class _SeverityBadge extends StatelessWidget {
  final String severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = severityColor(severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 6),
          Text(severityLabel(severity),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ─── Onglet langue ────────────────────────────────────────────────────────────
class _LangTab extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _LangTab({required this.label, required this.value, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? HexColor('#1A365D') : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
