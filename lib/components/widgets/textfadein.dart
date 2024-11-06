import 'package:flutter/material.dart';

class TextFadeIn extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TextFadeIn({
    Key? key,
    required this.text,
    required this.style,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  _TextFadeInState createState() => _TextFadeInState();
}

class _TextFadeInState extends State<TextFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, _fadeAnimation.value],
              colors: [
                Colors.transparent,
                Colors.white,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Text(
            widget.text,
            style: widget.style,
          ),
        );
      },
    );
  }
}
