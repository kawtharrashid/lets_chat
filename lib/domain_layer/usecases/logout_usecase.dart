import 'package:lets_chat/core/usecase/usecase.dart';

import '../repositories/auth_repository.dart';

class LogoutUseCase implements NoParamsUseCase<Future<void>> {
  final AuthRepository repository;

  LogoutUseCase({required this.repository});

  @override
  Future<void> call() {
    return repository.logout();
  }
}
