import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/moa/pages/auth/signin.dart';
import 'package:gestion_chantier/moa/utils/HexColor.dart';
import 'package:gestion_chantier/moa/widgets/navitems.dart';
import 'package:gestion_chantier/moa/bloc/auth/auth_bloc.dart' as moa_auth;
import 'package:gestion_chantier/moa/bloc/home/home_bloc.dart' as moahome;
import 'package:gestion_chantier/moa/bloc/home/home_event.dart'
    as moahome_event;
import 'package:gestion_chantier/moa/repository/auth_repository.dart'
    as moarepo;
import 'package:gestion_chantier/moa/bloc/auth/auth_bloc.dart';
import 'package:gestion_chantier/moa/bloc/auth/auth_event.dart';
import 'package:gestion_chantier/moa/bloc/auth/auth_state.dart';
import 'package:gestion_chantier/moa/bloc/home/home_bloc.dart';
import 'package:gestion_chantier/moa/bloc/home/home_event.dart';
import 'package:gestion_chantier/ouvrier/pages/ouvrier_main_screen.dart';
// duplicate import removed

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticatedState) {
            // Connexion réussie - afficher les infos utilisateur
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Bienvenue !'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nom : ${state.user.nom}'),
                        Text('Prénom : ${state.user.prenom}'),
                        Text('Email : ${state.user.email}'),
                        Text('Profil : ${state.user.profil}'),
                        Text('Téléphone : ${state.user.telephone}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Rafraîchir l'utilisateur courant dans le HomeBloc
                          context.read<HomeBloc>().add(LoadCurrentUserEvent());
                          // Redirection selon le profil
                          final profil = state.user.profil.toLowerCase();
                          if (profil == 'worker' || profil == 'ouvrier') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const OuvrierMainScreen(),
                              ),
                            );
                          } else if (profil == 'moa') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider<moa_auth.AuthBloc>(
                                          create: (_) => moa_auth.AuthBloc(),
                                        ),
                                        BlocProvider<moahome.HomeBloc>(
                                          create:
                                              (_) => moahome.HomeBloc(
                                                authRepository:
                                                    moarepo.AuthRepository(),
                                              )..add(
                                                moahome_event.LoadCurrentUserEvent(),
                                              ),
                                        ),
                                      ],
                                      child: const MainScreen(),
                                    ),
                              ),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(),
                              ),
                            );
                          }
                        },
                        child: Text('Continuer'),
                      ),
                    ],
                  ),
            );
            // Ne pas rediriger tout de suite, attendre la fermeture du dialog
            return;
          } else if (state is AuthErrorState) {
            // Erreur de connexion
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 4),
              ),
            );
          } else if (state is AuthForgotPasswordSentState) {
            // Confirmation d'envoi du lien de récupération
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Un lien de récupération a été envoyé à ${state.email}',
                ),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.black,
                  size: 24,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre principal
                    Text(
                      'Connectez-Vous',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 12),

                    // Sous-titre
                    Text(
                      'Accédez à votre tableau de bord',
                      style: TextStyle(
                        fontSize: 13,
                        color: HexColor('#6C7278'),
                        height: 1.4,
                      ),
                    ),

                    SizedBox(height: 22),

                    // Champ Email
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HexColor('#CBD5E1')),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: state is! AuthLoadingState,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir votre email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Veuillez saisir un email valide';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'ex. pro@chantier.com',
                          hintStyle: TextStyle(
                            color: HexColor('#9C9AA5'),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Champ Mot de passe
                    Text(
                      'Mot de passe',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: HexColor('#CBD5E1')),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enabled: state is! AuthLoadingState,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez saisir votre mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: 'Minimum 8 caractères',
                          hintStyle: TextStyle(
                            color: HexColor('#9C9AA5'),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: HexColor('#ACB5BB'),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          errorStyle: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        style: TextStyle(fontSize: 16),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Lien mot de passe oublié
                    Container(
                      padding: EdgeInsets.only(left: 199),
                      child: GestureDetector(
                        onTap:
                            state is AuthLoadingState
                                ? null
                                : () {
                                  _showForgotPasswordDialog(context);
                                },
                        child: Text(
                          'Mot de passe oublié ?',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color:
                                state is AuthLoadingState
                                    ? Colors.grey
                                    : HexColor('#FF5C02'),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                            height: 1.40,
                            letterSpacing: -0.14,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Bouton Se Connecter
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed:
                            state is AuthLoadingState
                                ? null
                                : () {
                                  if (_formKey.currentState!.validate()) {
                                    // Déclencher l'événement de connexion
                                    BlocProvider.of<AuthBloc>(context).add(
                                      AuthLoginEvent(
                                        email: _emailController.text.trim(),
                                        password: _passwordController.text,
                                      ),
                                    );
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              state is AuthLoadingState
                                  ? Colors.grey[400]
                                  : HexColor('#FF5C02'),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child:
                            state is AuthLoadingState
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                )
                                : Text(
                                  'Se Connecter',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    ),

                    SizedBox(height: 22),

                    // Séparateur "Ou"
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Ou',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),

                    SizedBox(height: 12),

                    // Boutons Google et Apple
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed:
                                  state is AuthLoadingState
                                      ? null
                                      : () {
                                        _showSocialLoginNotImplemented(
                                          'Google',
                                        );
                                      },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      state is AuthLoadingState
                                          ? Colors.grey[400]!
                                          : Colors.grey[300]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.g_mobiledata_outlined,
                                    color:
                                        state is AuthLoadingState
                                            ? Colors.grey[400]
                                            : Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Google',
                                    style: TextStyle(
                                      color:
                                          state is AuthLoadingState
                                              ? Colors.grey[400]
                                              : Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 16),

                        Expanded(
                          child: SizedBox(
                            height: 42,
                            child: OutlinedButton(
                              onPressed:
                                  state is AuthLoadingState
                                      ? null
                                      : () {
                                        _showSocialLoginNotImplemented('Apple');
                                      },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color:
                                      state is AuthLoadingState
                                          ? Colors.grey[400]!
                                          : Colors.grey[300]!,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.apple,
                                    color:
                                        state is AuthLoadingState
                                            ? Colors.grey[400]
                                            : Colors.black,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Apple',
                                    style: TextStyle(
                                      color:
                                          state is AuthLoadingState
                                              ? Colors.grey[400]
                                              : Colors.black,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Spacer(),

                    // Lien d'inscription en bas
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pas de compte ?  ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                state is AuthLoadingState
                                    ? null
                                    : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignupScreen(),
                                        ),
                                      );
                                    },
                            child: Text(
                              'S\'inscrire',
                              style: TextStyle(
                                color:
                                    state is AuthLoadingState
                                        ? Colors.grey
                                        : HexColor('#FF5C02'),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 44),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final forgotPasswordFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthForgotPasswordSentState) {
              Navigator.of(dialogContext).pop();
            }
          },
          builder: (context, state) {
            return AlertDialog(
              title: Text(
                'Mot de passe oublié',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: forgotPasswordFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Saisissez votre adresse email pour recevoir un lien de réinitialisation.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: state is! AuthLoadingState,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir votre email';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return 'Email invalide';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'Votre email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      state is AuthLoadingState
                          ? null
                          : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Annuler',
                    style: TextStyle(
                      color:
                          state is AuthLoadingState
                              ? Colors.grey
                              : Colors.grey[700],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      state is AuthLoadingState
                          ? null
                          : () {
                            if (forgotPasswordFormKey.currentState!
                                .validate()) {
                              BlocProvider.of<AuthBloc>(context).add(
                                AuthForgotPasswordEvent(
                                  email: emailController.text.trim(),
                                ),
                              );
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        state is AuthLoadingState
                            ? Colors.grey[400]
                            : HexColor('#FF5C02'),
                  ),
                  child:
                      state is AuthLoadingState
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                          : Text(
                            'Envoyer',
                            style: TextStyle(color: Colors.white),
                          ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSocialLoginNotImplemented(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion avec $provider non implémentée'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
