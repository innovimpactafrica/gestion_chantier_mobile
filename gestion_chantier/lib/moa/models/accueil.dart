// models/Home_data.dart
class HomeData {
  final String userName;
  final String company;
  final String avatarUrl;
  final SiteStats siteStats;
  final double budgetPercentage;
  final List<StockItems> stockAlerts;
  final List<CriticalTask> criticalTasks;

  HomeData({
    required this.userName,
    required this.company,
    required this.avatarUrl,
    required this.siteStats,
    required this.budgetPercentage,
    required this.stockAlerts,
    required this.criticalTasks,
  });

  static HomeData mock() {
    return HomeData(
      userName: 'Cheikh Gueye',
      company: 'Groupe BTP Sénégal',
      avatarUrl: 'assets/images/avatar.jpg',
      siteStats: SiteStats(
        inProgress: 12,
        delayed: 5,
        pending: 2,
        completed: 8,
      ),
      budgetPercentage: 70,
      stockAlerts: [
        StockItems(
          name: 'Carrelage',
          current: 12,
          threshold: 30,
          unit: 'm²',
          status: StockStatus.critical,
          siteId: 'Chantier A',
        ),
        StockItems(
          name: 'Fer à béton',
          current: 40,
          threshold: 40,
          unit: 'tonnes',
          status: StockStatus.normal,
          siteId: 'Chantier B',
        ),
        StockItems(
          name: 'Ciment',
          current: 20,
          threshold: 25,
          unit: 'tonnes',
          status: StockStatus.faible,
          siteId: 'Chantier C',
        ),
      ],
      criticalTasks: [
        CriticalTask(
          title: 'Clôture du chantier A',
          dueDate: DateTime(2025, 5, 1),
          status: TaskStatus.delayed,
        ),
        CriticalTask(
          title: 'Livraison matériel chantier B',
          dueDate: DateTime(2025, 5, 10),
          status: TaskStatus.urgent,
        ),
        CriticalTask(
          title: 'Réunion suivi client',
          dueDate: DateTime(2025, 5, 25),
          status: TaskStatus.upToDate,
          daysRemaining: 17,
        ),
      ],
    );
  }
}

class SiteStats {
  final int inProgress;
  final int delayed;
  final int pending;
  final int completed;

  SiteStats({
    required this.inProgress,
    required this.delayed,
    required this.pending,
    required this.completed,
  });

  int get total => inProgress + delayed + pending + completed;
}

class StockItems {
  final String name;
  final int current;
  final int threshold;
  final String unit;
  final StockStatus status;
  final String siteId;

  StockItems({
    required this.name,
    required this.current,
    required this.threshold,
    required this.unit,
    required this.status,
    required this.siteId,
  });
}

enum StockStatus { critical, normal, faible }

class CriticalTask {
  final String title;
  final DateTime dueDate;
  final TaskStatus status;
  final int? daysRemaining;

  CriticalTask({
    required this.title,
    required this.dueDate,
    required this.status,
    this.daysRemaining,
  });

  String get formattedDate =>
      '${dueDate.day.toString().padLeft(2, '0')}/${dueDate.month.toString().padLeft(2, '0')}/${dueDate.year}';
}

enum TaskStatus { delayed, urgent, upToDate }
