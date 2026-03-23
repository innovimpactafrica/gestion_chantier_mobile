import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class LocaleEvent {}
class LoadLocaleEvent extends LocaleEvent {}
class ChangeLocaleEvent extends LocaleEvent {
  final Locale locale;
  ChangeLocaleEvent(this.locale);
}

class LocaleState {
  final Locale locale;
  LocaleState(this.locale);
}

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const _key = 'app_locale';

  LocaleBloc() : super(LocaleState(const Locale('fr'))) {
    on<LoadLocaleEvent>(_onLoad);
    on<ChangeLocaleEvent>(_onChange);
  }

  Future<void> _onLoad(LoadLocaleEvent event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'fr';
    emit(LocaleState(Locale(code)));
  }

  Future<void> _onChange(ChangeLocaleEvent event, Emitter<LocaleState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, event.locale.languageCode);
    emit(LocaleState(event.locale));
  }
}
