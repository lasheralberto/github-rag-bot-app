import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GitHubRagApi {
  final String baseUrl;

  GitHubRagApi(this.baseUrl);

  Future<Map<String, dynamic>?> initializeRepo(
      {required String githubToken,
      required String openaiKey,
      required String repoName,
      required String pineconeKey}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/initialize-repo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'github': githubToken,
        'openai': openaiKey,
        'pinecone': pineconeKey,
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

  Future<int> indexDocument(String openaiKey, String pineconeKey,
      String fileUrl, String indexName, String fileExt) async {
    // Endpoint de la API
    int statuscodeRepeated;
    int retries = 0;

    

    try {
      // Realiza la solicitud POST
      final response = await http.post(
        Uri.parse('$baseUrl/document_index/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'openai': openaiKey,
          'pinecone': pineconeKey,
          'url': fileUrl,
          'indexname': indexName,
          'file_ext': fileExt
        })
      );

      // Maneja la respuesta de la API
      if (response.statusCode == 200) {
        return 200;
      } else {
        return 400;
      }
    } catch (e) {
      return 400;
    }
  }

  Future<String> askRepo(
      {required String reponame,
      required String question,
      required String openaiKey,
      required String pineconeKey}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ask-repo/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'repo_name': reponame,
        'openai': openaiKey,
        'pinecone': pineconeKey,
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
