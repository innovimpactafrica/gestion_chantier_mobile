import 'package:flutter/material.dart';

// Types pour les callbacks de routage
typedef AuthBlocFactory = Widget Function(BuildContext);
typedef MainScreenFactory = Widget Function(BuildContext);
typedef RoutingCallback = void Function(BuildContext, String profile);

/// Widget de login unifié (actuellement non utilisé car les modules
/// utilisent leurs propres implémentations avec le RoutingService)
class UnifiedLoginScreen extends StatefulWidget {
  final AuthBlocFactory authBlocFactory;
  final MainScreenFactory mainScreenFactory;
  final RoutingCallback onRoutingNeeded;
  final String? signupRoute;

  const UnifiedLoginScreen({
    super.key,
    required this.authBlocFactory,
    required this.mainScreenFactory,
    required this.onRoutingNeeded,
    this.signupRoute,
  });

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  @override
  Widget build(BuildContext context) {
    return widget.authBlocFactory(context);
  }
}
