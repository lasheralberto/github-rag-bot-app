import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubRagApi {
  final String baseUrl;

  GitHubRagApi(this.baseUrl);

  Future<String> initializeRepo({
    required String githubToken,
    required String openaiKey,
    required String username,
    required String repoName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/initialize-repo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'github': githubToken,
        'openai': openaiKey,
        'username': username,
        'repo_name': repoName,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['instance_key'];
    } else {
      throw Exception('Failed to initialize repository: ${response.body}');
    }
  }

  Future<String> askRepo({
    required String instanceKey,
    required String question,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask-repo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'instance_key': instanceKey,
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