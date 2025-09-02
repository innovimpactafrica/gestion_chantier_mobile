class AuthorityModel {
  final String authority;

  AuthorityModel({required this.authority});

  factory AuthorityModel.fromJson(Map<String, dynamic> json) {
    return AuthorityModel(authority: json['authority'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {"authority": authority};
  }

  static List<AuthorityModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => AuthorityModel.fromJson(e)).toList();
  }
}
