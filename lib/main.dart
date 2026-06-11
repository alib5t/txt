import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const TxtEditorApp());
}

class TxtEditorApp extends StatelessWidget {
  const TxtEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const EditorScreen(),
    );
  }
}

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TextEditingController controller = TextEditingController();

  bool editing = false;

  Future<void> importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null) return;

    final path = result.files.single.path;

    if (path == null) return;

    final file = File(path);

    final content = await file.readAsString();

    setState(() {
      controller.text = content;
      editing = true;
    });
  }

Future<void> exportFile() async {
  TextEditingController nameController =
      TextEditingController(text: "note.txt");

  bool cancelled = false;

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("File name"),
        content: TextField(
          controller: nameController,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              cancelled = true;
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Save"),
          ),
        ],
      );
    },
  );

  if (cancelled) return;

  String fileName = nameController.text.trim();

  if (fileName.isEmpty) return;

  if (!fileName.endsWith(".txt")) {
    fileName += ".txt";
  }

  final baseDir = Directory("/storage/emulated/0/TXTEditor");

  if (!await baseDir.exists()) {
    await baseDir.create(recursive: true);
  }

  final file = File("${baseDir.path}/$fileName");

  await file.writeAsString(controller.text);

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        "Saved to ${file.path}",
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final dark =
        Theme.of(context).brightness == Brightness.dark;

    final background =
        dark ? const Color(0xFF1E1E1E) : Colors.white;

    final textColor =
        dark ? Colors.white : Colors.black;

    final buttonColor =
        dark ? Colors.white : Colors.black;

    final buttonTextColor =
        dark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: exportFile,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                    child: Text(
                      "Export file",
                      style: TextStyle(
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: importFile,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                    child: Text(
                      "Import file",
                      style: TextStyle(
                        color: buttonTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    editing = true;
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: editing
                      ? TextField(
                          controller: controller,
                          maxLines: null,
                          autofocus: true,
                          style: TextStyle(
                            color: textColor,
                          ),
                          decoration:
                              const InputDecoration(
                            border: InputBorder.none,
                          ),
                        )
                      : Center(
                          child: Text(
                            "Open a file or create a file.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
