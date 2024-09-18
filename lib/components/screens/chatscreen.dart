
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:githubrag/models/colors.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _openaicontroller = TextEditingController();
  final TextEditingController _gitcontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String currentUser =
      "lasheralberto@gmail.com"; // Simulación de usuario actual
  String selectedRepo = "";
  List<String> userRepos = [];

  @override
  void initState() {
    super.initState();
    _loadUserRepos();
  }

  void _loadUserRepos() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('conversations')
        .where('user', isEqualTo: currentUser)
        .get();

    setState(() {
      userRepos =
          querySnapshot.docs.map((doc) => doc['repo'] as String).toList();
      if (userRepos.isNotEmpty) {
        selectedRepo = userRepos[0];
      }
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
            selectedRepo,
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
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('conversations')
          .doc('$currentUser-$selectedRepo')
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        List<DocumentSnapshot> messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> data =
                messages[index].data() as Map<String, dynamic>;
            return _buildMessageBubble(data['text']);
          },
        );
      },
    );
  }

  Widget _buildMessageBubble(String message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(message, style: const TextStyle(color: AppColors.textPrimary)),
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
            child: const Icon(Icons.send, color: AppColors.cardBackground),
            backgroundColor: AppColors.accent,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && selectedRepo.isNotEmpty) {
      await _firestore
          .collection('conversations')
          .doc('$currentUser-$selectedRepo')
          .collection('messages')
          .add({
        'text': _messageController.text,
        'role': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
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
              child: const Text('Cerrar', style: TextStyle(color: AppColors.accent)),
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