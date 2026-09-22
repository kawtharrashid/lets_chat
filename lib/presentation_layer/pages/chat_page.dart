import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/entities/user_entity.dart';
import 'package:lets_chat/presentation_layer/cubits/auth_cubit/auth_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_cubit.dart';
import 'package:lets_chat/presentation_layer/cubits/chat_cubit/chat_state.dart';
import 'package:lets_chat/presentation_layer/widgets/chat_app_bar.dart';
import 'package:lets_chat/presentation_layer/widgets/message_list.dart';
import 'package:lets_chat/presentation_layer/widgets/message_input.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatPage extends StatefulWidget {
  final UserEntity user;

  const ChatPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  static const String id = '/chat';

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  DateTime? _lastLoadMoreTime;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _animateToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      final chatCubit = context.read<ChatCubit>();
      final now = DateTime.now();
      final canTrigger = _lastLoadMoreTime == null ||
          now.difference(_lastLoadMoreTime!).inMilliseconds > 700;

      if (!chatCubit.isLoadingMore &&
          position.maxScrollExtent > 0 &&
          canTrigger &&
          !chatCubit.hasReachedEnd) {
        _lastLoadMoreTime = now;
        chatCubit.loadMoreMessages();
      }
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final authCubit = context.read<AuthCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await authCubit.logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.user.uid;

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: ChatAppBar(
        onLogout: () => _confirmLogout(context),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          left: 8,
          right: 8,
          top: 8,
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.messagesStatus == ChatMessagesStatus.loading) {
                    return Center(
                      child: LoadingAnimationWidget.hexagonDots(
                        color: kPrimaryColor,
                        size: 50,
                      ),
                    );
                  }

                  if (state.messagesStatus == ChatMessagesStatus.failure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.messagesError ?? 'Failed to load messages.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (state.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages yet.',
                      ),
                    );
                  }

                  return MessageList(
                    messages: state.messages,
                    userId: userId,
                    controller: _scrollController,
                    isLoadingMore: state.isLoadingMore,
                  );
                },
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              buildWhen: (previous, current) =>
                  previous.sendMessageStatus != current.sendMessageStatus,
              builder: (context, state) {
                return MessageInput(
                  controller: _messageController,
                  isSending:
                      state.sendMessageStatus == SendMessageStatus.sending,
                  onSend: (text) {
                    context.read<ChatCubit>().sendMessage(
                          text: text,
                          userId: userId,
                        );

                    _messageController.clear();
                    _animateToBottom();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
