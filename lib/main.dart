import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const TxtEditorApp());
}

class TxtEditorApp extends StatelessWidget {
  const TxtEditorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
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

  @override
  void initState() {
    super.initState();
    setupStorage();
  }

  Future<void> setupStorage() async {
    await Permission.manageExternalStorage.request();

    if (await Permission.manageExternalStorage.isGranted) {
      final dir = Directory("/storage/emulated/0/TXTEditor");

      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    }
  }

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
  try {
    TextEditingController nameController =
        TextEditingController(text: "note.txt");

    bool cancelled = false;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (cancelled) return;

    String fileName = nameController.text.trim();

    if (fileName.isEmpty) return;

    if (!fileName.endsWith(".txt")) {
      fileName += ".txt";
    }

    final mediaDir = Directory(
      "/storage/emulated/0/Android/media/com.txteditor.app/TXTEditor",
    );

    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final file = File(
      "${mediaDir.path}/$fileName",
    );

    await file.writeAsString(controller.text);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text(
          "Saved to:\n${file.path}",
        ),
      ),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "ERROR: $e",
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color buttonBg = isDark ? Colors.white : Colors.black;
    Color buttonText = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: exportFile,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonBg,
                    ),
                    child: Text(
                      "Export file",
                      style: TextStyle(color: buttonText),
                    ),
                  ),
                  TextButton(
                    onPressed: importFile,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonBg,
                    ),
                    child: Text(
                      "Import file",
                      style: TextStyle(color: buttonText),
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
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        )
                      : Center(
                          child: Text(
                            "Open a file or create a file.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
