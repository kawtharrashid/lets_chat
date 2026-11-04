import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/core/errors/error_message_mapper.dart';
import 'package:lets_chat/domain_layer/usecases/load_more_messages_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/send_message_usecase.dart';
import 'package:lets_chat/domain_layer/usecases/watch_messages_usecase.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_state.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_cubit.dart';
import 'package:lets_chat/presentation_layer/pages/chat_page.dart';
import 'package:lets_chat/presentation_layer/pages/login_page.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AuthGate extends StatefulWidget {
  final WatchMessagesUseCase watchMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final LoadMoreMessagesUseCase loadMoreMessagesUseCase;

  const AuthGate({
    Key? key,
    required this.watchMessagesUseCase,
    required this.sendMessageUseCase,
    required this.loadMoreMessagesUseCase,
  }) : super(key: key);

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Widget? _currentPage;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
          current.status == AuthStatus.failure &&
          current.errorCode != null &&
          previous.errorCode != current.errorCode,
      listener: (context, state) {
        final errorCode = state.errorCode;

        if (errorCode == null) return;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(ErrorMessageMapper.map(errorCode)),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
            ),
          );
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.initial:
              if (_currentPage != null) {
                return _currentPage!;
              }

              return _loadingScreen();

            case AuthStatus.loading:
              if (_currentPage != null) {
                return _currentPage!;
              }

              return _loadingScreen();

            case AuthStatus.authenticated:
              final user = state.user;

              if (user == null) {
                _currentPage = const LoginPage();
                return _currentPage!;
              }

              _currentPage = BlocProvider<ChatCubit>(
                create: (_) => ChatCubit(
                  watchMessagesUseCase: widget.watchMessagesUseCase,
                  sendMessageUseCase: widget.sendMessageUseCase,
                  loadMoreMessagesUseCase: widget.loadMoreMessagesUseCase,
                )..watchMessages(),
                child: ChatPage(user: user),
              );

              return _currentPage!;

            case AuthStatus.unauthenticated:
              _currentPage = const LoginPage();
              return _currentPage!;

            case AuthStatus.failure:
              // Keep the current page on failure.
              // A failed logout must not automatically send the user
              // to the login page.
              return _currentPage ?? const LoginPage();
          }
        },
      ),
    );
  }

  Widget _loadingScreen() {
    return Scaffold(
      body: Center(
        child: LoadingAnimationWidget.hexagonDots(
          color: kPrimaryColor,
          size: 50,
        ),
      ),
    );
  }
}
