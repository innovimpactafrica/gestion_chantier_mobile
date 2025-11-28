// ignore_for_file: unreachable_switch_default, deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gestion_chantier/manager/bloc/Indicator/ConstructionIndicatorBloc.dart';
import 'package:gestion_chantier/manager/bloc/Indicator/ConstructionIndicatorEvent.dart';
import 'package:gestion_chantier/manager/bloc/Indicator/ConstructionIndicatorState.dart';
import 'package:gestion_chantier/manager/models/AlbumModel.dart';
import 'package:gestion_chantier/manager/models/ConstructionPhaseIndicatorModel.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/services/AlbumService.dart';
import 'package:gestion_chantier/manager/services/ConstructionPhaseIndicator_service.dart';

import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/utils/constant.dart';

class VueGeneraleWidget extends StatefulWidget {
  final RealEstateModel projet;
  final VoidCallback? onRefresh;

  const VueGeneraleWidget({super.key, required this.projet, this.onRefresh});

  @override
  _VueGeneraleWidgetState createState() => _VueGeneraleWidgetState();
}

class _VueGeneraleWidgetState extends State<VueGeneraleWidget> {
  String selectedYear = '2025';
  final ProgressAlbumService _albumService = ProgressAlbumService();
  List<ProgressAlbum> _albums = [];
  bool _isLoadingAlbums = false;
  String? _albumsError;

  @override
  void initState() {
    super.initState();
    // Chargement initial des indicateurs
    context.read<ConstructionIndicatorBloc>().add(
      LoadIndicatorsByProperty(widget.projet.id),
    );
    // Chargement initial des albums
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    if (!mounted) return;
    setState(() {
      _isLoadingAlbums = true;
      _albumsError = null;
    });

    try {
      final albums = await _albumService.getAlbumsByProperty(widget.projet.id);
      if (!mounted) return;
      setState(() {
        _albums = albums;
        _isLoadingAlbums = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _albumsError = e.toString();
        _isLoadingAlbums = false;
        _albums = [];
      });
    }
  }

