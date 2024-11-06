import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TypingIndicator extends StatelessWidget {
  final Color color;
  final double size;

  const TypingIndicator({
    Key? key,
    this.color = Colors.grey,
    this.size = 50.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: LoadingAnimationWidget.waveDots(
            color: color,
            size: size,
          ),
        ),
      ),
    );
  }
}
