import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class AuthSignupEvent extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;
  final bool activated;
  final String role;
  final String profil;
  final String adresse;
  final String dateNaissance;
  final String lieuNaissance;

  const AuthSignupEvent({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
    this.activated = true,
    this.role = "USER",
    this.profil = "SITE_MANAGER",
    this.adresse = '',
    this.dateNaissance = '',
    this.lieuNaissance = '',
  });

  @override
  List<Object> get props => [
    firstName,
    lastName,
    email,
    password,
    phone,
    activated,
    role,
    profil,
    adresse,
    dateNaissance,
    lieuNaissance,
  ];
}

class AuthLogoutEvent extends AuthEvent {}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}



class AuthChangePasswordEvent extends AuthEvent {
  final String email;
  final String password;
  final String newPassword;

  const AuthChangePasswordEvent({
    required this.email,
    required this.password,
    required this.newPassword,
  });

  @override
  List<Object> get props => [email, password, newPassword];
}


