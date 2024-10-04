import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:githubrag/components/screens/chatscreen.dart';

const users = {
  'lasheralberto@gmail.com': '12345',
  'hunter@gmail.com': 'hunter',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<String?> _authUser(LoginData data) async {
    try {
      // Intentar iniciar sesión con Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email:  data.name,
        password: data.password,
      );
      // Si el inicio de sesión es exitoso, devolver null (ningún error)
      return null;
    } on FirebaseAuthException catch (e) {
      // Manejar los diferentes tipos de errores
      if (e.code == 'user-not-found') {
        return 'User not exists';
      } else if (e.code == 'wrong-password') {
        return 'Password does not match';
      } else {
        return 'An error occurred: ${e.message}';
      }
    }
  }

  Future<String?> _signupUser(SignupData data) async {
    try {
      // Intentar registrar un nuevo usuario con Firebase Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name.toString(),
        password: data.password.toString(),
      );
      // Si el registro es exitoso, devolver null (sin error)
      return null;
    } on FirebaseAuthException catch (e) {
      // Manejar los diferentes tipos de errores durante el registro
      if (e.code == 'email-already-in-use') {
        return 'The email is already registered';
      } else if (e.code == 'weak-password') {
        return 'The password is too weak';
      } else {
        return 'An error occurred: ${e.message}';
      }
    }
  }

  Future<String?> _recoverPassword(String email) async {
    try {
      // Enviar el correo electrónico de restablecimiento de contraseña a través de Firebase
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Si es exitoso, devolver null (sin error)
      return null;
    } on FirebaseAuthException catch (e) {
      // Manejar los errores comunes
      if (e.code == 'user-not-found') {
        return 'User not exists';
      } else {
        return 'An error occurred: ${e.message}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      // loginProviders: [LoginProvider(icon: Icons.login, callback: () {GoogleLogin})],

      ///logo: const AssetImage('assets/images/ecorp-lightblue.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        ));
      },
      onRecoverPassword: _recoverPassword,
    );
  }
}
