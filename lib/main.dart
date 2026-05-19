import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';

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

  // 📥 IMPORT FILE
  Future<void> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: Platform.isIOS,
    );

    if (result == null) return;

    String content = "";

    // 🍎 iOS
    if (Platform.isIOS) {
      Uint8List? bytes = result.files.single.bytes;

      if (bytes != null) {
        content = String.fromCharCodes(bytes);
      }
    }

    // 🤖 Android
    else {
      String? path = result.files.single.path;

      if (path == null) return;

      File file = File(path);

      content = await file.readAsString();
    }

    setState(() {
      controller.text = content;
      editing = true;
    });
  }

  // 📤 EXPORT FILE
  Future<void> exportFile() async {
    TextEditingController nameController =
        TextEditingController(text: "note");

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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );

    if (cancelled) return;

    String fileName = nameController.text.trim();

    if (fileName.isEmpty) return;

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(controller.text.codeUnits),
      ext: "txt",
      mimeType: MimeType.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("File saved"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color backgroundColor =
        isDark ? const Color(0xFF1E1E1E) : Colors.white;

    Color textColor =
        isDark ? Colors.white : Colors.black;

    Color buttonColor =
        isDark ? Colors.white : Colors.black;

    Color buttonTextColor =
        isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔝 TOP BAR
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
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

            // 📄 EDITOR AREA
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
