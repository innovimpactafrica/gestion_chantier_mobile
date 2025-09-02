import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/incidents/incidents_bloc.dart';
import 'package:gestion_chantier/manager/models/RealEstateModel.dart';
import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/CustomFloatingButton.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/signalement/incidents_list.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/appbar.dart';
import 'package:gestion_chantier/manager/widgets/projetsaccueil/projet/signalement/addsignalement.dart';

class SignalementsPage extends StatelessWidget {
  final RealEstateModel? projet;

  const SignalementsPage({super.key, this.projet});

  @override
  Widget build(BuildContext context) {
    // ATTENTION : Ce widget suppose que BlocProvider<IncidentsBloc> est déjà présent dans le parent !
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomProjectAppBar(
            title: projet?.name ?? 'Signalements',
            onBackPressed: () => Navigator.of(context).pop(),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: Colors.white, size: 20),
                tooltip: 'Rechercher des signalements',
                onPressed: () {
                  final bloc = BlocProvider.of<IncidentsBloc>(context);
                  final state = bloc.state;
                  if (state is IncidentsLoaded) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (context) => SignalementSearchPage(
                              incidents: state.incidents,
                            ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Les signalements ne sont pas encore chargés.',
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'Signalements',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(child: IncidentsListWidget(propertyId: projet?.id ?? 0)),
        ],
      ),
      floatingActionButton: Builder(
        builder:
            (fabContext) => CustomFloatingButton(
              imagePath: 'assets/icons/plus.svg',
              onPressed: () async {
                await AddSignalementModal.show(
                  fabContext,
                  propertyId: projet?.id ?? 0,
                );
                final bloc = BlocProvider.of<IncidentsBloc>(fabContext);
                bloc.add(RefreshIncidentsEvent(propertyId: projet?.id ?? 0));
              },
              label: '',
              backgroundColor: HexColor('#FF5C02'),
              elevation: 4.0,
            ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class SignalementSearchPage extends StatefulWidget {
  final List incidents;
  const SignalementSearchPage({super.key, required this.incidents});

  @override
  State<SignalementSearchPage> createState() => _SignalementSearchPageState();
}

class _SignalementSearchPageState extends State<SignalementSearchPage> {
  String searchQuery = '';
  late List filteredIncidents;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    filteredIncidents = widget.incidents;
    _controller = TextEditingController();
  }

  void _filterIncidents(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredIncidents = widget.incidents;
      } else {
        filteredIncidents =
            widget.incidents
                .where(
                  (incident) => incident.title.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: HexColor('#1A365D'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: Colors.white, fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Rechercher ici',
            hintStyle: TextStyle(color: Colors.white70, fontSize: 22),
            border: InputBorder.none,
          ),
          onChanged: _filterIncidents,
        ),
      ),
      body:
          searchQuery.isEmpty
              ? Container()
              : (filteredIncidents.isEmpty
                  ? Center(child: Text('Aucun signalement trouvé'))
                  : ListView.builder(
                    itemCount: filteredIncidents.length,
                    itemBuilder: (context, index) {
                      final incident = filteredIncidents[index];
                      return ListTile(title: Text(incident.title));
                    },
                  )),
    );
  }
}