  // Méthode publique pour recharger les albums
  void reloadAlbums() {
    _loadAlbums();
    // Appeler le callback si fourni
    widget.onRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Section Vue graphique
        _buildGraphicView(),
        SizedBox(height: 32),
        // Section Albums
        _buildAlbumsSection(),
      ],
    );
  }

  Widget _buildGraphicView() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header avec titre et sélecteur d'année
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vue graphique',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedYear,
                    items:
                        ['2024', '2025', '2026'].map((String year) {
                          return DropdownMenuItem<String>(
                            value: year,
                            child: Text(
                              year,
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedYear = newValue;
                        });
                      }
                    },
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF666666),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Graphique en barres avec BlocBuilder
          BlocBuilder<ConstructionIndicatorBloc, ConstructionIndicatorState>(
            builder: (context, state) {
              if (state is ConstructionIndicatorLoading) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  ),
                );
              }

              if (state is ConstructionIndicatorError) {
                return SizedBox(
                  height: 200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        SizedBox(height: 16),
                        Text(
                          'Erreur de chargement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ConstructionIndicatorBloc>().add(
                              LoadIndicatorsByProperty(widget.projet.id),
                            );
                          },
                          child: Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ConstructionIndicatorLoaded ||
                  state is ConstructionIndicatorRefreshing ||
                  state is ConstructionIndicatorUpdating) {
                List<ConstructionPhaseIndicator> indicators = [];
                bool isLoading = false;

                if (state is ConstructionIndicatorLoaded) {
                  indicators = state.indicators;
                } else if (state is ConstructionIndicatorRefreshing) {
                  indicators = state.indicators;
                  isLoading = true;
                } else if (state is ConstructionIndicatorUpdating) {
                  indicators = state.indicators;
                  isLoading = true;
                }

                return Stack(
                  children: [
                    _buildBarChart(indicators),
                    if (isLoading)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                  ],
                );
              }

              // État par défaut avec des valeurs vides
              return _buildBarChart([]);
            },
          ),

          SizedBox(height: 16),

          // Bouton "Modifier les phases"
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F2), // Fond très clair orangé
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 47, vertical: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showEditPhasesDialog(context);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined, // Icône crayon
                    color: const Color(0xFFFF5C02),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mettre à jour les indicateurs',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF5C02),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<ConstructionPhaseIndicator> indicators) {
    // Fonction pour obtenir le pourcentage par phase
    double getProgressByPhase(PhaseType phase) {
      try {
        return indicators
            .firstWhere((indicator) => indicator.phaseName == phase)
            .progressPercentage
            .toDouble();
      } catch (e) {
        return 0.0; // Retourne 0 si la phase n'est pas trouvée
      }
    }

    // Fonction pour obtenir la couleur selon la phase
    Color getBarColor(PhaseType phase) {
      switch (phase) {
        case PhaseType.GROS_OEUVRE:
          return HexColor("#2ECC71"); // Vert pour Gros œuvre
        case PhaseType.SECOND_OEUVRE:
          return HexColor("#F39C12"); // Jaune pour Second œuvre
        case PhaseType.FINITION:
          return HexColor("#EAECF0"); // Gris pour Finition
        default:
          return Color(0xFFE8E8E8); // Couleur par défaut
      }
    }

    final grossOeuvreProgress = getProgressByPhase(PhaseType.GROS_OEUVRE);
    final secondOeuvreProgress = getProgressByPhase(PhaseType.SECOND_OEUVRE);
    final finitionProgress = getProgressByPhase(PhaseType.FINITION);

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          maxY: 120,
          minY: -20,
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: grossOeuvreProgress,
                  color: getBarColor(PhaseType.GROS_OEUVRE),
                  width: 80,
                  borderRadius: BorderRadius.circular(0),
                ),
              ],
            ),
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: secondOeuvreProgress,
                  color: getBarColor(PhaseType.SECOND_OEUVRE),
                  width: 80,
                  borderRadius: BorderRadius.circular(0),
                ),
              ],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: finitionProgress,
                  color: getBarColor(PhaseType.FINITION),
                  width: 80,
                  borderRadius: BorderRadius.circular(0),
                ),
              ],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 25,
                getTitlesWidget: (value, meta) {
                  const style = TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  );
                  switch (value.toInt()) {
                    case 0:
                      return Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Text('Gros œuvre', style: style),
                      );
                    case 1:
                      return Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Text('Second œuvre', style: style),
                      );
                    case 2:
                      return Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Text('Finition', style: style),
                      );
                    default:
                      return Text('');
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  if (value == 0 ||
                      value == 20 ||
                      value == 40 ||
                      value == 60 ||
                      value == 80 ||
                      value == 100) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 1.0),
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              // Lignes plus visibles pour 0 et 100
              if (value == -20 || value == 120) {
                return FlLine(color: Color(0xFFE0E0E0), strokeWidth: 2);
              }
              return FlLine(color: Color(0xFFF5F5F5), strokeWidth: 1.3);
            },
          ),
          borderData: FlBorderData(
            show: false, // Active les bordures pour mieux voir les limites
            border: Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              left: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.black87,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String label;
                switch (group.x) {
                  case 0:
                    label = 'Gros œuvre';
                    break;
                  case 1:
                    label = 'Second œuvre';
                    break;
                  case 2:
                    label = 'Finition';
                    break;
                  default:
                    label = '';
                }
                return BarTooltipItem(
                  '$label\n${rod.toY.toInt()}%',
                  TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Colors.grey[700],
                    size: 26,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Albums',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Bouton de rafraîchissement
              IconButton(
                onPressed: _isLoadingAlbums ? null : _loadAlbums,
                icon:
                    _isLoadingAlbums
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF4CAF50),
                          ),
                        )
                        : Icon(
                          Icons.refresh,
                          color: Colors.grey[600],
                          size: 24,
                        ),
                tooltip: 'Rafraîchir les albums',
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 140,
          child:
              _isLoadingAlbums
                  ? Center(
                    child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  )
                  : _albumsError != null
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Erreur de chargement',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _albumsError!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : _albums.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: Colors.grey[400],
                          size: 48,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Aucun album pour ce projet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ajoutez des albums pour suivre l\'avancement',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                  : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _albums.length,
                    separatorBuilder: (_, __) => SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      return _buildAlbumCard(_albums[index]);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildAlbumCard(ProgressAlbum album) {
    return GestureDetector(
      onTap: () => showAlbumDetailModal(context, album),
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
          image:
              album.pictures.isNotEmpty
                  ? DecorationImage(
                    image: NetworkImage(
                      '${APIConstants.API_BASE_URL_IMG}${album.pictures.first}',
                    ),
                    fit: BoxFit.cover,
                  )
                  : null,
          color: Colors.grey[300],
        ),
        child: Stack(
          children: [
            // Overlay foncé en bas
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            // Titre
            Positioned(
              left: 16,
              bottom: 48,
              child: Text(
                album.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Infos (date | nombre de photos)
            Positioned(
              left: 16,
              bottom: 16,
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    _formatShortDate(album.lastUpdatedDate),
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  // Séparateur vertical
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    width: 1,
                    height: 16,
                    color: Colors.white.withOpacity(0.7),
                  ),
                  Icon(Icons.image, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '${album.pictures.length.toString().padLeft(2, '0')} photos',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    // Format : 23/10/2024
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void showAlbumDetailModal(BuildContext context, ProgressAlbum album) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AlbumDetailModal(
          album: album,
          onAlbumDeleted: () {
            // Recharger les albums après suppression
            _loadAlbums();
          },
        );
      },
    );
  }

  void _showEditPhasesDialog(BuildContext context) {
    final bloc = context.read<ConstructionIndicatorBloc>();
    final indicatorService = ConstructionIndicatorService();
    List<ConstructionPhaseIndicator> currentIndicators = [];

    // Get current state
    if (bloc.state is ConstructionIndicatorLoaded) {
      currentIndicators =
          (bloc.state as ConstructionIndicatorLoaded).indicators;
    }

    // Initialize values with existing data or defaults
    final grosOeuvreIndicator = currentIndicators.firstWhere(
      (ind) => ind.phaseName == PhaseType.GROS_OEUVRE,
      orElse:
          () => ConstructionPhaseIndicator(
            id: -1,
            phaseName: PhaseType.GROS_OEUVRE,
            progressPercentage: 0,
            lastUpdated: DateTime.now(),
          ),
    );

    final secondOeuvreIndicator = currentIndicators.firstWhere(
      (ind) => ind.phaseName == PhaseType.SECOND_OEUVRE,
      orElse:
          () => ConstructionPhaseIndicator(
            id: -1,
            phaseName: PhaseType.SECOND_OEUVRE,
            progressPercentage: 0,
            lastUpdated: DateTime.now(),
          ),
    );

    final finitionIndicator = currentIndicators.firstWhere(
      (ind) => ind.phaseName == PhaseType.FINITION,
      orElse:
          () => ConstructionPhaseIndicator(
            id: -1,
            phaseName: PhaseType.FINITION,
            progressPercentage: 0,
            lastUpdated: DateTime.now(),
          ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Variables locales pour les valeurs des sliders
        double grosOeuvreValue =
            grosOeuvreIndicator.progressPercentage.toDouble();
        double secondOeuvreValue =
            secondOeuvreIndicator.progressPercentage.toDouble();
        double finitionValue = finitionIndicator.progressPercentage.toDouble();

        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 50,
                    height: 2,
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Indicateurs',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          _buildPhaseIndicator(
                            context,
                            title: 'Gros œuvre',
                            currentValue: grosOeuvreValue,
                            maxValue: 100,
                            color: HexColor("#FF5C02"),
                            onChanged: (value) {
                              setState(() {
                                grosOeuvreValue = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          _buildPhaseIndicator(
                            context,
                            title: 'Second œuvre',
                            currentValue: secondOeuvreValue,
                            maxValue: 100,
                            color: HexColor("#FF5C02"),
                            onChanged: (value) {
                              setState(() {
                                secondOeuvreValue = value;
                              });
                            },
                          ),
                          SizedBox(height: 10),
                          _buildPhaseIndicator(
                            context,
                            title: 'Finition',
                            currentValue: finitionValue,
                            maxValue: 100,
                            color: HexColor("#FF5C02"),
                            onChanged: (value) {
                              setState(() {
                                finitionValue = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom actions
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 1,
                      bottom: 30,
                      left: 20,
                      right: 20,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HexColor("#FF5C02"),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          try {
                            // Show loading indicator
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                    SizedBox(width: 16),
                                    Text('Mise à jour en cours...'),
                                  ],
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );

                            // Update indicators
                            if (grosOeuvreIndicator.id != -1) {
                              await indicatorService.updateIndicator(
                                grosOeuvreIndicator.id,
                                grosOeuvreValue.toInt(),
                              );
                            }
                            if (secondOeuvreIndicator.id != -1) {
                              await indicatorService.updateIndicator(
                                secondOeuvreIndicator.id,
                                secondOeuvreValue.toInt(),
                              );
                            }
                            if (finitionIndicator.id != -1) {
                              await indicatorService.updateIndicator(
                                finitionIndicator.id,
                                finitionValue.toInt(),
                              );
                            }

                            // Refresh indicators
                            bloc.add(
                              LoadIndicatorsByProperty(widget.projet.id),
                            );

                            Navigator.of(context).pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Indicateurs mis à jour avec succès',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Erreur lors de la mise à jour: $e',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPhaseIndicator(
    BuildContext context, {
    required String title,
    required double currentValue,
    required double maxValue,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la phase
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          // Slider avec style personnalisé et cercle blanc
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.grey[200],
              thumbColor: Colors.white, // Cercle blanc
              overlayColor: color.withOpacity(0.1),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
              trackHeight: 6,

              // Style personnalisé pour le cercle avec bordure
              valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: color,
              valueIndicatorTextStyle: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            child: Transform.translate(
              offset: Offset(
                -15,
                0,
              ), // Ajustez cette valeur pour plus/moins de décalage
              child: SizedBox(
                width: 500,
                child: Slider(
                  value: currentValue,
                  min: 0,
                  max: maxValue,
                  divisions: 100,
                  label: '${currentValue.toInt()}%',
                  onChanged: onChanged,
                ),
              ),
            ),
          ),

          // Row avec les pourcentages parfaitement alignés
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pourcentage actuel à gauche
                Text(
                  '${currentValue.toInt()}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                // 100% à droite
                Text(
                  '100%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumDetailModal extends StatefulWidget {
  final ProgressAlbum album;
  final VoidCallback onAlbumDeleted;
  const _AlbumDetailModal({required this.album, required this.onAlbumDeleted});
  @override
  State<_AlbumDetailModal> createState() => _AlbumDetailModalState();
}

class _AlbumDetailModalState extends State<_AlbumDetailModal> {
  int _currentPage = 0;
  late PageController _pageController;
  Timer? _autoScrollTimer;
  final ProgressAlbumService _albumService = ProgressAlbumService();
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    if (widget.album.pictures.length > 1) {
      _autoScrollTimer = Timer.periodic(Duration(seconds: 2), (timer) {
        if (!mounted || !_pageController.hasClients) {
          timer.cancel();
          return;
        }
          int nextPage = (_currentPage + 1) % widget.album.pictures.length;
          _pageController.animateToPage(
            nextPage,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
      });
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _deleteAlbum() async {
    // Afficher une boîte de dialogue de confirmation
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmer la suppression'),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer l\'album "${widget.album.name}" ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    setState(() {
      _isDeleting = true;
    });

    try {
      await _albumService.deleteAlbum(widget.album.id);

      if (mounted) {
        Navigator.pop(context); // Fermer le modal de détail
        widget.onAlbumDeleted(); // Appeler le callback pour recharger

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Album supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la suppression: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final album = widget.album;
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: 32 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  album.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.attach_file, size: 18, color: Colors.grey[700]),
              SizedBox(width: 4),
              Text(
                '${album.pictures.length} photos',
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
              SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[700]),
              SizedBox(width: 4),
              Text(
                _formatDate(album.lastUpdatedDate),
                style: TextStyle(fontSize: 15, color: Colors.grey[800]),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (album.pictures.isNotEmpty)
            Column(
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[100],
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: album.pictures.length,
                    onPageChanged: (i) {
                      if (mounted) {
                        setState(() => _currentPage = i);
                      }
                    },
                    itemBuilder: (context, i) {
                      return Image.network(
                        '${APIConstants.API_BASE_URL_IMG}${album.pictures[i]}',
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    album.pictures.length,
                    (i) => Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            i == _currentPage
                                ? Color(0xFFFF6B35)
                                : Colors.grey[300],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF6B35),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Modifier',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: _isDeleting ? null : _deleteAlbum,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFFFF6B35)),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isDeleting
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFFF6B35),
                            ),
                          )
                          : Text(
                            'Supprimer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format : Lun, 24 mars 2025
    final months = [
      "",
      "janv.",
      "févr.",
      "mars",
      "avr.",
      "mai",
      "juin",
      "juil.",
      "août",
      "sept.",
      "oct.",
      "nov.",
      "déc.",
    ];
    final days = ["Dim.", "Lun.", "Mar.", "Mer.", "Jeu.", "Ven.", "Sam."];
    return "${days[date.weekday % 7]} ${date.day.toString().padLeft(2, '0')} ${months[date.month]} ${date.year}";
  }
}
