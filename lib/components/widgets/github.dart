import 'dart:convert';

import 'package:githubrag/components/screens/login.dart';
import 'package:githubrag/constants/keys.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GitHubLoginButton extends StatefulWidget {
  Function(User?) onUserData;
  GitHubLoginButton({super.key, required this.onUserData});
  @override
  _GitHubLoginButtonState createState() => _GitHubLoginButtonState();
}

class _GitHubLoginButtonState extends State<GitHubLoginButton> {
  User? _user;

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  // Verifica si el usuario ya está logueado
  void _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _user = user;
        widget.onUserData(_user!);
      });
    }
  }

  // Método para loguear con GitHub usando el popup
  Future<User?> _loginWithGithubPopUp() async {
    try {
      var _gitprovider = GithubAuthProvider();

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(_gitprovider);
      setState(() {
        _user = userCredential.user;
        widget.onUserData(_user!);
      });
      return _user;
    } catch (e) {
      if (e is FirebaseAuthException) {
        String errorCode = e.code; // Obtiene el código de error
        if (errorCode != "popup-closed-by-user") {
          _showErrorDialog("Login Error", e.message.toString());
        }
      }

      return null;
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK", style: TextStyle(color: Colors.black)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  // Método para desloguear
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      _user = null;
      widget.onUserData(_user);
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LoginScreen();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Si el usuario está logueado, muestra el nombre
            if (_user != null)
              Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const FaIcon(FontAwesomeIcons.github,
                        color: Colors.white),
                    label: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black, // Estilo GitHub
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 20),
                    ),
                  ),
                ],
              )
            else
              Column(children: [
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton.icon(
                  onPressed: _loginWithGithubPopUp,
                  icon: const FaIcon(FontAwesomeIcons.github,
                      color: Colors.white),
                  label: const Text("Login with GitHub",
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Estilo del botón GitHub
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Bordes redondeados
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                  ),
                ),
              ]),
          ],
        ),
      ),
    );
  }
}
