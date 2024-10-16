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
        setState(() {
          _currentIndex = (_currentIndex + 1) % slogans.length;
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Privacy Policy'),
          content: SingleChildScrollView(
            child: Text('RAG-iT Privacy Policy\n\n'
                '1. Information We Collect:\n'
                '   - GitHub account information\n'
                '   - Repository data\n'
                '   - Chat conversations\n\n'
                '2. How We Use Your Information:\n'
                '   - To provide and improve our services\n'
                '   - To personalize your experience\n'
                '   - To communicate with you\n\n'
                '3. Data Security:\n'
                '   We implement industry-standard security measures.\n\n'
                '4. Third-Party Services:\n'
                '   We use GitHub API and may share necessary data.\n\n'
                '5. Your Rights:\n'
                '   You can request access, correction, or deletion of your data.\n\n'
                '6. Changes to This Policy:\n'
                '   We may update this policy and will notify users of significant changes.\n\n'
                '7. Contact Us:\n'
                '   For any questions, please contact privacy@rag-it.com'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAboutUs() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('About Us'),
          content: SingleChildScrollView(
            child: Text('RAG-iT: Your GitHub Companion\n\n'
                'It all started in a bustling hackathon, where a team of passionate developers found themselves drowning in a sea of GitHub repositories. As they struggled to navigate through countless lines of code, a lightbulb moment occurred: "What if we could talk to our repos?"\n\n'
                'That\'s how RAG-iT was born - a revolutionary chatbot that bridges the gap between developers and their GitHub repositories. Our mission is to simplify the complexities of collaborative coding, making it as easy as having a conversation with a knowledgeable friend.\n\n'
                'RAG-iT empowers developers to:\n'
                '- Quickly understand unfamiliar codebases\n'
                '- Effortlessly navigate through complex projects\n'
                '- Get instant answers to code-related questions\n'
                '- Boost productivity and reduce development time\n\n'
                'Join us in revolutionizing the way developers interact with their code. With RAG-iT, your GitHub repositories are just a chat away!'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.loginBackground,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                  color: Colors.white,
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
                        textAlign: TextAlign.center,
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
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              color: AppColors.loginBackground.withOpacity(0.8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _showPrivacyPolicy,
                    child: Text(
                      'Privacy Policy',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: _showAboutUs,
                    child: Text(
                      'About Us',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
