// pages/home.dart - Version avec BLoC pattern pour les matériaux
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/bloc/Task/task_event.dart';
import 'package:gestion_chantier/moa/bloc/budget/budget_bloc.dart';
import 'package:gestion_chantier/moa/bloc/budget/budget_event.dart';
import 'package:gestion_chantier/moa/bloc/materiels/material_bloc.dart';
import 'package:gestion_chantier/moa/bloc/materiels/material_event.dart';
import 'package:gestion_chantier/moa/bloc/task/task_bloc.dart';
import 'package:gestion_chantier/moa/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/moa/bloc/home/home_state.dart';
import 'package:gestion_chantier/moa/models/accueil.dart';
import 'package:gestion_chantier/moa/repository/auth_repository.dart';
import 'package:gestion_chantier/moa/services/MaterialsService.dart';
import 'package:gestion_chantier/moa/models/material_kpi.dart';
import 'package:gestion_chantier/moa/services/TaskService.dart';

import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/home/UserNameSection.dart';
import 'package:gestion_chantier/moa/widgets/home/critical_tasks.dart';
import 'package:gestion_chantier/moa/widgets/home/header.dart';
import 'package:gestion_chantier/moa/widgets/home/overview.dart';
import 'package:gestion_chantier/moa/widgets/home/stock_alerts.dart';
import 'package:gestion_chantier/moa/widgets/home/studies_summary_grid.dart';
import 'package:gestion_chantier/moa/widgets/home/studies_distribution_chart.dart';
import 'package:gestion_chantier/moa/bloc/studies_kpi/studies_kpi_bloc.dart';
import 'package:gestion_chantier/moa/services/StudyRequestsService.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(create: (context) => TaskBloc(TaskService())),
        BlocProvider<MaterialBloc>(
          create:
              (context) =>
                  MaterialBloc(MaterialsService(), InventoryRepository()),
        ),
        BlocProvider<BudgetBloc>(create: (context) => BudgetBloc()),
        BlocProvider<StudiesKpiBloc>(
          create:
              (context) =>
                  StudiesKpiBloc(service: StudyRequestsService())
                    ..add(LoadStudiesKpi()),
        ),
      ],
      child: HomePageContent(),
    );
  }
}

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  String selectedPeriod = 'Ce mois';

  @override
  void initState() {
    super.initState();
    // Add a small delay to ensure BLoCs are properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _onPeriodChanged(String period) {
    setState(() {
      selectedPeriod = period;
    });
    // TODO: Reload data based on selected period
    // _loadDataForPeriod(period);
  }

  void _loadInitialData() {
    try {
      // Load budget data with error handling
      context.read<BudgetBloc>().add(LoadBudgetDashboardKpi());

      // Load task KPIs with error handling
      context.read<TaskBloc>().add(LoadTaskKpis());

      // Load critical materials using BLoC
      context.read<MaterialBloc>().add(LoadCriticalMaterials());
    } catch (e) {
      print('Error loading initial data: $e');
      // Show error message to user if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement des données'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = HomeData.mock();

    return Scaffold(
      backgroundColor: HexColor('#1A365D'),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Small space at the top
            const SizedBox(height: 50),

            // Header section
            SizedBox(
              height: 120,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  final userProfile =
                      state.currentUser?.profil ?? 'Utilisateur';
                  final userAvatar = state.currentUser?.photo ?? 'Utilisateur';

                  return HeaderWidget(
                    name: const UserNameSection(),
                    company: userProfile,
                    avatarUrl: userAvatar,
                  );
                },
              ),
            ),

            // Main content with white background
            Container(
              width: double.infinity,
              decoration: BoxDecoration(color: HexColor('#F5F7FA')),
              child: Column(
                children: [
                  // Overview card positioned on top
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: OverviewCardWidget(
                        siteStats: homeData.siteStats,
                        budgetPercentage: homeData.budgetPercentage,
                      ),
                    ),
                  ),

                  // Content padding
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Études — résumé et répartition
                        BlocBuilder<StudiesKpiBloc, StudiesKpiState>(
                          builder: (context, state) {
                            if (state is StudiesKpiLoading ||
                                state is StudiesKpiInitial) {
                              return const SizedBox(
                                height: 120,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            if (state is StudiesKpiError) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  state.message,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }
                            final model = (state as StudiesKpiLoaded).model;
                            return StudiesSummaryGrid(
                              pendingCount: model.pendingCount,
                              inProgressCount: model.inProgressCount,
                              validatedCount: model.validatedCount,
                              rejectedCount: model.rejectedCount,
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        BlocBuilder<StudiesKpiBloc, StudiesKpiState>(
                          builder: (context, state) {
                            if (state is StudiesKpiLoaded) {
                              final model = state.model;
                              return StudiesDistributionChart(
                                pendingPct: model.pendingPct,
                                inProgressPct: model.inProgressPct,
                                validatedPct: model.validatedPct,
                                rejectedPct: model.rejectedPct,
                                selectedPeriod: selectedPeriod,
                                onPeriodChanged: _onPeriodChanged,
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: 16),

                        // Stock Alerts agrégées (MOA)
                        FutureBuilder(
                          future:
                              MaterialsService()
                                  .getCriticalMaterialsAllPromoters(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      HexColor('#1A365D'),
                                    ),
                                  ),
                                ),
                              );
                            }
                            if (snapshot.hasError) {
                              return Container(
                                height: 150,
                                padding: EdgeInsets.all(16),
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
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        size: 32,
                                        color: Colors.red[400],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Erreur de chargement',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        snapshot.error.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 8),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {});
                                        },
                                        child: Text(
                                          'Réessayer',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: HexColor('#1A365D'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            final items =
                                (snapshot.data as List?)?.cast<StockItem>() ??
                                const <StockItem>[];
                            return StockAlertsWidget(
                              alertCount: items.length,
                              stockItems: items,
                            );
                          },
                        ),

                        const SizedBox(height: 14),

                        // Critical Tasks
                        CriticalTasksWidget(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BLoC-based stock section removed for MOA aggregation
}
