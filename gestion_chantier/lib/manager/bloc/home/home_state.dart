import 'package:gestion_chantier/manager/models/UserModel.dart';
import 'package:gestion_chantier/manager/models/BudgetModel.dart'; // <-- à importer

class HomeState {
  final bool isLoading;
  final UserModel? currentUser;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool showLoginDialog;

  final BudgetModel? budget; // <-- AJOUT

  const HomeState({
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
    this.isAuthenticated = false,
    this.showLoginDialog = false,
    this.budget, // <-- AJOUT
  });

  HomeState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    String? errorMessage,
    bool? isAuthenticated,
    bool? showLoginDialog,
    BudgetModel? budget, // <-- AJOUT
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      showLoginDialog: showLoginDialog ?? this.showLoginDialog,
      budget: budget ?? this.budget, // <-- AJOUT
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HomeState &&
        other.isLoading == isLoading &&
        other.currentUser == currentUser &&
        other.errorMessage == errorMessage &&
        other.isAuthenticated == isAuthenticated &&
        other.showLoginDialog == showLoginDialog &&
        other.budget == budget; // <-- AJOUT
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        currentUser.hashCode ^
        errorMessage.hashCode ^
        isAuthenticated.hashCode ^
        showLoginDialog.hashCode ^
        budget.hashCode; // <-- AJOUT
  }
}
