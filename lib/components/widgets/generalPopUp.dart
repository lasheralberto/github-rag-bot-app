import 'package:flutter/material.dart';

class Generalpopup extends StatefulWidget {
  String title;
  String text;
  Generalpopup({super.key, required this.text, required this.title});

  @override
  State<Generalpopup> createState() => _GeneralpopupState();
}

class _GeneralpopupState extends State<Generalpopup> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Text(widget.text),
      ),
    );
  }
}
