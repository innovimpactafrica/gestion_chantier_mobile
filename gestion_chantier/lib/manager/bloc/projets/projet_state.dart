class NavigationState {
  final int currentIndex;

  NavigationState({this.currentIndex = 0});

  NavigationState copyWith({int? currentIndex}) {
    return NavigationState(currentIndex: currentIndex ?? this.currentIndex);
  }
}
