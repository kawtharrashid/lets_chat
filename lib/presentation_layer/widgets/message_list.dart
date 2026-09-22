import 'package:flutter/material.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';
import 'package:lets_chat/presentation_layer/widgets/custom_message.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MessageList extends StatelessWidget {
  final List<MessageEntity> messages;
  final String userId;
  final ScrollController controller;
  final bool isLoadingMore;

  const MessageList({
    Key? key,
    required this.messages,
    required this.userId,
    required this.controller,
    this.isLoadingMore = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The list is `reverse: true`, so the last item lands at the visual
    // top of the screen — that's where older messages live, which is
    // exactly where a "loading more" indicator belongs.
    final itemCount = messages.length + (isLoadingMore ? 1 : 0);

    return ListView.separated(
      reverse: true,
      physics: const AlwaysScrollableScrollPhysics(),
      controller: controller,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (isLoadingMore && index == messages.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: LoadingAnimationWidget.hexagonDots(
                  color: kPrimaryColor,
                  size: 24,
                ),
              ),
            ),
          );
        }
        final message = messages[index];

        return CustomMessage(
          key: ValueKey(
            message.clientId ?? message.id ?? '${message.senderId}_$index',
          ),
          messageText: message.text,
          isSender: message.senderId == userId,
          isPending: message.isPending,
          isFailed: message.isFailed,
        );
      },
    );
  }
}
