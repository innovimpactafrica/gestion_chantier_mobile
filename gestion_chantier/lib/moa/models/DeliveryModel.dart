class DeliveryModel {
  final int id;
  final DateTime orderDate;
  final String status;
  final Property property;
  final Supplier supplier;
  final List<DeliveryItem> items;

  DeliveryModel({
    required this.id,
    required this.orderDate,
    required this.status,
    required this.property,
    required this.supplier,
    required this.items,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'],
      orderDate: DateTime(
        json['orderDate'][0],
        json['orderDate'][1],
        json['orderDate'][2],
        json['orderDate'][3],
        json['orderDate'][4],
        json['orderDate'][5],
      ),
      status: json['status'],
      property: Property.fromJson(json['property']),
      supplier: Supplier.fromJson(json['supplier']),
      items:
          (json['items'] as List).map((e) => DeliveryItem.fromJson(e)).toList(),
    );
  }
}

class Property {
  final int id;
  final String name;
  Property({required this.id, required this.name});
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(id: json['id'], name: json['name']);
  }
}

class Supplier {
  final int id;
  final String prenom;
  final String nom;
  final String telephone;
  Supplier({
    required this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
  });
  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      prenom: json['prenom'],
      nom: json['nom'],
      telephone: json['telephone'],
    );
  }
}

class DeliveryItem {
  final int id;
  final int materialId;
  final int quantity;
  final double unitPrice;
  DeliveryItem({
    required this.id,
    required this.materialId,
    required this.quantity,
    required this.unitPrice,
  });
  factory DeliveryItem.fromJson(Map<String, dynamic> json) {
    return DeliveryItem(
      id: json['id'],
      materialId: json['materialId'],
      quantity: json['quantity'],
      unitPrice: (json['unitPrice'] as num).toDouble(),
    );
  }
}
