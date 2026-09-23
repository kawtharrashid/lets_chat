import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:lets_chat/domain_layer/entities/message_entity.dart';

class CustomMessage extends StatelessWidget {
  const CustomMessage({
    Key? key,
    required this.message,
    required this.isSender,
    this.onRetry,
  }) : super(key: key);

  final MessageEntity message;
  final bool isSender;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = math.min(screenWidth * 0.75, 500.0);

    final bubbleColor = isSender ? senderMessage : receiverMessage;

    return Align(
      alignment: isSender ? Alignment.centerLeft : Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            // Message + status indicator
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Message bubble
                Flexible(
                  child: Opacity(
                    opacity: message.isPending ? 0.6 : 1,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: message.isFailed ? Colors.red[200] : bubbleColor,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(15),
                          topRight: const Radius.circular(15),
                          bottomRight: isSender
                              ? const Radius.circular(15)
                              : Radius.zero,
                          bottomLeft: isSender
                              ? Radius.zero
                              : const Radius.circular(15),
                        ),
                      ),
                      child: Text(
                        message.message,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),

                // Status indicator outside the bubble
                if (message.isPending) ...[
                  const SizedBox(width: 6),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimaryColor,
                    ),
                  ),
                ],

                if (message.isFailed) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: Colors.red.shade600,
                  ),
                ],
              ],
            ),

            // Retry action
            if (message.isFailed && onRetry != null)
              Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  right: 2,
                  left: 2,
                ),
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          size: 14,
                          color: Colors.red.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Retry',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
