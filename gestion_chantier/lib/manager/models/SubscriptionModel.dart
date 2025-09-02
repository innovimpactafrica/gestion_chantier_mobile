import 'SubscriptionPlan.dart';

class SubscriptionModel {
  final int id;
  final SubscriptionPlan subscriptionPlan;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final int paidAmount;
  final int installmentCount;
  final DateTime? dateInvoice;
  final String status;
  final bool renewed;

  SubscriptionModel({
    required this.id,
    required this.subscriptionPlan,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.paidAmount,
    required this.installmentCount,
    this.dateInvoice,
    required this.status,
    required this.renewed,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? 0,
      subscriptionPlan: SubscriptionPlan.fromJson(
        json['subscriptionPlan'] ?? {},
      ),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      active: json['active'] ?? false,
      paidAmount: json['paidAmount'] ?? 0,
      installmentCount: json['installmentCount'] ?? 0,
      dateInvoice:
          json['dateInvoice'] != null ? _parseDate(json['dateInvoice']) : null,
      status: json['status'] ?? '',
      renewed: json['renewed'] ?? false,
    );
  }

  static DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is List && dateValue.length >= 3) {
      return DateTime(
        dateValue[0] ?? DateTime.now().year,
        dateValue[1] ?? DateTime.now().month,
        dateValue[2] ?? DateTime.now().day,
        dateValue.length > 3 ? dateValue[3] ?? 0 : 0,
        dateValue.length > 4 ? dateValue[4] ?? 0 : 0,
        dateValue.length > 5 ? dateValue[5] ?? 0 : 0,
        dateValue.length > 6 ? (dateValue[6] ?? 0) ~/ 1000000 : 0,
      );
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "subscriptionPlan": subscriptionPlan.toJson(),
      "startDate": [startDate.year, startDate.month, startDate.day],
      "endDate": [endDate.year, endDate.month, endDate.day],
      "active": active,
      "paidAmount": paidAmount,
      "installmentCount": installmentCount,
      "dateInvoice":
          dateInvoice != null
              ? [dateInvoice!.year, dateInvoice!.month, dateInvoice!.day]
              : null,
      "status": status,
      "renewed": renewed,
    };
  }

  static List<SubscriptionModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => SubscriptionModel.fromJson(e)).toList();
  }
}
