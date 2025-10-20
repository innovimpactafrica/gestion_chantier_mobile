import 'package:gestion_chantier/fournisseur/models/UserModel.dart';

class HomeState {
  final bool isLoading;
  final UserModel? currentUser;
  final String? errorMessage;
  final bool isAuthenticated;
  final bool showLoginDialog;

  const HomeState({
    this.isLoading = false,
    this.currentUser,
    this.errorMessage,
    this.isAuthenticated = false,
    this.showLoginDialog = false,
  });

  HomeState copyWith({
    bool? isLoading,
    UserModel? currentUser,
    String? errorMessage,
    bool? isAuthenticated,
    bool? showLoginDialog,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      showLoginDialog: showLoginDialog ?? this.showLoginDialog,
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
        other.showLoginDialog == showLoginDialog;
  }

  @override
  int get hashCode {
    return isLoading.hashCode ^
        currentUser.hashCode ^
        errorMessage.hashCode ^
        isAuthenticated.hashCode ^
        showLoginDialog.hashCode;
  }
}
