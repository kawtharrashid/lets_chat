import 'package:lets_chat/core/usecase/usecase.dart';
import 'package:lets_chat/core/utils/typedef.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase
    implements NoParamsUseCase<NullableFutureUserEntity> {
  final AuthRepository repository;

  GetCurrentUserUseCase({required this.repository});

  @override
  NullableFutureUserEntity call() {
    return repository.getCurrentUser();
  }
}
