import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navProjects.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get navProjects;

  /// No description provided for @navAccount.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get navAccount;

  /// No description provided for @overviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble des chantiers'**
  String get overviewTitle;

  /// No description provided for @overviewInProgress.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get overviewInProgress;

  /// No description provided for @overviewDelayed.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get overviewDelayed;

  /// No description provided for @overviewPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get overviewPending;

  /// No description provided for @overviewCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get overviewCompleted;

  /// No description provided for @overviewBudgetLabel.
  ///
  /// In fr, this message translates to:
  /// **'Budget\nconsommé'**
  String get overviewBudgetLabel;

  /// No description provided for @stockAlertsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes stock matériaux'**
  String get stockAlertsTitle;

  /// No description provided for @stockNoAlert.
  ///
  /// In fr, this message translates to:
  /// **'Aucune alerte de stock'**
  String get stockNoAlert;

  /// No description provided for @stockStatusCritique.
  ///
  /// In fr, this message translates to:
  /// **'Critique'**
  String get stockStatusCritique;

  /// No description provided for @stockStatusFaible.
  ///
  /// In fr, this message translates to:
  /// **'Faible'**
  String get stockStatusFaible;

  /// No description provided for @stockStatusNormal.
  ///
  /// In fr, this message translates to:
  /// **'Normal'**
  String get stockStatusNormal;

  /// No description provided for @stockThreshold.
  ///
  /// In fr, this message translates to:
  /// **'seuil'**
  String get stockThreshold;

  /// No description provided for @criticalTasksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tâches critiques à échéance'**
  String get criticalTasksTitle;

  /// No description provided for @criticalTasksEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune tâche critique'**
  String get criticalTasksEmpty;

  /// No description provided for @criticalTasksEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Toutes vos tâches critiques sont à jour !'**
  String get criticalTasksEmptySubtitle;

  /// No description provided for @criticalTasksDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Échéance'**
  String get criticalTasksDeadline;

  /// No description provided for @criticalTasksDaysLeft.
  ///
  /// In fr, this message translates to:
  /// **'j restants'**
  String get criticalTasksDaysLeft;

  /// No description provided for @criticalTasksDelayed.
  ///
  /// In fr, this message translates to:
  /// **'En retard'**
  String get criticalTasksDelayed;

  /// No description provided for @criticalTasksUrgent.
  ///
  /// In fr, this message translates to:
  /// **'Urgent'**
  String get criticalTasksUrgent;

  /// No description provided for @criticalTasksUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get criticalTasksUpToDate;

  /// No description provided for @criticalTasksLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement'**
  String get criticalTasksLoadingError;

  /// No description provided for @criticalTasksRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get criticalTasksRetry;

  /// No description provided for @criticalTasksHelp.
  ///
  /// In fr, this message translates to:
  /// **'Aide'**
  String get criticalTasksHelp;

  /// No description provided for @criticalTasksConnectionTipsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Conseils de connexion'**
  String get criticalTasksConnectionTipsTitle;

  /// No description provided for @criticalTasksConnectionTip1.
  ///
  /// In fr, this message translates to:
  /// **'• Vérifiez votre connexion WiFi ou données mobiles'**
  String get criticalTasksConnectionTip1;

  /// No description provided for @criticalTasksConnectionTip2.
  ///
  /// In fr, this message translates to:
  /// **'• Assurez-vous d\'être connecté à internet'**
  String get criticalTasksConnectionTip2;

  /// No description provided for @criticalTasksConnectionTip3.
  ///
  /// In fr, this message translates to:
  /// **'• Redémarrez votre connexion si nécessaire'**
  String get criticalTasksConnectionTip3;

  /// No description provided for @criticalTasksConnectionTip4.
  ///
  /// In fr, this message translates to:
  /// **'• Contactez votre administrateur si le problème persiste'**
  String get criticalTasksConnectionTip4;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @projetsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Projets'**
  String get projetsTitle;

  /// No description provided for @projetsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom ou lieu du projet...'**
  String get projetsSearchHint;

  /// No description provided for @projetsSearchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un projet'**
  String get projetsSearchTitle;

  /// No description provided for @projetsNoneFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet trouvé'**
  String get projetsNoneFound;

  /// No description provided for @projetsNoneAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Aucun projet disponible'**
  String get projetsNoneAvailable;

  /// No description provided for @projetsLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get projetsLoadingError;

  /// No description provided for @projetsRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get projetsRetry;

  /// No description provided for @projetsSubscriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Abonnement requis'**
  String get projetsSubscriptionRequired;

  /// No description provided for @projetsSubscriptionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous devez vous abonner pour pouvoir créer un chantier.'**
  String get projetsSubscriptionMessage;

  /// No description provided for @projetsSubscriptionCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get projetsSubscriptionCancel;

  /// No description provided for @projetsSubscriptionSubscribe.
  ///
  /// In fr, this message translates to:
  /// **'S\'abonner'**
  String get projetsSubscriptionSubscribe;

  /// No description provided for @projetsBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Le créateur du projet doit renouveler son abonnement pour débloquer les fonctionnalités.'**
  String get projetsBlocked;

  /// No description provided for @progression.
  ///
  /// In fr, this message translates to:
  /// **'Progression'**
  String get progression;

  /// No description provided for @aboutDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description du projet'**
  String get aboutDescription;

  /// No description provided for @aboutSurface.
  ///
  /// In fr, this message translates to:
  /// **'Surface'**
  String get aboutSurface;

  /// No description provided for @aboutLocation.
  ///
  /// In fr, this message translates to:
  /// **'Emplacement'**
  String get aboutLocation;

  /// No description provided for @aboutLots.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de lots'**
  String get aboutLots;

  /// No description provided for @aboutDeadline.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'échéance'**
  String get aboutDeadline;

  /// No description provided for @aboutDeadlineUndefined.
  ///
  /// In fr, this message translates to:
  /// **'Non définie'**
  String get aboutDeadlineUndefined;

  /// No description provided for @aboutDatesUndefined.
  ///
  /// In fr, this message translates to:
  /// **'Dates à définir'**
  String get aboutDatesUndefined;

  /// No description provided for @aboutEquipments.
  ///
  /// In fr, this message translates to:
  /// **'Équipements communs'**
  String get aboutEquipments;

  /// No description provided for @aboutHall.
  ///
  /// In fr, this message translates to:
  /// **'Hall d\'entrée'**
  String get aboutHall;

  /// No description provided for @aboutHallDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espace d\'accueil de l\'immeuble'**
  String get aboutHallDesc;

  /// No description provided for @aboutElevator.
  ///
  /// In fr, this message translates to:
  /// **'Ascenseur'**
  String get aboutElevator;

  /// No description provided for @aboutElevatorDesc.
  ///
  /// In fr, this message translates to:
  /// **'Accès facilité aux différents étages'**
  String get aboutElevatorDesc;

  /// No description provided for @aboutParking.
  ///
  /// In fr, this message translates to:
  /// **'Parking'**
  String get aboutParking;

  /// No description provided for @aboutParkingDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espaces de stationnement sécurisés'**
  String get aboutParkingDesc;

  /// No description provided for @aboutPool.
  ///
  /// In fr, this message translates to:
  /// **'Piscine'**
  String get aboutPool;

  /// No description provided for @aboutPoolDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espace de détente et de loisirs aquatiques'**
  String get aboutPoolDesc;

  /// No description provided for @aboutGym.
  ///
  /// In fr, this message translates to:
  /// **'Salle de sport'**
  String get aboutGym;

  /// No description provided for @aboutGymDesc.
  ///
  /// In fr, this message translates to:
  /// **'Équipements de fitness et de musculation'**
  String get aboutGymDesc;

  /// No description provided for @aboutPlayground.
  ///
  /// In fr, this message translates to:
  /// **'Aire de jeux'**
  String get aboutPlayground;

  /// No description provided for @aboutPlaygroundDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espace de jeux pour enfants'**
  String get aboutPlaygroundDesc;

  /// No description provided for @aboutSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Service de sécurité'**
  String get aboutSecurity;

  /// No description provided for @aboutSecurityDesc.
  ///
  /// In fr, this message translates to:
  /// **'Surveillance et sécurité 24h/24'**
  String get aboutSecurityDesc;

  /// No description provided for @aboutGarden.
  ///
  /// In fr, this message translates to:
  /// **'Jardin'**
  String get aboutGarden;

  /// No description provided for @aboutGardenDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espaces verts et jardins paysagers'**
  String get aboutGardenDesc;

  /// No description provided for @aboutTerrace.
  ///
  /// In fr, this message translates to:
  /// **'Terrasse partagée'**
  String get aboutTerrace;

  /// No description provided for @aboutTerraceDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espace extérieur commun avec vue'**
  String get aboutTerraceDesc;

  /// No description provided for @aboutBicycle.
  ///
  /// In fr, this message translates to:
  /// **'Local à vélos'**
  String get aboutBicycle;

  /// No description provided for @aboutBicycleDesc.
  ///
  /// In fr, this message translates to:
  /// **'Rangement sécurisé pour bicyclettes'**
  String get aboutBicycleDesc;

  /// No description provided for @aboutLaundry.
  ///
  /// In fr, this message translates to:
  /// **'Buanderie'**
  String get aboutLaundry;

  /// No description provided for @aboutLaundryDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espace de lavage et séchage commun'**
  String get aboutLaundryDesc;

  /// No description provided for @aboutStorage.
  ///
  /// In fr, this message translates to:
  /// **'Locaux de stockage'**
  String get aboutStorage;

  /// No description provided for @aboutStorageDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espaces de rangement supplémentaires'**
  String get aboutStorageDesc;

  /// No description provided for @aboutWaste.
  ///
  /// In fr, this message translates to:
  /// **'Zone de collecte des déchets'**
  String get aboutWaste;

  /// No description provided for @aboutWasteDesc.
  ///
  /// In fr, this message translates to:
  /// **'Espace dédié à la gestion des déchets'**
  String get aboutWasteDesc;

  /// No description provided for @teamLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get teamLoadingError;

  /// No description provided for @teamRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get teamRetry;

  /// No description provided for @teamEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun membre d\'équipe'**
  String get teamEmpty;

  /// No description provided for @teamEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun worker assigné à ce projet'**
  String get teamEmptySubtitle;

  /// No description provided for @budgetPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Budget prévu'**
  String get budgetPlanned;

  /// No description provided for @budgetRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Budget restant'**
  String get budgetRemaining;

  /// No description provided for @budgetUsed.
  ///
  /// In fr, this message translates to:
  /// **'Budget utilisé'**
  String get budgetUsed;

  /// No description provided for @budgetModify.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le budget'**
  String get budgetModify;

  /// No description provided for @budgetOwnerOnly.
  ///
  /// In fr, this message translates to:
  /// **'Seul le propriétaire peut modifier'**
  String get budgetOwnerOnly;

  /// No description provided for @budgetLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement'**
  String get budgetLoadingError;

  /// No description provided for @budgetRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get budgetRetry;

  /// No description provided for @budgetNoExpenses.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense trouvée.'**
  String get budgetNoExpenses;

  /// No description provided for @budgetNoExpensesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune dépense disponible'**
  String get budgetNoExpensesEmpty;

  /// No description provided for @budgetNoExpensesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les dépenses apparaîtront ici une fois ajoutées'**
  String get budgetNoExpensesEmptySubtitle;

  /// No description provided for @budgetDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmation'**
  String get budgetDeleteConfirm;

  /// No description provided for @budgetDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer cette dépense ?'**
  String get budgetDeleteMessage;

  /// No description provided for @budgetDeleteCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get budgetDeleteCancel;

  /// No description provided for @budgetDeleteConfirmBtn.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get budgetDeleteConfirmBtn;

  /// No description provided for @budgetDeleteBackground.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get budgetDeleteBackground;

  /// No description provided for @budgetExpenseDetail.
  ///
  /// In fr, this message translates to:
  /// **'Détail de la dépense'**
  String get budgetExpenseDetail;

  /// No description provided for @budgetExpenseDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get budgetExpenseDescription;

  /// No description provided for @budgetExpenseDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get budgetExpenseDate;

  /// No description provided for @budgetExpenseAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant'**
  String get budgetExpenseAmount;

  /// No description provided for @budgetExpenseProof.
  ///
  /// In fr, this message translates to:
  /// **'Voir la preuve'**
  String get budgetExpenseProof;

  /// No description provided for @budgetNewExpense.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle dépense'**
  String get budgetNewExpense;

  /// No description provided for @budgetExpenseDescriptionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: Achat de matériaux'**
  String get budgetExpenseDescriptionHint;

  /// No description provided for @budgetExpenseAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant (FCFA)'**
  String get budgetExpenseAmountLabel;

  /// No description provided for @budgetExpenseAmountHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex: 50000'**
  String get budgetExpenseAmountHint;

  /// No description provided for @budgetExpenseDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get budgetExpenseDateLabel;

  /// No description provided for @budgetExpenseEvidenceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Evidence (optionnel)'**
  String get budgetExpenseEvidenceLabel;

  /// No description provided for @budgetExpenseChooseFile.
  ///
  /// In fr, this message translates to:
  /// **'Choisir un fichier'**
  String get budgetExpenseChooseFile;

  /// No description provided for @budgetExpenseFileSelected.
  ///
  /// In fr, this message translates to:
  /// **'Fichier sélectionné'**
  String get budgetExpenseFileSelected;

  /// No description provided for @budgetExpenseSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get budgetExpenseSave;

  /// No description provided for @budgetExpenseUpdating.
  ///
  /// In fr, this message translates to:
  /// **'Mise à jour...'**
  String get budgetExpenseUpdating;

  /// No description provided for @budgetExpenseUpdate.
  ///
  /// In fr, this message translates to:
  /// **'Mettre à jour'**
  String get budgetExpenseUpdate;

  /// No description provided for @budgetAmountLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant (FCFA)'**
  String get budgetAmountLabel;

  /// No description provided for @budgetAmountHint.
  ///
  /// In fr, this message translates to:
  /// **'Saisir le montant'**
  String get budgetAmountHint;

  /// No description provided for @budgetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Budget'**
  String get budgetTitle;

  /// No description provided for @commandesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Commandes'**
  String get commandesTitle;

  /// No description provided for @commandesLoading.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des commandes...'**
  String get commandesLoading;

  /// No description provided for @commandesLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get commandesLoadingError;

  /// No description provided for @commandesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande'**
  String get commandesEmpty;

  /// No description provided for @commandesEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune commande en attente pour ce projet'**
  String get commandesEmptySubtitle;

  /// No description provided for @commandesRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commandesRetry;

  /// No description provided for @commandesStatusDelivered.
  ///
  /// In fr, this message translates to:
  /// **'Livrée'**
  String get commandesStatusDelivered;

  /// No description provided for @commandesStatusInTransit.
  ///
  /// In fr, this message translates to:
  /// **'En livraison'**
  String get commandesStatusInTransit;

  /// No description provided for @commandesStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get commandesStatusPending;

  /// No description provided for @commandesStatusCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Annulée'**
  String get commandesStatusCancelled;

  /// No description provided for @commandesSupplier.
  ///
  /// In fr, this message translates to:
  /// **'Fournisseur'**
  String get commandesSupplier;

  /// No description provided for @commandesOrderDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de commande'**
  String get commandesOrderDate;

  /// No description provided for @commandesTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get commandesTotal;

  /// No description provided for @commandesArticles.
  ///
  /// In fr, this message translates to:
  /// **'Articles'**
  String get commandesArticles;

  /// No description provided for @commandesUnits.
  ///
  /// In fr, this message translates to:
  /// **'unités'**
  String get commandesUnits;

  /// No description provided for @incidentsLoadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors du chargement'**
  String get incidentsLoadingError;

  /// No description provided for @incidentsRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get incidentsRetry;

  /// No description provided for @incidentsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun signalement'**
  String get incidentsEmpty;

  /// No description provided for @incidentsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun incident n\'a été signalé pour ce projet'**
  String get incidentsEmptySubtitle;

  /// No description provided for @incidentsDeleteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le signalement'**
  String get incidentsDeleteTitle;

  /// No description provided for @incidentsDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous vraiment supprimer ce signalement ?'**
  String get incidentsDeleteMessage;

  /// No description provided for @incidentsDeleteCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get incidentsDeleteCancel;

  /// No description provided for @incidentsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get incidentsDeleteConfirm;

  /// No description provided for @incidentsDeleteError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur lors de la suppression'**
  String get incidentsDeleteError;

  /// No description provided for @accountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon compte'**
  String get accountTitle;

  /// No description provided for @accountNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get accountNotifications;

  /// No description provided for @accountLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue : Français'**
  String get accountLanguage;

  /// No description provided for @accountChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer mon mot de passe'**
  String get accountChangePassword;

  /// No description provided for @accountLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get accountLogout;

  /// No description provided for @accountLogoutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déconnexion'**
  String get accountLogoutTitle;

  /// No description provided for @accountLogoutMessage.
  ///
  /// In fr, this message translates to:
  /// **'Êtes-vous sûr de vouloir vous déconnecter ?'**
  String get accountLogoutMessage;

  /// No description provided for @accountLogoutCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get accountLogoutCancel;

  /// No description provided for @accountLogoutConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get accountLogoutConfirm;

  /// No description provided for @accountLogoutSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez été déconnecté avec succès.'**
  String get accountLogoutSuccess;

  /// No description provided for @accountChangePasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Changer le mot de passe'**
  String get accountChangePasswordTitle;

  /// No description provided for @accountEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'Votre email'**
  String get accountEmailHint;

  /// No description provided for @accountEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre email'**
  String get accountEmailRequired;

  /// No description provided for @accountCurrentPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get accountCurrentPasswordHint;

  /// No description provided for @accountCurrentPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir votre mot de passe actuel'**
  String get accountCurrentPasswordRequired;

  /// No description provided for @accountNewPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get accountNewPasswordHint;

  /// No description provided for @accountNewPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Veuillez saisir un nouveau mot de passe'**
  String get accountNewPasswordRequired;

  /// No description provided for @accountChangePasswordCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get accountChangePasswordCancel;

  /// No description provided for @accountChangePasswordConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Changer'**
  String get accountChangePasswordConfirm;

  /// No description provided for @loadingAlerts.
  ///
  /// In fr, this message translates to:
  /// **'Chargement des alertes...'**
  String get loadingAlerts;

  /// No description provided for @loadingError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement'**
  String get loadingError;

  /// No description provided for @errorBudget.
  ///
  /// In fr, this message translates to:
  /// **'Erreur\nbudget'**
  String get errorBudget;

  /// No description provided for @errorStats.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de chargement\ndes statistiques'**
  String get errorStats;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
