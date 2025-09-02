// widgets/home/circular_progress.dart
import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';

class CircularProgressWidget extends StatelessWidget {
  final double percentage;
  final String label;
  final String? value; // Nouvelle propriété optionnelle

  const CircularProgressWidget({
    super.key,
    required this.percentage,
    required this.label,
    this.value, // Valeur optionnelle à afficher au centre
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Cercle de progression
          Center(
            child: SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8,
                backgroundColor: HexColor('#E8E8E8'),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(percentage),
                ),
              ),
            ),
          ),

          // Contenu central
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Affichage de la valeur personnalisée ou du pourcentage
                Text(
                  value ?? '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: HexColor('#2C3E50'),
                  ),
                ),

                const SizedBox(height: 2),

                // Label
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: HexColor('#7F8C8D'),
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage <= 50) {
      return HexColor('#2ECC71'); // Vert pour faible consommation
    } else if (percentage <= 80) {
      return HexColor('#F39C12'); // Orange pour consommation modérée
    } else {
      return HexColor('#E74C3C'); // Rouge pour forte consommation
    }
  }
}
