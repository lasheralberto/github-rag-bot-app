import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NotRelevantFilesPopup extends StatelessWidget {
  final List<dynamic> notRelevantFiles;

  const NotRelevantFilesPopup({Key? key, required this.notRelevantFiles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Files not indexed'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: notRelevantFiles.length,
          itemBuilder: (BuildContext context, int index) {
            final file = notRelevantFiles[index];
            return ListTile(
              title: Text(file['name']),
              subtitle: Text('Size: ${file['size']} bytes'),
              trailing: IconButton(
                icon: const Icon(Icons.open_in_browser),
                onPressed: () {
                  _launchURL(file['url']);
                },
              ),
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open: $url';
    }
  }
}
