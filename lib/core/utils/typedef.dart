import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';

//it is better to add it inside domain layer latter

// Message typedefs
typedef MessageEntityList = List<MessageEntity>;
typedef FutureMessageEntityList = Future<List<MessageEntity>>;
typedef MessageEntityStream = Stream<MessageEntityList>;

// User typedefs
typedef NullableFutureUserEntity = Future<UserEntity?>;
typedef FutureUserEntity = Future<UserEntity>;
