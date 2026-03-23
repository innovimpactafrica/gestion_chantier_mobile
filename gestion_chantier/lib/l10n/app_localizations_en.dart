// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navHome => 'Home';

  @override
  String get navProjects => 'Projects';

  @override
  String get navAccount => 'My account';

  @override
  String get overviewTitle => 'Construction sites overview';

  @override
  String get overviewInProgress => 'In progress';

  @override
  String get overviewDelayed => 'Delayed';

  @override
  String get overviewPending => 'Pending';

  @override
  String get overviewCompleted => 'Completed';

  @override
  String get overviewBudgetLabel => 'Budget\nconsumed';

  @override
  String get stockAlertsTitle => 'Material stock alerts';

  @override
  String get stockNoAlert => 'No stock alerts';

  @override
  String get stockStatusCritique => 'Critical';

  @override
  String get stockStatusFaible => 'Low';

  @override
  String get stockStatusNormal => 'Normal';

  @override
  String get stockThreshold => 'threshold';

  @override
  String get criticalTasksTitle => 'Critical tasks due';

  @override
  String get criticalTasksEmpty => 'No critical tasks';

  @override
  String get criticalTasksEmptySubtitle =>
      'All your critical tasks are up to date!';

  @override
  String get criticalTasksDeadline => 'Deadline';

  @override
  String get criticalTasksDaysLeft => 'days left';

  @override
  String get criticalTasksDelayed => 'Delayed';

  @override
  String get criticalTasksUrgent => 'Urgent';

  @override
  String get criticalTasksUpToDate => 'Up to date';

  @override
  String get criticalTasksLoadingError => 'Loading error';

  @override
  String get criticalTasksRetry => 'Retry';

  @override
  String get criticalTasksHelp => 'Help';

  @override
  String get criticalTasksConnectionTipsTitle => 'Connection tips';

  @override
  String get criticalTasksConnectionTip1 =>
      '• Check your WiFi or mobile data connection';

  @override
  String get criticalTasksConnectionTip2 =>
      '• Make sure you are connected to the internet';

  @override
  String get criticalTasksConnectionTip3 =>
      '• Restart your connection if necessary';

  @override
  String get criticalTasksConnectionTip4 =>
      '• Contact your administrator if the problem persists';

  @override
  String get close => 'Close';

  @override
  String get projetsTitle => 'Projects';

  @override
  String get projetsSearchHint => 'Project name or location...';

  @override
  String get projetsSearchTitle => 'Search a project';

  @override
  String get projetsNoneFound => 'No projects found';

  @override
  String get projetsNoneAvailable => 'No projects available';

  @override
  String get projetsLoadingError => 'Loading error';

  @override
  String get projetsRetry => 'Retry';

  @override
  String get projetsSubscriptionRequired => 'Subscription required';

  @override
  String get projetsSubscriptionMessage =>
      'You must subscribe to create a construction site.';

  @override
  String get projetsSubscriptionCancel => 'Cancel';

  @override
  String get projetsSubscriptionSubscribe => 'Subscribe';

  @override
  String get projetsBlocked =>
      'The project creator must renew their subscription to unlock features.';

  @override
  String get progression => 'Progress';

  @override
  String get aboutDescription => 'Project description';

  @override
  String get aboutSurface => 'Area';

  @override
  String get aboutLocation => 'Location';

  @override
  String get aboutLots => 'Number of lots';

  @override
  String get aboutDeadline => 'Deadline';

  @override
  String get aboutDeadlineUndefined => 'Not defined';

  @override
  String get aboutDatesUndefined => 'Dates to be defined';

  @override
  String get aboutEquipments => 'Common amenities';

  @override
  String get aboutHall => 'Entrance hall';

  @override
  String get aboutHallDesc => 'Building reception area';

  @override
  String get aboutElevator => 'Elevator';

  @override
  String get aboutElevatorDesc => 'Easy access to different floors';

  @override
  String get aboutParking => 'Parking';

  @override
  String get aboutParkingDesc => 'Secured parking spaces';

  @override
  String get aboutPool => 'Swimming pool';

  @override
  String get aboutPoolDesc => 'Relaxation and aquatic leisure area';

  @override
  String get aboutGym => 'Gym';

  @override
  String get aboutGymDesc => 'Fitness and weight training equipment';

  @override
  String get aboutPlayground => 'Playground';

  @override
  String get aboutPlaygroundDesc => 'Play area for children';

  @override
  String get aboutSecurity => 'Security service';

  @override
  String get aboutSecurityDesc => '24/7 surveillance and security';

  @override
  String get aboutGarden => 'Garden';

  @override
  String get aboutGardenDesc => 'Green spaces and landscaped gardens';

  @override
  String get aboutTerrace => 'Shared terrace';

  @override
  String get aboutTerraceDesc => 'Common outdoor space with a view';

  @override
  String get aboutBicycle => 'Bicycle storage';

  @override
  String get aboutBicycleDesc => 'Secure storage for bicycles';

  @override
  String get aboutLaundry => 'Laundry room';

  @override
  String get aboutLaundryDesc => 'Common washing and drying area';

  @override
  String get aboutStorage => 'Storage rooms';

  @override
  String get aboutStorageDesc => 'Additional storage spaces';

  @override
  String get aboutWaste => 'Waste collection area';

  @override
  String get aboutWasteDesc => 'Dedicated waste management space';

  @override
  String get teamLoadingError => 'Loading error';

  @override
  String get teamRetry => 'Retry';

  @override
  String get teamEmpty => 'No team members';

  @override
  String get teamEmptySubtitle => 'No workers assigned to this project';

  @override
  String get budgetPlanned => 'Planned budget';

  @override
  String get budgetRemaining => 'Remaining budget';

  @override
  String get budgetUsed => 'Used budget';

  @override
  String get budgetModify => 'Edit budget';

  @override
  String get budgetOwnerOnly => 'Only the owner can edit';

  @override
  String get budgetLoadingError => 'Loading error';

  @override
  String get budgetRetry => 'Retry';

  @override
  String get budgetNoExpenses => 'No expenses found.';

  @override
  String get budgetNoExpensesEmpty => 'No expenses available';

  @override
  String get budgetNoExpensesEmptySubtitle =>
      'Expenses will appear here once added';

  @override
  String get budgetDeleteConfirm => 'Confirmation';

  @override
  String get budgetDeleteMessage =>
      'Are you sure you want to delete this expense?';

  @override
  String get budgetDeleteCancel => 'Cancel';

  @override
  String get budgetDeleteConfirmBtn => 'Delete';

  @override
  String get budgetDeleteBackground => 'Delete';

  @override
  String get budgetExpenseDetail => 'Expense detail';

  @override
  String get budgetExpenseDescription => 'Description';

  @override
  String get budgetExpenseDate => 'Date';

  @override
  String get budgetExpenseAmount => 'Amount';

  @override
  String get budgetExpenseProof => 'View proof';

  @override
  String get budgetNewExpense => 'New expense';

  @override
  String get budgetExpenseDescriptionHint => 'Ex: Material purchase';

  @override
  String get budgetExpenseAmountLabel => 'Amount (FCFA)';

  @override
  String get budgetExpenseAmountHint => 'Ex: 50000';

  @override
  String get budgetExpenseDateLabel => 'Date';

  @override
  String get budgetExpenseEvidenceLabel => 'Evidence (optional)';

  @override
  String get budgetExpenseChooseFile => 'Choose a file';

  @override
  String get budgetExpenseFileSelected => 'File selected';

  @override
  String get budgetExpenseSave => 'Save';

  @override
  String get budgetExpenseUpdating => 'Updating...';

  @override
  String get budgetExpenseUpdate => 'Update';

  @override
  String get budgetAmountLabel => 'Amount (FCFA)';

  @override
  String get budgetAmountHint => 'Enter amount';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get commandesTitle => 'Orders';

  @override
  String get commandesLoading => 'Loading orders...';

  @override
  String get commandesLoadingError => 'Loading error';

  @override
  String get commandesEmpty => 'No orders';

  @override
  String get commandesEmptySubtitle => 'No pending orders for this project';

  @override
  String get commandesRetry => 'Retry';

  @override
  String get commandesStatusDelivered => 'Delivered';

  @override
  String get commandesStatusInTransit => 'In transit';

  @override
  String get commandesStatusPending => 'Pending';

  @override
  String get commandesStatusCancelled => 'Cancelled';

  @override
  String get commandesSupplier => 'Supplier';

  @override
  String get commandesOrderDate => 'Order date';

  @override
  String get commandesTotal => 'Total';

  @override
  String get commandesArticles => 'Items';

  @override
  String get commandesUnits => 'units';

  @override
  String get incidentsLoadingError => 'Loading error';

  @override
  String get incidentsRetry => 'Retry';

  @override
  String get incidentsEmpty => 'No reports';

  @override
  String get incidentsEmptySubtitle =>
      'No incidents have been reported for this project';

  @override
  String get incidentsDeleteTitle => 'Delete report';

  @override
  String get incidentsDeleteMessage =>
      'Are you sure you want to delete this report?';

  @override
  String get incidentsDeleteCancel => 'Cancel';

  @override
  String get incidentsDeleteConfirm => 'Delete';

  @override
  String get incidentsDeleteError => 'Error while deleting';

  @override
  String get accountTitle => 'My account';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountLanguage => 'Language: English';

  @override
  String get accountChangePassword => 'Change my password';

  @override
  String get accountLogout => 'Log out';

  @override
  String get accountLogoutTitle => 'Log out';

  @override
  String get accountLogoutMessage => 'Are you sure you want to log out?';

  @override
  String get accountLogoutCancel => 'Cancel';

  @override
  String get accountLogoutConfirm => 'Log out';

  @override
  String get accountLogoutSuccess => 'You have been successfully logged out.';

  @override
  String get accountChangePasswordTitle => 'Change password';

  @override
  String get accountEmailHint => 'Your email';

  @override
  String get accountEmailRequired => 'Please enter your email';

  @override
  String get accountCurrentPasswordHint => 'Current password';

  @override
  String get accountCurrentPasswordRequired =>
      'Please enter your current password';

  @override
  String get accountNewPasswordHint => 'New password';

  @override
  String get accountNewPasswordRequired => 'Please enter a new password';

  @override
  String get accountChangePasswordCancel => 'Cancel';

  @override
  String get accountChangePasswordConfirm => 'Change';

  @override
  String get loadingAlerts => 'Loading alerts...';

  @override
  String get loadingError => 'Loading error';

  @override
  String get errorBudget => 'Budget\nerror';

  @override
  String get errorStats => 'Loading error\nfor statistics';
}
