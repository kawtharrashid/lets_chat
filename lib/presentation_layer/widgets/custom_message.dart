import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lets_chat/core/constants.dart';

class CustomMessage extends StatelessWidget {
  const CustomMessage({
    Key? key,
    required this.messageText,
    required this.isSender,
    this.isPending = false,
    this.isFailed = false,
  }) : super(key: key);

  final String messageText;
  final bool isSender;

  /// True while this message was added optimistically and is still being
  /// written to Firestore.
  final bool isPending;

  /// True if the optimistic write ended up failing.
  final bool isFailed;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final maxWidth = math.min(screenWidth * 0.75, 500.0);

    final bubbleColor = isFailed
        ? Colors.red.shade100
        : (isSender ? senderMessage : receiverMessage);

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Opacity(
        opacity: isPending ? 0.6 : 1,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(15),
              topRight: const Radius.circular(15),
              bottomLeft: isSender ? const Radius.circular(15) : Radius.zero,
              bottomRight: isSender ? Radius.zero : const Radius.circular(15),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  messageText,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
              ),
              if (isPending || isFailed) ...[
                const SizedBox(width: 6),
                if (isPending)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (isFailed)
                  const Icon(
                    Icons.error_outline,
                    size: 16,
                    color: Colors.red,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
