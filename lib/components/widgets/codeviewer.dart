import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:githubrag/components/widgets/textfadein.dart';
import 'package:githubrag/models/colors.dart';
import 'package:githubrag/models/styles.dart';
import 'package:githubrag/models/text.dart';

class CodeFormattedView extends StatelessWidget {
  final String content;
  final bool isUserOrAgentMessage;

  const CodeFormattedView(this.content, this.isUserOrAgentMessage, {super.key});

  @override
  Widget build(BuildContext context) {
    final parts = content.split("```");
    final textPart = parts[0].trim();
    final codePart = parts.length > 1 ? parts[1].trim() : "";
    var lang = codePart.split('\n')[0];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment:
            isUserOrAgentMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUserOrAgentMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Parte de texto
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUserOrAgentMessage
                    ? AppColors.textUserBubble
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(WidgetStyle.borderRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isUserOrAgentMessage)
                    const CircleAvatar(
                      radius: 18.0,
                      backgroundColor: Colors.white,
                      foregroundImage: AssetImage('media/images/logo.png'),
                    ),
                  if (!isUserOrAgentMessage) const SizedBox(width: 8),
                  Flexible(
                    child: TextFadeIn(
                      text: textPart,
                      style: TextStyle(
                        fontSize: TextSize.textBubbleChat,
                        color: isUserOrAgentMessage
                            ? AppColors.textBubbleUserColor
                            : AppColors.textBubbleAgentColor,
                      ),
                    ),
                  ),
                  if (isUserOrAgentMessage) const SizedBox(width: 8),
                  if (isUserOrAgentMessage)
                    CircleAvatar(
                      radius: 15.0,
                      backgroundColor: Colors.blue,
                      child: Text(
                        FirebaseAuth
                                .instance.currentUser!.displayName!.isNotEmpty
                            ? FirebaseAuth.instance.currentUser!.displayName![0]
                                .toUpperCase()
                            : '',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Parte de código resaltado
            if (codePart.isNotEmpty)
              Stack(
                children: [
                  HighlightView(
                    codePart,
                    language: lang,
                    theme: githubTheme,
                    padding: const EdgeInsets.all(36),
                    textStyle: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 8,
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
              ),
          ],
        ),
      ),
    );
  }
}
