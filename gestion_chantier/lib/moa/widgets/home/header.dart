import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class HeaderWidget extends StatelessWidget {
  final Widget name;
  final String company;
  final String avatarUrl;

  const HeaderWidget({
    super.key,
    required this.name,
    required this.company,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 0, 10, 60),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 12),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                avatarUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFE8F4FD),
                    child: Icon(
                      Icons.person,
                      color: HexColor('#1A365D'),
                      size: 28,
                    ),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Name and Company
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(child: name),
                Text(
                  company,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.60),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          SizedBox(
            width: 44,
            height: 44,

            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                Positioned(
                  right: 9,
                  top: 9,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
