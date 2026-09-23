import 'package:lets_chat/core/usecase/usecase.dart';
import 'package:lets_chat/core/utils/typedef.dart';
import 'package:lets_chat/domain_layer/usecases/params/auth_params.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase implements UseCase<FutureUserEntity, AuthParams> {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  @override
  FutureUserEntity call(AuthParams input) {
    return repository.login(email: input.email, password: input.password);
  }
}
