// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navHome => 'Accueil';

  @override
  String get navProjects => 'Projets';

  @override
  String get navAccount => 'Mon compte';

  @override
  String get overviewTitle => 'Vue d\'ensemble des chantiers';

  @override
  String get overviewInProgress => 'En cours';

  @override
  String get overviewDelayed => 'En retard';

  @override
  String get overviewPending => 'En attente';

  @override
  String get overviewCompleted => 'Terminées';

  @override
  String get overviewBudgetLabel => 'Budget\nconsommé';

  @override
  String get stockAlertsTitle => 'Alertes stock matériaux';

  @override
  String get stockNoAlert => 'Aucune alerte de stock';

  @override
  String get stockStatusCritique => 'Critique';

  @override
  String get stockStatusFaible => 'Faible';

  @override
  String get stockStatusNormal => 'Normal';

  @override
  String get stockThreshold => 'seuil';

  @override
  String get criticalTasksTitle => 'Tâches critiques à échéance';

  @override
  String get criticalTasksEmpty => 'Aucune tâche critique';

  @override
  String get criticalTasksEmptySubtitle =>
      'Toutes vos tâches critiques sont à jour !';

  @override
  String get criticalTasksDeadline => 'Échéance';

  @override
  String get criticalTasksDaysLeft => 'j restants';

  @override
  String get criticalTasksDelayed => 'En retard';

  @override
  String get criticalTasksUrgent => 'Urgent';

  @override
  String get criticalTasksUpToDate => 'À jour';

  @override
  String get criticalTasksLoadingError => 'Erreur lors du chargement';

  @override
  String get criticalTasksRetry => 'Réessayer';

  @override
  String get criticalTasksHelp => 'Aide';

  @override
  String get criticalTasksConnectionTipsTitle => 'Conseils de connexion';

  @override
  String get criticalTasksConnectionTip1 =>
      '• Vérifiez votre connexion WiFi ou données mobiles';

  @override
  String get criticalTasksConnectionTip2 =>
      '• Assurez-vous d\'être connecté à internet';

  @override
  String get criticalTasksConnectionTip3 =>
      '• Redémarrez votre connexion si nécessaire';

  @override
  String get criticalTasksConnectionTip4 =>
      '• Contactez votre administrateur si le problème persiste';

  @override
  String get close => 'Fermer';

  @override
  String get projetsTitle => 'Projets';

  @override
  String get projetsSearchHint => 'Nom ou lieu du projet...';

  @override
  String get projetsSearchTitle => 'Rechercher un projet';

  @override
  String get projetsNoneFound => 'Aucun projet trouvé';

  @override
  String get projetsNoneAvailable => 'Aucun projet disponible';

  @override
  String get projetsLoadingError => 'Erreur de chargement';

  @override
  String get projetsRetry => 'Réessayer';

  @override
  String get projetsSubscriptionRequired => 'Abonnement requis';

  @override
  String get projetsSubscriptionMessage =>
      'Vous devez vous abonner pour pouvoir créer un chantier.';

  @override
  String get projetsSubscriptionCancel => 'Annuler';

  @override
  String get projetsSubscriptionSubscribe => 'S\'abonner';

  @override
  String get projetsBlocked =>
      'Le créateur du projet doit renouveler son abonnement pour débloquer les fonctionnalités.';

  @override
  String get progression => 'Progression';

  @override
  String get aboutDescription => 'Description du projet';

  @override
  String get aboutSurface => 'Surface';

  @override
  String get aboutLocation => 'Emplacement';

  @override
  String get aboutLots => 'Nombre de lots';

  @override
  String get aboutDeadline => 'Date d\'échéance';

  @override
  String get aboutDeadlineUndefined => 'Non définie';

  @override
  String get aboutDatesUndefined => 'Dates à définir';

  @override
  String get aboutEquipments => 'Équipements communs';

  @override
  String get aboutHall => 'Hall d\'entrée';

  @override
  String get aboutHallDesc => 'Espace d\'accueil de l\'immeuble';

  @override
  String get aboutElevator => 'Ascenseur';

  @override
  String get aboutElevatorDesc => 'Accès facilité aux différents étages';

  @override
  String get aboutParking => 'Parking';

  @override
  String get aboutParkingDesc => 'Espaces de stationnement sécurisés';

  @override
  String get aboutPool => 'Piscine';

  @override
  String get aboutPoolDesc => 'Espace de détente et de loisirs aquatiques';

  @override
  String get aboutGym => 'Salle de sport';

  @override
  String get aboutGymDesc => 'Équipements de fitness et de musculation';

  @override
  String get aboutPlayground => 'Aire de jeux';

  @override
  String get aboutPlaygroundDesc => 'Espace de jeux pour enfants';

  @override
  String get aboutSecurity => 'Service de sécurité';

  @override
  String get aboutSecurityDesc => 'Surveillance et sécurité 24h/24';

  @override
  String get aboutGarden => 'Jardin';

  @override
  String get aboutGardenDesc => 'Espaces verts et jardins paysagers';

  @override
  String get aboutTerrace => 'Terrasse partagée';

  @override
  String get aboutTerraceDesc => 'Espace extérieur commun avec vue';

  @override
  String get aboutBicycle => 'Local à vélos';

  @override
  String get aboutBicycleDesc => 'Rangement sécurisé pour bicyclettes';

  @override
  String get aboutLaundry => 'Buanderie';

  @override
  String get aboutLaundryDesc => 'Espace de lavage et séchage commun';

  @override
  String get aboutStorage => 'Locaux de stockage';

  @override
  String get aboutStorageDesc => 'Espaces de rangement supplémentaires';

  @override
  String get aboutWaste => 'Zone de collecte des déchets';

  @override
  String get aboutWasteDesc => 'Espace dédié à la gestion des déchets';

  @override
  String get teamLoadingError => 'Erreur de chargement';

  @override
  String get teamRetry => 'Réessayer';

  @override
  String get teamEmpty => 'Aucun membre d\'équipe';

  @override
  String get teamEmptySubtitle => 'Aucun worker assigné à ce projet';

  @override
  String get budgetPlanned => 'Budget prévu';

  @override
  String get budgetRemaining => 'Budget restant';

  @override
  String get budgetUsed => 'Budget utilisé';

  @override
  String get budgetModify => 'Modifier le budget';

  @override
  String get budgetOwnerOnly => 'Seul le propriétaire peut modifier';

  @override
  String get budgetLoadingError => 'Erreur lors du chargement';

  @override
  String get budgetRetry => 'Réessayer';

  @override
  String get budgetNoExpenses => 'Aucune dépense trouvée.';

  @override
  String get budgetNoExpensesEmpty => 'Aucune dépense disponible';

  @override
  String get budgetNoExpensesEmptySubtitle =>
      'Les dépenses apparaîtront ici une fois ajoutées';

  @override
  String get budgetDeleteConfirm => 'Confirmation';

  @override
  String get budgetDeleteMessage =>
      'Voulez-vous vraiment supprimer cette dépense ?';

  @override
  String get budgetDeleteCancel => 'Annuler';

  @override
  String get budgetDeleteConfirmBtn => 'Supprimer';

  @override
  String get budgetDeleteBackground => 'Supprimer';

  @override
  String get budgetExpenseDetail => 'Détail de la dépense';

  @override
  String get budgetExpenseDescription => 'Description';

  @override
  String get budgetExpenseDate => 'Date';

  @override
  String get budgetExpenseAmount => 'Montant';

  @override
  String get budgetExpenseProof => 'Voir la preuve';

  @override
  String get budgetNewExpense => 'Nouvelle dépense';

  @override
  String get budgetExpenseDescriptionHint => 'Ex: Achat de matériaux';

  @override
  String get budgetExpenseAmountLabel => 'Montant (FCFA)';

  @override
  String get budgetExpenseAmountHint => 'Ex: 50000';

  @override
  String get budgetExpenseDateLabel => 'Date';

  @override
  String get budgetExpenseEvidenceLabel => 'Evidence (optionnel)';

  @override
  String get budgetExpenseChooseFile => 'Choisir un fichier';

  @override
  String get budgetExpenseFileSelected => 'Fichier sélectionné';

  @override
  String get budgetExpenseSave => 'Enregistrer';

  @override
  String get budgetExpenseUpdating => 'Mise à jour...';

  @override
  String get budgetExpenseUpdate => 'Mettre à jour';

  @override
  String get budgetAmountLabel => 'Montant (FCFA)';

  @override
  String get budgetAmountHint => 'Saisir le montant';

  @override
  String get budgetTitle => 'Budget';

  @override
  String get commandesTitle => 'Commandes';

  @override
  String get commandesLoading => 'Chargement des commandes...';

  @override
  String get commandesLoadingError => 'Erreur de chargement';

  @override
  String get commandesEmpty => 'Aucune commande';

  @override
  String get commandesEmptySubtitle =>
      'Aucune commande en attente pour ce projet';

  @override
  String get commandesRetry => 'Réessayer';

  @override
  String get commandesStatusDelivered => 'Livrée';

  @override
  String get commandesStatusInTransit => 'En livraison';

  @override
  String get commandesStatusPending => 'En attente';

  @override
  String get commandesStatusCancelled => 'Annulée';

  @override
  String get commandesSupplier => 'Fournisseur';

  @override
  String get commandesOrderDate => 'Date de commande';

  @override
  String get commandesTotal => 'Total';

  @override
  String get commandesArticles => 'Articles';

  @override
  String get commandesUnits => 'unités';

  @override
  String get incidentsLoadingError => 'Erreur lors du chargement';

  @override
  String get incidentsRetry => 'Réessayer';

  @override
  String get incidentsEmpty => 'Aucun signalement';

  @override
  String get incidentsEmptySubtitle =>
      'Aucun incident n\'a été signalé pour ce projet';

  @override
  String get incidentsDeleteTitle => 'Supprimer le signalement';

  @override
  String get incidentsDeleteMessage =>
      'Voulez-vous vraiment supprimer ce signalement ?';

  @override
  String get incidentsDeleteCancel => 'Annuler';

  @override
  String get incidentsDeleteConfirm => 'Supprimer';

  @override
  String get incidentsDeleteError => 'Erreur lors de la suppression';

  @override
  String get accountTitle => 'Mon compte';

  @override
  String get accountNotifications => 'Notifications';

  @override
  String get accountLanguage => 'Langue : Français';

  @override
  String get accountChangePassword => 'Changer mon mot de passe';

  @override
  String get accountLogout => 'Se déconnecter';

  @override
  String get accountLogoutTitle => 'Déconnexion';

  @override
  String get accountLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get accountLogoutCancel => 'Annuler';

  @override
  String get accountLogoutConfirm => 'Se déconnecter';

  @override
  String get accountLogoutSuccess => 'Vous avez été déconnecté avec succès.';

  @override
  String get accountChangePasswordTitle => 'Changer le mot de passe';

  @override
  String get accountEmailHint => 'Votre email';

  @override
  String get accountEmailRequired => 'Veuillez saisir votre email';

  @override
  String get accountCurrentPasswordHint => 'Mot de passe actuel';

  @override
  String get accountCurrentPasswordRequired =>
      'Veuillez saisir votre mot de passe actuel';

  @override
  String get accountNewPasswordHint => 'Nouveau mot de passe';

  @override
  String get accountNewPasswordRequired =>
      'Veuillez saisir un nouveau mot de passe';

  @override
  String get accountChangePasswordCancel => 'Annuler';

  @override
  String get accountChangePasswordConfirm => 'Changer';

  @override
  String get loadingAlerts => 'Chargement des alertes...';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get errorBudget => 'Erreur\nbudget';

  @override
  String get errorStats => 'Erreur de chargement\ndes statistiques';
}
