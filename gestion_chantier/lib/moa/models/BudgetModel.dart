import 'package:gestion_chantier/moa/models/RealEstateModel.dart';

class BudgetModel {
  final int id;
  final double plannedBudget;
  final double consumedBudget;
  final double remainingBudget;
  final RealEstateModel property;

  BudgetModel({
    required this.id,
    required this.plannedBudget,
    required this.consumedBudget,
    required this.remainingBudget,
    required this.property,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] ?? 0,
      plannedBudget: (json['plannedBudget'] ?? 0).toDouble(),
      consumedBudget: (json['consumedBudget'] ?? 0).toDouble(),
      remainingBudget: (json['remainingBudget'] ?? 0).toDouble(),
      property: RealEstateModel.fromJson(json['property'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plannedBudget': plannedBudget,
      'consumedBudget': consumedBudget,
      'remainingBudget': remainingBudget,
      'property': property.toJson(),
    };
  }

  static List<BudgetModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => BudgetModel.fromJson(e)).toList();
  }
}
