import 'package:lets_chat/core/utils/typedef.dart';
import 'package:lets_chat/data_layer/datasources/auth_remote_datasource.dart';
import 'package:lets_chat/data_layer/models/user_model.dart';
import 'package:lets_chat/domain_layer/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource datasource;

  AuthRepositoryImpl(this.datasource);

  @override
  NullableFutureUserEntity getCurrentUser() async {
    final user = datasource.currentUser;

    if (user == null) {
      return null;
    }

    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  FutureUserEntity login({
    required String email,
    required String password,
  }) async {
    final user = await datasource.login(
      email: email,
      password: password,
    );

    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  FutureUserEntity register({
    required String email,
    required String password,
  }) async {
    final user = await datasource.register(
      email: email,
      password: password,
    );

    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  Future<void> logout() {
    return datasource.signOut();
  }
}
