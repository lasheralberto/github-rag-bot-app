import 'dart:async';
import 'dart:convert';
import 'dart:math';
//import 'package:appwrite/appwrite.dart' as appw;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:githubrag/components/widgets/animatedlogo.dart';
import 'package:githubrag/components/widgets/codeviewer.dart';
import 'package:githubrag/components/widgets/generalPopUp.dart';
import 'package:githubrag/components/widgets/loadinggif.dart';
import 'package:githubrag/components/widgets/loadingindicator.dart';
import 'package:githubrag/components/widgets/notrelevantfiles.dart';
import 'package:githubrag/components/widgets/openaibut.dart';
import 'package:githubrag/components/widgets/relevantfiles.dart';
import 'package:githubrag/constants/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:githubrag/models/colors.dart';
import 'package:githubrag/models/gitbackend.dart';
import 'package:githubrag/components/widgets/github.dart';
import 'package:githubrag/models/styles.dart';
import 'package:githubrag/models/text.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _openaicontroller = TextEditingController();
  final TextEditingController _gitcontroller = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<List<Map<String, dynamic>>> _chatStreamController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  var focusNode = FocusNode();
  String? currentUser;
  String? selectedRepo;
  List<Map<String, dynamic>> userRepos = [];
  bool? reposLoaded = false;
  int? indexSelected;
  GitHubRagApi? apiGitInstance;
  String? instanceKeyGit;
  bool? repoLoading;
  User? userData;
  bool? isGitLogged;
  bool? isMessageRepliedByBot;
  List<dynamic>? notRelevantFiles;
  List<dynamic>? RelevantFiles;
  AnimationController? _controller;
  String? pineconeKey;

  @override
  void initState() {
    super.initState();

    RelevantFiles = [];
    notRelevantFiles = [];
    isGitLogged = false;
    isMessageRepliedByBot = true;

    ServicesBinding.instance.keyboard.addHandler(_onKey);
    indexSelected = 0;
    repoLoading = false;
    _gitcontroller.text = dotenv.env['gittoken'].toString();
    _openaicontroller.text = "";
    pineconeKey = dotenv.env['pineconekey'].toString();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await GetUserDataAndRepos(currentUser);
      }
    });
  }

  Future<void> GetUserDataAndRepos(userdata) async {
    //String? username = await _getUserData(userdata);
    reposLoaded = await _fetchGitHubRepos();

    //var repos = await _fetchRepos(username);
    final api = GitHubRagApi(UrlConstants.gcloudService);
    setState(() {
      reposLoaded = true;
      apiGitInstance = api;
    });
    await _addMessageToFirebaseAndStream(selectedRepo);
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent &&
        selectedRepo != null &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      _sendMessage();
    }

    return false;
  }

  Future<void> _addMessageToFirebaseAndStream(repoSelected) async {
    var splittedRepo = repoSelected?.split('/');
    if (splittedRepo != null && splittedRepo.length > 1) {
      var username = splittedRepo[0];
      var repo = splittedRepo[1];

      _firestore
          .collection('conversations')
          .doc('$username-$repo')
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
        List<Map<String, dynamic>> messages =
            snapshot.docs.map((doc) => doc.data()).toList();
        _chatStreamController.add(messages);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Card(
          elevation: 20.0,
          color: AppColors.repoListCardBehind,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment
                  .start, // Alinear el contenido verticalmente en la parte superior
              children: [
                // Panel de la lista de repositorios alineado a la izquierda
                SizedBox(
                  width: MediaQuery.of(context).size.width /
                      4, // Ocupa 1/4 del ancho de la pantalla
                  child: _buildRepoList(),
                ),
                const SizedBox(
                    width:
                        16), // Espacio entre la lista de repos y el contenido principal

                // El área central (logo animado o área de chat)
                Expanded(
                  flex: 3, // El contenido central ocupará más espacio
                  child: selectedRepo == null
                      ? Center(
                          // Centra el logo en la pantalla
                          child: AnimatedLogoText(
                            indexing: false,
                          ),
                        )
                      : repoLoading == true
                          ? Center(
                              // También centrado mientras carga el repositorio
                              child: AnimatedLogoText(
                                indexing: true,
                              ),
                            )
                          : FirebaseAuth.instance.currentUser == null
                              ? const SizedBox
                                  .shrink() // Ocultar si no hay usuario
                              : _buildChatArea(
                                  indexSelected), // Muestra el área de chat si el repositorio está seleccionado
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatArea(index) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(WidgetStyle.borderRadius),
          boxShadow: [
            // BoxShadow(
            //   color: Colors.black.withOpacity(0.1),
            //   offset: const Offset(-3, -3),
            //   blurRadius: 10,
            // ),
            // BoxShadow(
            //   color: Colors.white.withOpacity(0.7),
            //   offset: const Offset(3, 3),
            //   blurRadius: 10,
            // ),
          ],
        ),
        child: Column(
          children: [
            if (RelevantFiles == null || notRelevantFiles == null)
              _buildChatHeader(context, [], [], index, selectedRepo)
            else
              _buildChatHeader(context, notRelevantFiles!, RelevantFiles!,
                  index, selectedRepo),
            Expanded(child: _buildMessageList()),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildRepoList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.repoListCardBehind,
        borderRadius: BorderRadius.circular(WidgetStyle.borderRadius),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OpenAiButton(
                apikey: _openaicontroller.text,
                onApiKeyEntered: (p0) {
                  setState(() {
                    _openaicontroller.text = p0;
                  });
                },
              ),
              const SizedBox(
                width: 20,
              ),
              GitHubLoginButton(
                onUserData: (user) {
                  setState(() {
                    userData = user;
                    if (userData != null) {
                      GetUserDataAndRepos(userData);
                      isGitLogged = true;
                      _controller?.forward(); // Iniciar animación al loguearse
                    } else {
                      //NO hay datos o ha hecho logout
                      isGitLogged = false;
                      userRepos = [];
                    }
                  });
                },
              ),
            ],
          ),
          isGitLogged == true
              ? Expanded(
                  child: Card(
                    color: AppColors.repoList,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(WidgetStyle.borderRadius))),
                    elevation: 20.0,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: userRepos.length,
                      itemBuilder: (context, index) {
                        var isSelected = indexSelected == index;
                        return ListTile(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(WidgetStyle.borderRadius))),
                          tileColor: AppColors.repoList,
                          subtitle: Text(userRepos[index]['visibility'],
                              style: TextStyle(
                                  color:
                                      userRepos[index]['visibility'] == 'public'
                                          ? Colors.blue
                                          : Colors.red)),
                          // leading: CircleAvatar(
                          //     child:
                          //         Text(userRepos[index].substring(0, 1).toUpperCase())),
                          title: Text(
                            userRepos[index]['name'],
                            style: TextStyle(
                                fontSize: TextSize.textRepoSize,
                                color: (isSelected && indexSelected != 0)
                                    ? AppColors.textRepoListSelected
                                    : const Color.fromARGB(255, 166, 169, 182)),
                          ),
                          onTap: () async {
                            await initializerepoAndSetState(index);
                            await _addMessageToFirebaseAndStream(selectedRepo);
                          },
                        );
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return Container(
      width: MediaQuery.of(context).size.width / 5,
      height: MediaQuery.of(context).size.height / 5,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(WidgetStyle.borderRadius),
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

  Widget _buildChatHeader(BuildContext context, List<dynamic> notRelevantFiles,
      List<dynamic> RelevantFiles, index, reposelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              await initializerepoAndSetState(index);
              await _addMessageToFirebaseAndStream(reposelected);
            },
            icon: const Icon(Icons.refresh_sharp),
            tooltip: 'Re-index repository',
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  selectedRepo.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              RelevantFiles.isNotEmpty
                  ? IconButton(
                      tooltip: 'Show files indexed',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return RelevantFilesPopup(
                              RelevantFiles:
                                  RelevantFiles, // Pasar la lista de archivos no relevantes
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.green,
                      ))
                  : const SizedBox.shrink(),
              // Botón para mostrar el popup
              notRelevantFiles.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.red),
                      tooltip: 'Show files not indexed',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return NotRelevantFilesPopup(
                              notRelevantFiles:
                                  notRelevantFiles, // Pasar la lista de archivos no relevantes
                            );
                          },
                        );
                      },
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(WidgetStyle.borderRadius),
          bottomRight: Radius.circular(WidgetStyle.borderRadius),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Ask me something...',
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          KeyboardListener(
            focusNode: focusNode,
            onKeyEvent: (event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.enter) {
                _sendMessage();
                // Do something
              }
            },
            child: isMessageRepliedByBot == true
                ? ElevatedButton(
                    onPressed: _sendMessage,
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all<Color>(AppColors.accent),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(WidgetStyle.borderRadius),
                        ),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.send,
                          color: AppColors.textBubbleUserColor),
                    ),
                  )
                : const CircularProgressIndicator(
                    strokeWidth: 8.0,
                    valueColor: AlwaysStoppedAnimation(Colors.amber),
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
            return const Center(child: Text('No conversations'));
          } else if (snapshot.hasData) {
            List<Map<String, dynamic>> messages = snapshot.data!;

            return ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(messages[index]);
              },
            );
          } else {
            return const Center(child: Text('Error'));
          }
        });
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    bool isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.bottomRight : Alignment.centerLeft,
      child: CodeFormattedView(message['text'], isUser),
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty &&
        selectedRepo.toString().isNotEmpty) {
      String userMessage = _messageController.text;
      _messageController.clear();

      setState(() {
        isMessageRepliedByBot = false;
      });

      var splittedRepo = selectedRepo?.split('/');
      var username = splittedRepo![0];
      var repo = splittedRepo[1];

      // Add user message to Firestore
      await _firestore
          .collection('conversations')
          .doc('$username-$repo')
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
            reponame: selectedRepo.toString(),
            question: userMessage,
            openaiKey: _openaicontroller.text,
            pineconeKey: pineconeKey.toString());

        //var botResponse = await _sendMessageToLangChain(userMessage);

        // Add bot response to Firestore
        await _firestore
            .collection('conversations')
            .doc('$username-$repo')
            .collection('messages')
            .add({
          'text': answer,
          'role': 'bot',
          'timestamp': FieldValue.serverTimestamp(),
        });

        setState(() {
          isMessageRepliedByBot = true;
        });
      } catch (e) {
        print('Error getting bot response: $e');
        setState(() {
          isMessageRepliedByBot = true;
        });
        // Optionally, add an error message to the chat
        await _firestore
            .collection('conversations')
            .doc('$username-$repo')
            .collection('messages')
            .add({
          'text': 'Error: Unable to get response from the bot.',
          'role': 'bot',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> initializerepoAndSetState(index) async {
    setState(() {
      selectedRepo = userRepos[index]['name'];
      repoLoading = true;
      indexSelected = index;
      // Inicializar el repositorio
    });
    Map<String, dynamic>? _instanceKeyGit =
        await apiGitInstance?.initializeRepo(
            githubToken: _gitcontroller.text,
            openaiKey: _openaicontroller.text,
            repoName: selectedRepo.toString(),
            pineconeKey: pineconeKey.toString());

    setState(() {
      if (_instanceKeyGit != null && _instanceKeyGit.containsKey('repo_name')) {
        var repoName = _instanceKeyGit['repo_name'];
        var loggers = _instanceKeyGit['messages'];
        if (repoName.isEmpty) {
          repoLoading = false;
          loggers.toString().isNotEmpty
              ? showDialog(
                  context: context,
                  builder: (context) {
                    return Generalpopup(
                        text: _instanceKeyGit['messages'], title: 'Error');
                  })
              : const SizedBox.shrink();
        } else {
          instanceKeyGit = _instanceKeyGit['repo_name'];

          RelevantFiles = _instanceKeyGit['relevant'];
          notRelevantFiles = _instanceKeyGit['not_relevant'];
          repoLoading = false;
        }
      }
    });
  }

  Future<bool> _fetchGitHubRepos() async {
    try {
      // Autenticar con GitHub usando el proveedor de autenticación de Firebase
      final githubProvider = GithubAuthProvider();
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithPopup(githubProvider);

      // Obtener el GitHub access token del objeto OAuthCredential
      final OAuthCredential? credential =
          userCredential.credential as OAuthCredential?;
      String? accessToken = credential?.accessToken;

      if (accessToken == null) {
        return false;
      }

      // Hacer la solicitud a la API de GitHub con el access token de GitHub
      final response = await http.get(
        Uri.parse('https://api.github.com/user/repos'),
        headers: {
          'Authorization': 'token $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          userRepos = jsonResponse
              .map((repo) =>
                  {'visibility': repo['visibility'], 'name': repo['full_name']})
              .toList();
        });

        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Error en la autenticación con GitHub o la solicitud: $e');
      return false;
    }
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    _messageController.dispose();
    super.dispose();
  }
}
