import 'package:flutter/material.dart';

class AnimatedLogoText extends StatefulWidget {
  final bool? indexing;
  AnimatedLogoText({Key? key, required this.indexing}) : super(key: key);

  @override
  _AnimatedLogoTextState createState() => _AnimatedLogoTextState();
}

class _AnimatedLogoTextState extends State<AnimatedLogoText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Inicializa el AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
          seconds: 8), // Duración más larga para animación irregular
    )..repeat(); // Repite la animación indefinidamente

    // Define una animación no lineal con variaciones de velocidad
    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeInOutQuad, // Curva de aceleración/desaceleración
        ),
      ),
    );
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
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Colors.blueAccent,
                Colors.greenAccent,
                Colors.purpleAccent,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ],
            ).createShader(rect);
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.indexing == true
                      ? RotationTransition(
                          turns:
                              _rotationAnimation, // Usa la animación de rotación no lineal
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Image.asset('media/images/logo.png'),
                          ),
                        )
                      : SizedBox(
                          height: 100,
                          width: 100,
                          child: Image.asset('media/images/logo.png'),
                        ),
                  const SizedBox(width: 16),
                  const Text(
                    "RAG-iT",
                    style: TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              widget.indexing == true
                  ? const Text(
                      'Indexing repository...',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : const SizedBox.shrink()
            ],
          ),
        );
      },
    );
  }
}
