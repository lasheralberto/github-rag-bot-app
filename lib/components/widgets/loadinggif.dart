import 'package:flutter/material.dart';
import 'dart:async';

class LoadingImage extends StatefulWidget {
  final double opacity; // Opacidad de la imagen
  final double size; // Tamaño del widget
  final bool isIndexingRepo;
  final String gifPath;

  const LoadingImage(
      {super.key,
      required this.isIndexingRepo,
      this.opacity = 0.4, // Valor por defecto de opacidad
      this.size = 300, // Tamaño por defecto
      required this.gifPath});

  @override
  _LoadingImageState createState() => _LoadingImageState();
}

class _LoadingImageState extends State<LoadingImage> {
  late Timer _timer; // Temporizador para cambiar el texto
  List<String> texts = [
    'Indexing repository...',
    'Fetching data...',
    'Processing request...',
    "This may take up few minutes...",
    "Just a second.."
  ];
  String currentText = '';

  @override
  void initState() {
    super.initState();
    currentText = texts[0]; // Establecer el primer texto

    // Iniciar el temporizador
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _updateText();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancelar el temporizador al destruir el widget
    super.dispose();
  }

  void _updateText() {
    setState(() {
      // Cambiar al siguiente texto
      currentText = texts[(texts.indexOf(currentText) + 1) % texts.length];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: widget.size,
        width: widget.size,
        child: Opacity(
          opacity: widget.opacity, // Ajusta la opacidad
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  widget.gifPath, // Ruta de la imagen en assets
                  fit: BoxFit
                      .scaleDown, // Hace que la imagen cubra todo el espacio
                ),
              ),
              if (widget.isIndexingRepo) const SizedBox(height: 10),
              if (widget.isIndexingRepo)
                Text(
                  currentText,
                  style: const TextStyle(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
