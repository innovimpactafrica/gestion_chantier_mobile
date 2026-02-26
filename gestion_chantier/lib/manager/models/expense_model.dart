class ExpenseModel {
  final int id;
  final String description;
  final DateTime date;
  final double amount;
  final String evidence;

  ExpenseModel({
    required this.id,
    required this.description,
    required this.date,
    required this.amount,
    required this.evidence,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      description: json['description'],
      evidence: json['evidence']??"",


      date: DateTime(json['date'][0], json['date'][1], json['date'][2]),
      amount: (json['amount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "description": description,
      "evidence": evidence,
      "date": [date.year, date.month, date.day],
      "amount": amount,
    };
  }
}
