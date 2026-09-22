import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lets_chat/presentation_layer/widgets/message_input.dart';

void main() {
  group('MessageInput', () {
    late TextEditingController controller;
    late List<String> sentMessages;

    setUp(() {
      controller = TextEditingController();
      sentMessages = <String>[];
    });

    tearDown(() {
      controller.dispose();
    });

    Widget buildTestWidget({
      bool isSending = false,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MessageInput(
            controller: controller,
            isSending: isSending,
            onSend: sentMessages.add,
          ),
        ),
      );
    }

    testWidgets(
      'renders text field and send button',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(
          find.byType(TextField),
          findsOneWidget,
        );

        expect(
          find.byIcon(Icons.send_rounded),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'sends trimmed message when send button is tapped',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.enterText(
          find.byType(TextField),
          '   Hello Flutter   ',
        );

        await tester.tap(
          find.byIcon(Icons.send_rounded),
        );

        await tester.pump();

        expect(
          sentMessages,
          ['Hello Flutter'],
        );
      },
    );

    testWidgets(
      'does not send empty message',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(
          find.byIcon(Icons.send_rounded),
        );

        await tester.pump();

        expect(
          sentMessages,
          isEmpty,
        );
      },
    );

    testWidgets(
      'does not send whitespace-only message',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.enterText(
          find.byType(TextField),
          '     ',
        );

        await tester.tap(
          find.byIcon(Icons.send_rounded),
        );

        await tester.pump();

        expect(
          sentMessages,
          isEmpty,
        );
      },
    );

    testWidgets(
      'sends message when submitted from keyboard',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final textField = find.byType(TextField);

        await tester.tap(textField);

        await tester.enterText(
          textField,
          'Hello from keyboard',
        );

        // For a multiline TextField, use `send` to trigger
        // the submission callback instead of `newline`.
        await tester.testTextInput.receiveAction(
          TextInputAction.send,
        );

        await tester.pump();

        expect(
          sentMessages,
          ['Hello from keyboard'],
        );
      },
    );

    testWidgets(
      'disables text field while sending',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(isSending: true),
        );

        final textField = tester.widget<TextField>(
          find.byType(TextField),
        );

        expect(
          textField.enabled,
          isFalse,
        );
      },
    );

    testWidgets(
      'disables send button while sending',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(isSending: true),
        );

        final sendButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );

        expect(
          sendButton.onPressed,
          isNull,
        );
      },
    );

    testWidgets(
      'does not trigger onSend while sending',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(isSending: true),
        );

        expect(
          sentMessages,
          isEmpty,
        );

        final sendButton = tester.widget<IconButton>(
          find.byType(IconButton),
        );

        expect(
          sendButton.onPressed,
          isNull,
        );
      },
    );

    testWidgets(
      'configures multiline text input',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final textField = tester.widget<TextField>(
          find.byType(TextField),
        );

        expect(
          textField.minLines,
          1,
        );

        expect(
          textField.maxLines,
          5,
        );

        expect(
          textField.keyboardType,
          TextInputType.multiline,
        );
      },
    );
  });
}
