import 'package:flutter/material.dart';
import 'package:lets_chat/core/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSend;
  final bool isSending;

  const MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  }) : super(key: key);

  void _submit() {
    if (isSending) {
      return;
    }

    final text = controller.text.trim();

    if (text.isEmpty) {
      return;
    }

    onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        controller: controller,
        enabled: !isSending,
        onSubmitted: (_) {
          _submit();
        },
        keyboardType: TextInputType.multiline,
        minLines: 1,
        maxLines: 5,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            tooltip: 'Send message',
            icon: isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: LoadingAnimationWidget.hexagonDots(
                      color: kPrimaryColor,
                      size: 20,
                    ),
                  )
                : const Icon(
                    Icons.send_rounded,
                    color: kPrimaryColor,
                  ),
            onPressed: isSending ? null : _submit,
          ),
          hintText: 'Type a message...',
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }
}
