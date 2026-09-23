import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';

//it is better to add it inside domain layer latter
typedef MessageEntityList = List<MessageEntity>;
typedef FutureMessageEntityList = Future<List<MessageEntity>>;
typedef NullableFutureUserEntity = Future<UserEntity?>;
typedef MessageEntityStream = Stream<MessageEntityList>;
typedef FutureUserEntity = Future<UserEntity>;
