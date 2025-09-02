// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_state.dart';

class UserNameSection extends StatelessWidget {
  const UserNameSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (state.currentUser != null) {
          return Text(
            '${state.currentUser?.prenom ?? ''} ${state.currentUser?.nom ?? 'Invité'}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          );
        } else {
          return const Text(
            'Invité',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }
      },
    );
  }
}
