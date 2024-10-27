import 'package:flutter/material.dart';
import 'package:githubrag/models/styles.dart';

class ErrorDialogCustom extends StatelessWidget {
  final String title;
  final String message;

  const ErrorDialogCustom(
      {super.key, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("OK", style: TextStyle(color: Colors.black)),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(WidgetStyle.borderRadius),
      ),
    );
  }
}
