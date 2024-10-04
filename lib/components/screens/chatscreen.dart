import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:githubrag/constants/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:githubrag/models/colors.dart';
import 'package:githubrag/models/gitbackend.dart';
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
  var focusNode = FocusNode();

  String? currentUser;
  String? selectedRepo;
  List<String> userRepos = [];
  bool? reposLoaded = false;
  dynamic userData;
  int? indexSelected;
  GitHubRagApi? apiGitInstance;
  String? instanceKeyGit;

  @override
  void initState() {
    super.initState();
    ServicesBinding.instance.keyboard.addHandler(_onKey);
    indexSelected = 0;
    _gitcontroller.text = KeyConstants.gitToken;
    _openaicontroller.text = KeyConstants.openaiKey;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userData = await _getUserData();
      currentUser = userData.toString();
      var repos = await _fetchRepos(currentUser);
      final api = GitHubRagApi(UrlConstants.gcloudService);
      setState(() {
        reposLoaded = repos;
        apiGitInstance = api;
      });
      await _initializeChatStream();
    });
  }

   bool _onKey(KeyEvent event) {

    if (event is KeyDownEvent && selectedRepo != null && event.logicalKey == LogicalKeyboardKey.enter ) {
     
      _sendMessage();
    } 

    return false;
  }

  Future<void> _initializeChatStream() async {
    _firestore
        .collection('conversations')
        .doc('$currentUser-$selectedRepo')
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> messages = snapshot.docs
          .map((doc) => doc.data())
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
              selectedRepo == null ? Expanded(child: Positioned.fill(
            child: Opacity(
              opacity: 0.8, // Ajusta la opacidad si quieres que la imagen sea más sutil
              child: Image.asset(
                'images/select_repo.png', // Ruta de la imagen en assets
                fit: BoxFit.fitHeight, // Hace que la imagen cubra todo el espacio
              ),
            ),
          )): Expanded(
                flex: 3,
                child: _buildChatArea(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(-3, -3),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(3, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildChatHeader(),
          Expanded(child: _buildMessageList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildRepoList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(-3, -3),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(3, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          IconButton(
            onPressed: () => _showTokensDialog(context),
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Repositorios',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: reposLoaded == false
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: userRepos.length,
                    itemBuilder: (context, index) {
                      var isSelected = indexSelected == index;
                      return ListTile(
                        title: Text(
                          userRepos[index],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        onTap: () async {
                          setState(() {
                            selectedRepo = userRepos[index];
                            indexSelected = index;
                                // Inicializar el repositorio

                          });

                         String? _instanceKeyGit = await apiGitInstance?.initializeRepo(
                            githubToken: _gitcontroller.text,
                            openaiKey: _openaicontroller.text,
                            username: currentUser.toString(),
                            repoName: selectedRepo.toString(),
                          );

                          setState(() {
                            instanceKeyGit = _instanceKeyGit;
                          });

                          await _initializeChatStream();
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showTokensDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
             
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Configuración de Tokens',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(_openaicontroller, 'OpenAI Key'),
                const SizedBox(height: 16),
                _buildTextField(_gitcontroller, 'Github token'),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: AppColors.cardBackground,
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(color: AppColors.background),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Container(
      width: MediaQuery.of(context).size.width / 5,
       height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
       
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
       
      ),
      child: Text(
        selectedRepo.toString(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(-3, -3),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(3, 3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Escribe un mensaje...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: (event) {

               if ( event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter ) {
                _sendMessage();
            // Do something
          }
              
            },
            
            child: ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: AppColors.accent,
              ),
              child: const Icon(Icons.send, color: AppColors.background),
            ),
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
          color: isUser ? AppColors.accent : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(15),
          
        ),
        child: Text(
          message['text'],
          style: TextStyle(
            color: isUser ? AppColors.textPrimary : AppColors.textSecondary,
          ),
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

        // Hacer una pregunta
    final answer = await apiGitInstance?.askRepo(
      instanceKey: instanceKeyGit.toString(),
      question: 'What is the main purpose of this repository?',
    );
        
        //var botResponse = await _sendMessageToLangChain(userMessage);

        // Add bot response to Firestore
        await _firestore
            .collection('conversations')
            .doc('$currentUser-$selectedRepo')
            .collection('messages')
            .add({
          'text': answer,
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

  Future<dynamic> _getUserData() async {
    // Datos para enviar en el cuerpo de la solicitud
    Map<String, dynamic> bodyData = {"github": _gitcontroller.text};
    var jsonBody = json.encode(bodyData);

    // Encabezados de la solicitud
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    var url =
        '${UrlConstants.gcloudService}/get-user-data-github/';

    final response =
        await http.post(Uri.parse(url), headers: headers, body: jsonBody);

    if (response.statusCode == 200) {
      // Si la respuesta es un objeto JSON (Map)
      final Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Acceder directamente a las claves del objeto
      var login =
          jsonResponse['login']; // Por ejemplo, obteniendo el nombre de usuario
      return login;
    } else {
      // Manejar el error en caso de que falle la solicitud

      print('Error al obtener los repositorios: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> _fetchRepos(user) async {
    // Datos para enviar en el cuerpo de la solicitud
    Map<String, dynamic> bodyData = {
      "github": _gitcontroller.text,
      "openai": KeyConstants.openaiKey,
      "username": user,
    };
    var jsonBody = json.encode(bodyData);

    // Encabezados de la solicitud
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };

    var url =
        '${UrlConstants.gcloudService}/get-repos-user/';

    final response =
        await http.post(Uri.parse(url), headers: headers, body: jsonBody);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        userRepos = jsonResponse.map((repo) => repo['name'] as String).toList();
      });

      return true;
    } else {
      // Manejar el error en caso de que falle la solicitud

      print('Error al obtener los repositorios: ${response.statusCode}');
      return false;
    }
  }

  Future<String> _sendMessageToLangChain(String message) async {
    // URL del servidor
    var url = Uri.parse(
        '${UrlConstants.gcloudService}/ask-repo/');

    // Token de autenticación (debe coincidir con el valor de `VALID_API_KEY` en el servidor)
    String apiKey = '123';

    // Encabezados de la solicitud
    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization":
          "Bearer $apiKey" // Agrega el token al encabezado Authorization
    };

    // Datos para enviar en el cuerpo de la solicitud
    Map<String, dynamic> bodyData = {
      "github": _gitcontroller.text,
      "openai": _openaicontroller.text,
      "username": currentUser,
      "repo_name": selectedRepo,
      "question": message
    };

    // Codifica el cuerpo como JSON
    var jsonBody = json.encode(bodyData);

    try {
      // Envía la solicitud POST
      var response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
      );

      // Maneja la respuesta
      if (response.statusCode == 200) {
        return response.body.toString();
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

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    _messageController.dispose();
    super.dispose();
  }
}
