import 'package:flutter/material.dart';
import 'package:gestion_chantier/moa/pages/splash/welcome.dart';

class SplashScreensecond extends StatefulWidget {
  const SplashScreensecond({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreensecond>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Configuration de l'animation
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Démarrer l'animation
    _animationController.forward();

    // Navigation après 3 secondes
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE85A2B), // Orange
              Color(0xFFD4481F), // Orange plus foncé
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icône en losange
                Transform.rotate(
                  angle: 0.785398, // 45 degrés
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                // Texte
                Text(
                  'Innovchantiers inc.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  'Optimisez la gestion de vos chantiers, simplement.',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 225, 225, 225),
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
