import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubRagApi {
  final String baseUrl;

  GitHubRagApi(this.baseUrl);

  Future<Map<String, dynamic>?> initializeRepo({
    required String githubToken,
    required String openaiKey,
    required String repoName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/initialize-repo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'github': githubToken,
        'openai': openaiKey,
        'repo_name': repoName,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to initialize repository: ${response.body}');
    }
  }

  Future<String> askRepo({
    required String reponame,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask-repo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'repo_name': reponame,
        'question': question,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['answer'];
    } else {
      throw Exception('Failed to get answer: ${response.body}');
    }
  }
}
