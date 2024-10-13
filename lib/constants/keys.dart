import 'package:flutter/services.dart';

class KeyConstants {
  // static const openaiKey = String.fromEnvironment('OPENAI_API_KEY');
  static const openaiKey =
      "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";
  //static const gitToken = String.fromEnvironment('GITHUB_TOKEN');
  static const gitToken =
      "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";
}

class UrlConstants {
  static const gcloudService =
      "https://gitbotrag-service-842301100243.us-central1.run.app";
}

class GithubKeys {
  static const id = "Iv23liYAdEMPiIeEwDbD";
  static const callbackUrl =
      "https://github-rag-app.firebaseapp.com/__/auth/handler";
  late final String gitsecret;

  static Future<String> getGitSecret() async {
    var gitsecret = await rootBundle.loadString('assets/git_secret.pem');
    return gitsecret;
  }
}
