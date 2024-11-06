import 'package:flutter/material.dart';
class TextFadeIn extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration duration;

  const TextFadeIn({
    Key? key,
    required this.text,
    required this.style,
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _TextFadeInState createState() => _TextFadeInState();
}

class _TextFadeInState extends State<TextFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String _displayedText = '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _controller.addListener(_updateText);
    _controller.forward();
  }

  void _updateText() {
    final progress = _controller.value;
    final targetLength = (widget.text.length * progress).round();
    
    if (targetLength != _currentIndex && mounted) {
      setState(() {
        _currentIndex = targetLength;
        _displayedText = widget.text.substring(0, _currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_updateText);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayedText,
      style: widget.style,
    );
  }
}