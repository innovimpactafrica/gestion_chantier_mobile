abstract class HomeEvent {
  const HomeEvent();
}

class LoadCurrentUserEvent extends HomeEvent {
  const LoadCurrentUserEvent();
}

class ResetDialogFlagEvent extends HomeEvent {
  const ResetDialogFlagEvent();
}

class ShowLoginDialogEvent extends HomeEvent {
  const ShowLoginDialogEvent();
}

class UpdateAuthenticationStatusEvent extends HomeEvent {
  final bool isAuthenticated;

  const UpdateAuthenticationStatusEvent({required this.isAuthenticated});
}

class ClearUserEvent extends HomeEvent {
  const ClearUserEvent();
}
