import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/usecases/load_messages_usecase.dart';
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
          current.errorMessage != null &&
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
          ),
        );
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.initial:
              if (_currentPage == null) {
                return Scaffold(
                  body: Center(
                    child: LoadingAnimationWidget.hexagonDots(
                      color: kPrimaryColor,
                      size: 50,
                    ),
                  ),
                );
              }
              return _currentPage!;
            case AuthStatus.loading:
              if (_currentPage != null) {
                return _currentPage!;
              }

              return Scaffold(
                body: Center(
                  child: LoadingAnimationWidget.hexagonDots(
                    color: kPrimaryColor,
                    size: 50,
                  ),
                ),
              );

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
                )..getMessages(),
                child: ChatPage(user: user),
              );

              return _currentPage!;

            case AuthStatus.unauthenticated:
            case AuthStatus.failure:
              _currentPage = const LoginPage();
              return _currentPage!;
          }
        },
      ),
    );
  }
}
