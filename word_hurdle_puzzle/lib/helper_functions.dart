import 'package:flutter/material.dart';

void showMsg(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Future<void> showResult({
  required BuildContext context,
  required String title,
  required String body,
  required VoidCallback onPlayAgain,
  required VoidCallback onCancel,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: onCancel, child: const Text('Quit')),
          TextButton(onPressed: onPlayAgain, child: const Text('Play Again')),
        ],
      ),
    ),
  );
}
