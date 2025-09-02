import 'package:equatable/equatable.dart';

abstract class DeliveryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDeliveries extends DeliveryEvent {
  final int propertyId;
  final int page;
  final int size;
  FetchDeliveries(this.propertyId, {this.page = 0, this.size = 10});

  @override
  List<Object?> get props => [propertyId, page, size];
}
