import 'package:equatable/equatable.dart';
import 'package:gestion_chantier/manager/models/DeliveryModel.dart';

abstract class DeliveryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {}

class DeliveryLoading extends DeliveryState {}

class DeliveryLoaded extends DeliveryState {
  final List<DeliveryModel> deliveries;
  DeliveryLoaded(this.deliveries);
  @override
  List<Object?> get props => [deliveries];
}

class DeliveryError extends DeliveryState {
  final String message;
  DeliveryError(this.message);
  @override
  List<Object?> get props => [message];
}
