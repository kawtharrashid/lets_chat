import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/core/firebase_options.dart';
import 'package:lets_chat/data_layer/datasources/auth_remote_datasource.dart';
import 'package:lets_chat/data_layer/datasources/chat_remote_datasource.dart';
import 'package:lets_chat/data_layer/repositories/auth_repository_impl.dart';
import 'package:lets_chat/data_layer/repositories/chat_repository_impl.dart';
import 'package:lets_chat/domain_layer/usecases/get_current_user_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/get_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/get_more_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/login_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/logout_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/register_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_cubit.dart';
import 'package:lets_chat/presentation_layer/pages/register_page.dart';
import 'package:lets_chat/presentation_layer/widgets/auth_gate.dart';
import 'package:lets_chat/presentation_layer/pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LetsChat());
}

class LetsChat extends StatelessWidget {
  const LetsChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authDatasource = AuthRemoteDatasource(
      FirebaseAuth.instance,
    );

    final authRepository = AuthRepositoryImpl(
      authDatasource,
    );

    final loginUseCase = LoginUseCase(
      authRepository,
    );

    final registerUseCase = RegisterUseCase(
      authRepository,
    );

    final getCurrentUserUseCase = GetCurrentUserUseCase(
      repository: authRepository,
    );

    final logoutUseCase = LogoutUseCase(
      repository: authRepository,
    );
    final chatDatasource = ChatRemoteDatasource(
      FirebaseFirestore.instance,
    );

    final chatRepository = ChatRepositoryImpl(
      chatDatasource,
    );

    final getMessagesUseCase = GetMessagesUseCase(
      repository: chatRepository,
    );

    final getMoreMessagesUseCase = GetMoreMessagesUseCase(
      repository: chatRepository,
    );

    final sendMessageUseCase = SendMessageUseCase(
      repository: chatRepository,
    );

    return BlocProvider<AuthCubit>(
      create: (_) => AuthCubit(
        loginUseCase: loginUseCase,
        registerUseCase: registerUseCase,
        getCurrentUserUseCase: getCurrentUserUseCase,
        logoutUseCase: logoutUseCase,
      )..initialize(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(
          getMessagesUseCase: getMessagesUseCase,
          sendMessageUseCase: sendMessageUseCase,
          getMoreMessagesUseCase: getMoreMessagesUseCase,
        ),
        routes: {
          LoginPage.id: (_) => const LoginPage(),
          RegisterPage.id: (_) => const RegisterPage(),
        },
      ),
    );
  }
}
