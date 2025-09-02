/// Modèle pour représenter une dépense
class ExpenseModel {
  final int id;
  final double amount;
  final String description;
  final DateTime date;
  final String category;

  ExpenseModel({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Convertir le format de date [année, mois, jour] en DateTime
      DateTime parseDate(dynamic dateData) {
        if (dateData is String) {
          return DateTime.tryParse(dateData) ?? DateTime.now();
        }
        if (dateData is List && dateData.length >= 3) {
          return DateTime(
            dateData[0],
            dateData[1],
            dateData.length > 3 ? dateData[2] : 1,
          );
        }
        return DateTime.now();
      }

      return ExpenseModel(
        id: json['id']?.toInt() ?? 0,
        amount: (json['amount'] ?? 0).toDouble(),
        description: json['description']?.toString() ?? 'Pas de description',
        date: parseDate(json['date']),
        category: json['category']?.toString() ?? 'Non catégorisé',
      );
    } catch (e) {
      print('Erreur de parsing ExpenseModel: $e');
      print('Données reçues: $json');
      throw FormatException('Format de données invalide pour les dépenses');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'category': category,
    };
  }
}
