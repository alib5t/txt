import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

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

  // 📥 IMPORT (iOS + Android) ✅ iOS destek eklendi
  Future<void> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
      withData: Platform.isIOS, // 🔥 iOS fix
    );

    if (result == null) return;

    String content = "";

    if (Platform.isIOS) {
      if (result.files.single.bytes != null) {
        content = String.fromCharCodes(result.files.single.bytes!);
      }
    } else {
      if (result.files.single.path == null) return;
      File file = File(result.files.single.path!);
      content = await file.readAsString();
    }

    setState(() {
      controller.text = content;
      editing = true;
    });
  }

  // 📤 EXPORT (iOS + Android uyumlu)
  Future<void> exportFile() async {
    TextEditingController nameController =
        TextEditingController(text: "note.txt");

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
              onPressed: () => Navigator.pop(context),
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

    String fileName = nameController.text.trim();
    if (fileName.isEmpty) return;

    if (!fileName.endsWith(".txt")) {
      fileName += ".txt";
    }

    final text = controller.text;

    // 🤖 ANDROID
    if (Platform.isAndroid) {
      String? folder = await FilePicker.platform.getDirectoryPath();
      if (folder == null) return;

      File file = File("$folder/$fileName");
      await file.writeAsString(text);
    }

    // 🍎 iOS
    else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName");

      await file.writeAsString(text);

      // iOS Files + paylaşım
      await Share.shareXFiles([XFile(file.path)], text: "Exported file");
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File saved")),
    );
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
            // 🔝 TOP BAR
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: exportFile,
                    style: TextButton.styleFrom(backgroundColor: buttonBg),
                    child: Text("Export file",
                        style: TextStyle(color: buttonText)),
                  ),
                  TextButton(
                    onPressed: importFile,
                    style: TextButton.styleFrom(backgroundColor: buttonBg),
                    child: Text("Import file",
                        style: TextStyle(color: buttonText)),
                  ),
                ],
              ),
            ),

            // 📄 MAIN AREA
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => editing = true),
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
