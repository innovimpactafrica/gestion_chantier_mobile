import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/incidents/incidents_bloc.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/projetsaccueil/projet/signalement/incidents_list.dart';

class SignalementsPage extends StatelessWidget {
  final int propertyId;
  final String propertyName;

  const SignalementsPage({
    super.key,
    required this.propertyId,
    required this.propertyName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncidentsBloc(),
      child: Scaffold(
        backgroundColor: HexColor('#F5F7FA'),
        body: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 10,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: HexColor('#1A365D'),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Signalements',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          propertyName,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Contenu principal
            Expanded(child: IncidentsListWidget(propertyId: propertyId)),
          ],
        ),
      ),
    );
  }
}
