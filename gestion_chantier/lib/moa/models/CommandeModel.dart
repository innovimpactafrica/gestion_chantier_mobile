import 'package:gestion_chantier/moa/models/PropertyType.dart';
import 'package:gestion_chantier/moa/models/UserModel.dart';

class CommandeModel {
  final int id;
  final DateTime orderDate;
  final String status;
  final PropertyType property;
  final UserModel supplier;
  final List<CommandeItem> items;
  final dynamic trackingInfo;

  CommandeModel({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.property,
    required this.supplier,
    required this.items,
    this.trackingInfo,
  });

  factory CommandeModel.fromJson(Map<String, dynamic> json) {
    return CommandeModel(
      id: _parseId(json['id']),
      orderDate: _parseDateTimeList(json['orderDate']),
      status: json['status']?.toString() ?? 'PENDING',
      property: PropertyType.fromJson(json['property'] ?? {}),
      supplier: UserModel.fromJson(json['supplier'] ?? {}),
      items:
          (json['items'] as List<dynamic>? ?? [])
              .map((item) => CommandeItem.fromJson(item))
              .toList(),
      trackingInfo: json['trackingInfo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderDate': [
        orderDate.year,
        orderDate.month,
        orderDate.day,
        orderDate.hour,
        orderDate.minute,
        orderDate.second,
        orderDate.microsecond,
      ],
      'status': status,
      'property': property.toJson(),
      'supplier': supplier.toJson(),
      'items': items.map((item) => item.toJson()).toList(),
      'trackingInfo': trackingInfo,
    };
  }

  static int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  static DateTime _parseDateTimeList(List<dynamic> list) {
    try {
      return DateTime(
        list[0],
        list[1],
        list[2],
        list[3],
        list[4],
        list[5],
        list.length > 6 ? list[6] : 0,
      );
    } catch (e) {
      return DateTime.now();
    }
  }
}

class CommandeItem {
  final int id;
  final int materialId;
  final int quantity;
  final int unitPrice;
  final String? materialLabel;

  CommandeItem({
    required this.id,
    required this.materialId,
    required this.quantity,
    required this.unitPrice,
    this.materialLabel,
  });

  factory CommandeItem.fromJson(Map<String, dynamic> json) {
    return CommandeItem(
      id: json['id'] ?? 0,
      materialId: json['material']?['id'] ?? json['materialId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      unitPrice: _parseInt(json['unitPrice']),
      materialLabel: json['material']?['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialId': materialId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
