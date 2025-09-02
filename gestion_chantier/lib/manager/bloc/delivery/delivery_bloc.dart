import 'package:flutter_bloc/flutter_bloc.dart';
import 'delivery_event.dart';
import 'delivery_state.dart';
import 'package:gestion_chantier/manager/repository/delivery_repository.dart';

class DeliveryBloc extends Bloc<DeliveryEvent, DeliveryState> {
  final DeliveryRepository repository;
  DeliveryBloc(this.repository) : super(DeliveryInitial()) {
    on<FetchDeliveries>((event, emit) async {
      emit(DeliveryLoading());
      try {
        final deliveries = await repository.fetchDeliveries(
          event.propertyId,
          page: event.page,
          size: event.size,
        );
        emit(DeliveryLoaded(deliveries));
      } catch (e) {
        emit(DeliveryError(e.toString()));
      }
    });
  }
}
