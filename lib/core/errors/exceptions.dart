class AuthenticationException implements Exception {
  final String code;

  const AuthenticationException(this.code);
}

class FirestoreException implements Exception {
  final String code;

  const FirestoreException(this.code);
}
