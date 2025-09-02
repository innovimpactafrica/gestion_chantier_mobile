abstract class NavigationEvent {}

class NavigationIndexChanged extends NavigationEvent {
  final int index;

  NavigationIndexChanged(this.index);
}
