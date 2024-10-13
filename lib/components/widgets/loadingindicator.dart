import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size; // Tamaño del indicador de carga

  const LoadingIndicator({
    super.key,
    this.size = 20, // Tamaño por defecto
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: const CircularProgressIndicator.adaptive(),
    );
  }
}
