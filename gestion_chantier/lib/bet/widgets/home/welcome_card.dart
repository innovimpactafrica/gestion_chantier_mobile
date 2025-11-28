import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_state.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BetHomeBloc, BetHomeState>(
      builder: (context, state) {
        String nom = '';
        String prenom = '';
        if (state is BetHomeLoading) {
          return const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          );
        } else if (state is BetHomeLoaded) {
          nom = state.currentUser.nom;
          prenom = state.currentUser.prenom;
        } else if (state is BetHomeError) {
          return Text(state.message, style: const TextStyle(color: Colors.red));
        } else {
          nom = 'Invité';
          prenom = '';
        }
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bonjour, $prenom $nom',
                style: const TextStyle(
                  color: Color(0xFF183B63),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Voici votre activité pour aujourd'hui",
                style: TextStyle(
                  color: Color(0xFF8A98A8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
