// pages/home.dart - Version avec BLoC pattern pour les matériaux
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/bloc/Task/task_event.dart';
import 'package:gestion_chantier/manager/bloc/budget/budget_bloc.dart';
import 'package:gestion_chantier/manager/bloc/budget/budget_event.dart';
import 'package:gestion_chantier/manager/bloc/materiels/material_bloc.dart';
import 'package:gestion_chantier/manager/bloc/materiels/material_event.dart';
import 'package:gestion_chantier/manager/bloc/materiels/material_state.dart'
    as material_states;
import 'package:gestion_chantier/manager/bloc/task/task_bloc.dart';
import 'package:gestion_chantier/manager/models/UserModel.dart';
import 'package:gestion_chantier/manager/models/accueil.dart';
import 'package:gestion_chantier/manager/repository/auth_repository.dart';
import 'package:gestion_chantier/manager/services/MaterialsService.dart';
import 'package:gestion_chantier/manager/services/TaskService.dart';

import 'package:gestion_chantier/manager/utils/HexColor.dart';
import 'package:gestion_chantier/manager/widgets/home/UserNameSection.dart';
import 'package:gestion_chantier/manager/widgets/home/critical_tasks.dart';
import 'package:gestion_chantier/manager/widgets/home/header.dart';
import 'package:gestion_chantier/manager/widgets/home/overview.dart';
import 'package:gestion_chantier/manager/widgets/home/stock_alerts.dart';
import 'package:gestion_chantier/manager/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/manager/bloc/home/home_state.dart';
import 'package:gestion_chantier/ouvrier/utils/profile_utils.dart';

import '../models/RealEstateKpiStatusModel.dart';
import '../repository/RealEstateKpiRepository.dart';

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

  final RealEstateKpiRepository repo = RealEstateKpiRepository();
  final  AuthRepository authrepo =  AuthRepository();

  RealEstateKpiStatusModel? kpiStatus;
  bool isLoading = false;
  String? errorMessage;
  int? _lastLoadedUserId;
  void loadKpi() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {

      UserModel user = await authrepo.currentUser();
      final kpi = await repo.getStatusKpiByPromoter(user .id);



      setState(() {
        kpiStatus = kpi;
        isLoading = false;
      });

      print('Total: ${kpi.total}');
      print('En cours: ${kpi.inProgress}');
      print('En retard: ${kpi.delayed}');
      print('En attente: ${kpi.pending}');
      print('Terminés: ${kpi.completed}');
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });

      print('Erreur KPI: $e');
    }
  }


  @override
  void initState() {
    super.initState();

    // Add a small delay to ensure BLoCs are properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadKpi();
      _loadInitialData();
    });
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
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 120,
                  child: BlocListener<HomeBloc, HomeState>(
                    listenWhen: (previous, current) =>
                    previous.currentUser?.id != current.currentUser?.id &&
                        current.currentUser != null,
                    listener: (context, state) {
                      final userId = state.currentUser?.id;

                      if (userId != null && userId != _lastLoadedUserId) {
                        _lastLoadedUserId = userId;

                      }
                    },
                    child: BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, state) {
                        final userProfile =
                        ProfileUtils.toFrench(state.currentUser?.profil);

                        return HeaderWidget(
                          name: const UserNameSection(),
                          company: userProfile,
                          avatarUrl: homeData.avatarUrl,
                        );
                      },
                    ),
                  ),
                ),


                // Main content with white background
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(color: HexColor('#F5F7FA')),
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 150, // Space for overview card
                          bottom: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 25),

                            // Stock Alerts with BLoC
                            BlocBuilder<
                              MaterialBloc,
                              material_states.MaterialState
                            >(
                              builder: (context, state) {
                                return _buildStockAlertsSection(state);
                              },
                            ),

                            const SizedBox(height: 14),

                            // Critical Tasks
                            CriticalTasksWidget(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Overview card positioned on top

            Positioned(
              top: 80,
              left: 20,
              right: 20,
              child: OverviewCardWidget(
                kpiStatus: kpiStatus,
                budgetPercentage: homeData.budgetPercentage,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockAlertsSection(material_states.MaterialState state) {
    if (state is material_states.MaterialLoading) {
      return SizedBox(
        height: 150,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(HexColor('#1A365D')),
              ),
              SizedBox(height: 16),
              Text(
                'Chargement des alertes...',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (state is material_states.MaterialError) {
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
              Icon(Icons.error_outline, size: 32, color: Colors.red[400]),
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
                state.message,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<MaterialBloc>().add(LoadCriticalMaterials());
                },
                child: Text(
                  'Réessayer',
                  style: TextStyle(fontSize: 12, color: HexColor('#1A365D')),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state is material_states.CriticalMaterialsLoaded) {
      return StockAlertsWidget(
        alertCount: state.materials.length,
        stockItems: state.materials,
      );
    }

    if (state is material_states.MaterialsLoaded) {
      return StockAlertsWidget(
        alertCount: state.criticalMaterials.length,
        stockItems: state.criticalMaterials,
      );
    }

    // État initial - afficher un widget vide avec le bon nombre d'alertes
    return StockAlertsWidget(alertCount: 0, stockItems: const []);
  }

  Future<void> _onRefresh() async {
    try {
      // Reload budget data
      context.read<BudgetBloc>().add(LoadBudgetDashboardKpi());

      // Reload task KPIs
      context.read<TaskBloc>().add(LoadTaskKpis());

      // Reload materials using BLoC
      context.read<MaterialBloc>().add(LoadCriticalMaterials());

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error during refresh: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'actualisation'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
