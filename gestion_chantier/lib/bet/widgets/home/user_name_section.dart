import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_state.dart';

class UserNameSection extends StatelessWidget {
  const UserNameSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BetHomeBloc, BetHomeState>(
      builder: (context, state) {
        if (state is BetHomeLoading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (state is BetHomeLoaded) {
          return Text(
            state.currentUser.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        } else if (state is BetHomeError) {
          return const Text('Erreur', style: TextStyle(color: Colors.red));
        } else {
          return const Text(
            'Alpha Dieye',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          );
        }
      },
    );
  }
}
