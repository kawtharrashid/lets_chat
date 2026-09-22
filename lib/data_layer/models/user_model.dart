import 'package:firebase_auth/firebase_auth.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';

class UserModel {
  final String uid;
  final String email;

  const UserModel({
    required this.uid,
    required this.email,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
    );
  }
}
