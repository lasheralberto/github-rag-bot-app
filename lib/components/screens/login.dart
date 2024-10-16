import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:githubrag/components/screens/chatscreen.dart';
import 'package:githubrag/components/widgets/github.dart';
import 'package:githubrag/models/colors.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  final List<String> slogans = [
    "Decode your team's code like a pro!",
    "Ask it, crack it, code it!",
    "Crack the code, ask away!",
  ];

  @override
  void initState() {
    super.initState();

    // Inicializamos el controlador de animación
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Cambia el texto al completar la animación de desaparición
        setState(() {
          _currentIndex = (_currentIndex + 1) % slogans.length;
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        // Inicia la animación para que vuelva a aparecer
        _controller.forward();
      }
    });

    // Comienza la animación
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Liberamos los recursos
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: Center(
        // Añadimos un Center para alinear todo el contenido centrado
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Centramos horizontalmente
              mainAxisAlignment:
                  MainAxisAlignment.center, // Centramos verticalmente
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
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
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centramos el Row
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              height: 100,
                              width: 100,
                              child: Image.asset('media/logo.png')),
                          const Text(
                            "RAG-iT",
                            style: TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .white, // Este color será afectado por el Shader
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    slogans[_currentIndex],
                    textAlign: TextAlign
                        .center, // Aseguramos que el texto esté centrado
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GitHubLoginButton(
                  onUserData: (user) {
                    if (FirebaseAuth.instance.currentUser != null) {
                      // Retrasa la navegación hasta el siguiente ciclo de renderizado
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return const ChatScreen();
                        }));
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
