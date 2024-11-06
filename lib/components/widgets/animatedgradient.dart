import 'package:flutter/material.dart';
import 'package:githubrag/models/colors.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AnimatedGradientBackgroundState createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _beginAlignment;
  late Animation<Alignment> _endAlignment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 200),
      vsync: this,
    )..repeat(reverse: true);

    _beginAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        weight: 1.0,
        tween: AlignmentTween(
          begin: const Alignment(-2.0, 0.0),
          end: const Alignment(0.0, 0.0),
        ),
      ),
    ]).animate(_controller);

    _endAlignment = TweenSequence<Alignment>([
      TweenSequenceItem(
        weight: 1.0,
        tween: AlignmentTween(
          begin: const Alignment(0.0, 0.0),
          end: const Alignment(2.0, 0.0),
        ),
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              transform: GradientRotation(1.0),
              radius: 2.5,
              tileMode: TileMode.decal,
              colors: [
                Color(0xFF1A1A2E), // Azul muy oscuro
                Color(0xFF1B1C34),
                Color(0xFF1C1E3A),
                Color(0xFF1E2040),
                Color.fromARGB(255, 14, 48, 90), // Azul principal
                Color(0xFF0F3460), // Azul principal
                Color(0xFF203A6D),
                Color(0xFF2E447E),
                Color.fromARGB(255, 43, 61, 116),
                Color(0xFF3F5295),
                Color.fromARGB(255, 53, 65, 119), // Azul claro
              ],
              stops: [0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0],
            ),
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
