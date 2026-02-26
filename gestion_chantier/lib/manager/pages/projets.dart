// pages/projets_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/projet/projet_bloc.dart';
import 'package:gestion_chantier/manager/bloc/projet/projet_event.dart';
import 'package:gestion_chantier/manager/bloc/projet/projet_state.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/repository/RealEstateKpiRepository.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/navitems_projet.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet_card.dart';
import 'package:gestion_chantier/manager/widgets/rstate/CreateRealEstateModal.dart';
import 'package:gestion_chantier/ouvrier/utils/ToastUtils.dart';

import '../../shared/utils/constant.dart';
import '../utils/url_launcher.dart';

class ProjetsPage extends StatefulWidget {
  final int currentUserId;
  final String profil;

  const ProjetsPage(
      {super.key, required this.currentUserId, required this.profil});

  @override
  _ProjetsPageState createState() => _ProjetsPageState();
}

class _ProjetsPageState extends State<ProjetsPage> {
  TextEditingController searchController = TextEditingController();
  late ProjetsBloc _projetsBloc;

  @override
  void initState() {
    super.initState();
    _projetsBloc = ProjetsBloc(promoterId: widget.currentUserId);
    _projetsBloc.add(LoadProjetsEvent());
    searchController.addListener(_onSearchChanged);
  }


  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _projetsBloc.add(SearchProjetsEvent(searchController.text));
  }

  void _onProjetTap(RealEstateModel projet) {
    if (projet.blocked) {
      ToastUtils.show(
          'Le créateur du projet doit renouveler son abonnement pour débloquer les fonctionnalités.'
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MainProjectScreenWrapper(projet: projet),
        ),
      );
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Rechercher un projet'),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Nom ou lieu du projet...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _projetsBloc,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor:  Theme.of(context).primaryColor,
          child: Icon(Icons.add_outlined, color: Colors.white,),
          onPressed: () async {
            // 1️⃣ Vérifier si l'utilisateur peut créer un projet
            final canCreate = await RealEstateKpiRepository()
                .checkCanCreateProject(widget.currentUserId);

            if (!canCreate) {
              // 2️⃣ Si non, afficher un pop-up pour proposer l'abonnement
              showDialog(
                context: context,
                builder: (ctx) =>
                    AlertDialog(
                      title: const Text("Abonnement requis"),
                      content: const Text(
                          "Vous devez vous abonner pour pouvoir créer un chantier."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Annuler"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx); // fermer le dialog
                            UrlLauncher().openWebLink(
                                '${BTPConst.BASE_LINK}/sub/${widget
                                    .currentUserId}/${widget.profil}');
                          },
                          child: const Text(
                            "S'abonner",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );
              return; // ne pas ouvrir le BottomSheet
            }

            // 3️⃣ Si oui, ouvrir le BottomSheet pour créer le projet
            final result = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              builder: (_) =>
                  CreateRealEstateBottomSheet(
                    promoterId: widget.currentUserId,
                    profil: widget.profil,
                  ),
            );

            if (result == true) {
              _projetsBloc.add(RefreshProjetsEvent());
              await _projetsBloc.stream.firstWhere(
                    (state) => state is! ProjetsLoadingState,
              );
            }
          },
        ),


        backgroundColor: HexColor('#F5F7FA'),
        appBar: _buildAppBar(),
        body: BlocConsumer<ProjetsBloc, ProjetsState>(
          listener: (context, state) {
            if (state is ProjetsErrorState) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProjetsLoadingState) {
              return Center(child: CircularProgressIndicator());
            } else if (state is ProjetsLoadedState) {
              return _buildProjectsList(state.filteredProjets);
            } else if (state is ProjetsErrorState) {
              return _buildErrorWidget(state.message);
            }
            return Center(child: Text('Aucun projet disponible'));
          },
        ),
      ),);
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Container(
        alignment: Alignment.centerLeft,
        // margin: EdgeInsets.only(right: 210),
        child: Text(
          'Projets',
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      backgroundColor: HexColor('#1A365D'),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white, size: 28),
          onPressed: _showSearchDialog,
        ),
      ],
    );
  }

  Widget _buildProjectsList(List<RealEstateModel> projets) {
    if (projets.isEmpty) {
      return Center(child: Text('Aucun projet trouvé'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        _projetsBloc.add(RefreshProjetsEvent());
        await _projetsBloc.stream.firstWhere(
              (state) => state is! ProjetsLoadingState,
        );
      },
      child: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (projets.isNotEmpty)
            MainProjetCard(
              projet: projets.first,
              onTap: () => _onProjetTap(projets.first),
            ),
          SizedBox(height: 16),
          ...projets
              .skip(1)
              .map(
                (projet) =>
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: SecondaryProjetCard(
                    projet: projet,
                    onTap: () => _onProjetTap(projet),
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _projetsBloc.add(LoadProjetsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: HexColor('#1A365D'),
              foregroundColor: Colors.white,
            ),
            child: Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}
