import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:m3u_nullsafe/m3u_nullsafe.dart'; // M3U parser
import 'package:http/http.dart' as http; // HTTP client for URL fetching
import 'dart:convert';

void main() {
  runApp(AubsTVApp());
}

class AubsTVApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AubsTV',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AubsTVHomePage(),
    );
  }
}

class AubsTVHomePage extends StatefulWidget {
  @override
  _AubsTVHomePageState createState() => _AubsTVHomePageState();
}

class _AubsTVHomePageState extends State<AubsTVHomePage> {
  String? playlistPath;
  List<String> channels = [];
  TextEditingController urlController = TextEditingController();  // Controller for URL input

  @override
  void dispose() {
    // Clean up controller when widget is disposed
    urlController.dispose();
    super.dispose();
  }

  Future<void> loadM3UFromUrl(String url) async {
    var client = http.Client();
    try {
      final response = await client.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final playlistContent = response.body;
        final playlist = await M3uParser.parse(playlistContent);
        setState(() {
          channels = playlist.map((entry) => entry.title ?? 'Unknown Channel').toList();
        });
      } else {
        print('Failed to load M3U from URL with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching M3U from URL: $e');
    } finally {
      client.close();
    }
  }

  Future<void> loadM3UFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['m3u'],
    );

    if (result != null) {
      File m3uFile = File(result.files.single.path!);
      final playlistContent = await m3uFile.readAsString();

      // Parse M3U from file
      final playlist = await M3uParser.parse(playlistContent);
      setState(() {
        playlistPath = result.files.single.path;
        channels = playlist.map((entry) => entry.title ?? 'Unknown Channel').toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AubsTV'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // URL Input Field
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: urlController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Enter M3U URL',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (urlController.text.isNotEmpty) {
                  await loadM3UFromUrl(urlController.text);  // Load M3U from URL
                }
              },
              child: Text('Load from URL'),
            ),
            SizedBox(height: 20),
            // File Picker Button
            ElevatedButton(
              onPressed: () async {
                await loadM3UFromFile();  // Load M3U from File
              },
              child: Text('Load M3U Playlist'),
            ),
            SizedBox(height: 20),
            Text(playlistPath ?? 'No playlist loaded'),
            SizedBox(height: 20),
            // Display the list of channels
            Expanded(
              child: ListView.builder(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(channels[index]),
                    onTap: () {
                      // Placeholder for playing the channel
                      print('Selected channel: ${channels[index]}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}