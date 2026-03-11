// ignore_for_file: file_names

class UserCacheService {
  static final UserCacheService instance = UserCacheService._();
  UserCacheService._();

  Map<String, dynamic>? _data;
  DateTime? _cachedAt;
  static const _ttl = Duration(minutes: 5);

  bool get _isValid =>
      _data != null &&
      _cachedAt != null &&
      DateTime.now().difference(_cachedAt!) < _ttl;

  /// Retourne les données en cache si valides, sinon appelle [fetcher]
  Future<Map<String, dynamic>> get(
    Future<dynamic> Function() fetcher,
  ) async {
    if (_isValid) return _data!;
    final result = await fetcher();
    _data = result as Map<String, dynamic>;
    _cachedAt = DateTime.now();
    return _data!;
  }

  /// À appeler lors de la déconnexion
  void invalidate() {
    _data = null;
    _cachedAt = null;
  }
}
