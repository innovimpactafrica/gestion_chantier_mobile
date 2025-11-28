import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_state.dart';
import 'package:gestion_chantier/bet/widgets/home/header_section.dart';
import 'package:gestion_chantier/bet/widgets/home/welcome_card.dart';
import 'package:gestion_chantier/bet/widgets/home/stats_section.dart';
import 'package:gestion_chantier/bet/widgets/home/distribution_chart_section.dart';
import 'package:gestion_chantier/bet/widgets/home/volume_chart_section.dart';

class BetHomePage extends StatefulWidget {
  const BetHomePage({Key? key}) : super(key: key);

  @override
  State<BetHomePage> createState() => _BetHomePageState();
}

class _BetHomePageState extends State<BetHomePage> {
  @override
  void initState() {
    super.initState();
    // L'utilisateur est déjà défini par ProfileRouter via SetCurrentUserEvent
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 90),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HeaderSection(),
            Transform.translate(
              offset: const Offset(0, -30),
              child: const WelcomeCard(),
            ),
            BlocBuilder<BetHomeBloc, BetHomeState>(
              builder: (context, state) {
                print('🔍 BetHomeState: $state');
                if (state is BetHomeLoaded) {
                  print(
                    '✅ Utilisateur BET chargé: ${state.currentUser.fullName}',
                  );

                  // Les KPIs se chargent automatiquement via SetCurrentUserEvent

                  return StatsSection(kpiData: state.kpiData);
                } else if (state is BetHomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BetHomeError) {
                  return Center(child: Text('Erreur: ${state.message}'));
                } else {
                  print('❌ État inattendu: $state');
                  return const Center(child: Text('État inattendu'));
                }
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<BetHomeBloc, BetHomeState>(
              builder: (context, state) {
                if (state is BetHomeLoaded) {
                  return DistributionChartSection(kpiData: state.kpiData);
                }
                return const DistributionChartSection();
              },
            ),
            const SizedBox(height: 32),
            BlocBuilder<BetHomeBloc, BetHomeState>(
              builder: (context, state) {
                if (state is BetHomeLoaded) {
                  return VolumeChartSection(
                    kpiData: state.kpiData,
                    volumetryData: state.volumetryData,
                  );
                }
                return const VolumeChartSection();
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
