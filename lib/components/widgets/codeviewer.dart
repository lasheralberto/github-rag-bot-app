import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:githubrag/models/colors.dart';
import 'package:githubrag/models/text.dart';

class CodeFormattedView extends StatelessWidget {
  final String content;
  final bool isUserOrAgentMessage;

  const CodeFormattedView(this.content, this.isUserOrAgentMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    // Ejemplo de string: "Este es el ejemplo del codigo:\n''' python\n(Python code '''\n"
    // Dividir el contenido entre texto y código
    final parts =
        content.split("```"); // Asume que el código está entre comillas triples

    // El primer elemento es el texto, el segundo es el código
    final textPart = parts[0].trim();
    final codePart = parts.length > 1 ? parts[1].trim() : "";
    var lang = codePart.split('\n')[0];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar la parte de texto
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserOrAgentMessage == true
                    ? AppColors.textUserBubble
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  isUserOrAgentMessage == false
                      ? const CircleAvatar(
                          radius: 20.0,
                          backgroundColor: Colors.white,
                          foregroundImage: AssetImage('images/logo_chat.png'),
                        )
                      : CircleAvatar(
                          radius: 15.0,
                          backgroundColor:
                              Colors.blue, // Puedes cambiar el color de fondo
                          child: Text(
                            FirebaseAuth.instance.currentUser!.displayName!
                                    .isNotEmpty
                                ? FirebaseAuth
                                    .instance.currentUser!.displayName![0]
                                    .toUpperCase()
                                : '', // Mostrar la primera letra en mayúscula
                            style: const TextStyle(
                                color:
                                    Colors.white), // Color y estilo del texto
                          ),
                        ),
                  const SizedBox(
                    width: 15,
                  ),
                  Flexible(
                    child: SelectableText(
                      textPart,
                      style: TextStyle(
                          fontSize: TextSize.textBubbleChat,
                          color: isUserOrAgentMessage == true
                              ? AppColors.textBubbleUserColor
                              : AppColors.textBubbleAgentColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Mostrar la parte de código resaltado

            if (codePart.isNotEmpty)
              Stack(
                children: [
                  HighlightView(
                    codePart, // Mostrar el bloque de código
                    language:
                        lang, // Puedes detectar el lenguaje dinámicamente si es necesario
                    theme: githubTheme, // El tema para resaltar el código
                    padding: const EdgeInsets.all(36),
                    textStyle: const TextStyle(
                      fontFamily: 'monospace', // Fuente de código
                      fontSize: 12,
                    ),
                  ),
                  Positioned(
                    top: 12, // Ajusta la posición vertical del botón
                    right: 8, // Ajusta la posición horizontal del botón
                    child: IconButton(
                      icon: const Icon(Icons.copy),
                      iconSize: 20.0,
                      tooltip: 'Copiar al portapapeles',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: codePart))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Código copiado al portapapeles')),
                          );
                        });
                      },
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}
