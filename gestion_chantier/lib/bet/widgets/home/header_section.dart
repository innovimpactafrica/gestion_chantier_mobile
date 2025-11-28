import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/bet/bloc/home/home_state.dart';
import 'package:gestion_chantier/bet/utils/HexColor.dart';
import 'user_name_section.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BetHomeBloc, BetHomeState>(
      builder: (context, state) {
        final userProfile = state is BetHomeLoaded ? 'BET' : 'BET';

        return Container(
          height: 170,
          decoration: BoxDecoration(color: HexColor('#1A365D')),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 20),
              const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/images/avatar1.png'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const UserNameSection(),
                    Text(
                      userProfile,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.60),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 12,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5C02),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
