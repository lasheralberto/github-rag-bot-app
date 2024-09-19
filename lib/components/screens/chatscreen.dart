import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:githubrag/models/colors.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _openaicontroller = TextEditingController();
  final TextEditingController _gitcontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<Map<String, dynamic>>> _chatStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  String? currentUser;
  String? selectedRepo;
  List<String> userRepos = [];

  @override
  void initState() {
    super.initState();
    selectedRepo = "botpress-socketio";
    _gitcontroller.text =
        "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";

    currentUser = "lasheralberto";
    _fetchRepos();
    _initializeChatStream();
  }

  void _initializeChatStream() {
    _firestore
        .collection('conversations')
        .doc('$currentUser-$selectedRepo')
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> messages = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      _chatStreamController.add(messages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: _buildRepoList(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: _buildChatArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRepoList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            onPressed: () => _showTokensDialog(context),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Repositorios',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userRepos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(userRepos[index],
                      style: const TextStyle(color: AppColors.textSecondary)),
                  selected: userRepos[index] == selectedRepo,
                  selectedTileColor: AppColors.primary.withOpacity(0.1),
                  onTap: () {
                    setState(() {
                      selectedRepo = userRepos[index];
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChatHeader(),
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.cardBackground,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            mini: true,
            backgroundColor: AppColors.accent,
            onPressed: _sendMessage,
            child: const Icon(Icons.send, color: AppColors.cardBackground),
          ),
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedRepo.toString(),
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _chatStreamController.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Map<String, dynamic>> messages = snapshot.data!;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return _buildMessageBubble(messages[index]);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          message['text'],
          style: TextStyle(
              color: isUser ? AppColors.textPrimary : AppColors.accent),
        ),
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty &&
        selectedRepo.toString().isNotEmpty) {
      String userMessage = _messageController.text;
      _messageController.clear();

      // Add user message to Firestore
      await _firestore
          .collection('conversations')
          .doc('$currentUser-$selectedRepo')
          .collection('messages')
          .add({
        'text': userMessage,
        'role': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Get bot response
      try {
        var botResponse = await _sendMessageToLangChain(userMessage);

        // Add bot response to Firestore
        await _firestore
            .collection('conversations')
            .doc('$currentUser-$selectedRepo')
            .collection('messages')
            .add({
          'text': botResponse['response'],
          'role': 'bot',
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Error getting bot response: $e');
        // Optionally, add an error message to the chat
        await _firestore
            .collection('conversations')
            .doc('$currentUser-$selectedRepo')
            .collection('messages')
            .add({
          'text': 'Error: Unable to get response from the bot.',
          'role': 'bot',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> _fetchRepos() async {
    var url =
        'https://gitbotrag-842301100243.europe-west2.run.app/get-repos-user/';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({
        {"github": _gitcontroller.text, "username": currentUser}
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        userRepos = jsonResponse.map((repo) => repo['name'] as String).toList();
      });
    } else {
      // Manejar el error en caso de que falle la solicitud
      print('Error al obtener los repositorios: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _sendMessageToLangChain(String message) async {
    var url = Uri.parse(
        'https://gitbotrag-842301100243.europe-west2.run.app/ask-repo/');

    try {
      var response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "github": _gitcontroller.text,
          "openai": _openaicontroller.text,
          "username": currentUser,
          "repo_name": selectedRepo,
          "question": message
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Server responded with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      if (e is http.ClientException) {
        print('ClientException details: ${e.message}');
      }
      rethrow;
    }
  }

  Widget _buildTokenField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent),
        ),
      ),
    );
  }

  void _showTokensDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Configuración de Tokens',
              style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              _buildTokenField(_openaicontroller, 'OpenAI Key'),
              const SizedBox(height: 8),
              _buildTokenField(_gitcontroller, 'Github token'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar',
                  style: TextStyle(color: AppColors.accent)),
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
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
