import 'package:flutter/material.dart';
import 'package:githubrag/models/styles.dart';

class OpenAiButton extends StatelessWidget {
  final Function(String) onApiKeyEntered;
  final String apikey;
  const OpenAiButton(
      {Key? key, required this.onApiKeyEntered, required this.apikey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      label: const Text(
        'API Key',
        style: TextStyle(color: Colors.black),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
              WidgetStyle.borderRadius), // Cambia a tu preferencia
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      ),
      onPressed: () {
        _showApiKeyDialog(context, this.apikey);
      },
      icon: Image.asset('media/images/openai.png'),
    );
  }

  void _showApiKeyDialog(BuildContext context, String apikey) {
    final TextEditingController apiKeyController =
        TextEditingController(text: apikey);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter API Key'),
          content: TextField(
            controller: apiKeyController,
            decoration: const InputDecoration(
              hintText: 'Enter your OpenAI API key',
            ),
            obscureText: false, // Si deseas ocultar la API key
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final apiKey = apiKeyController.text;
                // Aquí puedes manejar la API Key como necesites, por ejemplo, guardarla en un storage seguro
                this.onApiKeyEntered(apiKey);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
