import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gestion_chantier/manager/repository/material_top_used_repository.dart';
import 'material_top_used_event.dart';
import 'material_top_used_state.dart';

class MaterialTopUsedBloc
    extends Bloc<MaterialTopUsedEvent, MaterialTopUsedState> {
  final MaterialTopUsedRepository repository;
  MaterialTopUsedBloc(this.repository) : super(MaterialTopUsedInitial()) {
    on<FetchMaterialTopUsed>((event, emit) async {
      emit(MaterialTopUsedLoading());
      try {
        final materials = await repository.fetchTopUsedMaterials(
          event.propertyId,
        );
        emit(MaterialTopUsedLoaded(materials));
      } catch (e) {
        emit(MaterialTopUsedError(e.toString()));
      }
    });
  }
}
