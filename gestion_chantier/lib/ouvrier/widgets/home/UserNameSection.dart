// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/ouvrier/bloc/username/user_name_section_bloc.dart';
import 'package:gestion_chantier/ouvrier/repository/auth_repository.dart';
import '../../bloc/username/user_name_section_event.dart';
import '../../bloc/username/user_name_section_state.dart';

class UserNameSection extends StatelessWidget {
  const UserNameSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<UserNameSectionBloc>(
      create:
          (_) =>
              UserNameSectionBloc(authRepository: AuthRepository())
                ..add(LoadCurrentUserEvent()),
      child: BlocBuilder<UserNameSectionBloc, UserNameSectionState>(
        builder: (context, state) {
          if (state is UserNameLoading) {
            return const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          } else if (state is UserNameLoaded) {
            return Text(
              '${state.user.prenom} ${state.user.nom}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            );
          } else if (state is UserNameError) {
            return Text(
              state.message,
              style: const TextStyle(color: Colors.red),
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
      ),
    );
  }
}
