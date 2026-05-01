import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const TxtApp());
}

class TxtApp extends StatelessWidget {
  const TxtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const EditorPage(),
    );
  }
}

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final TextEditingController controller = TextEditingController();
  bool editing = false;

  // 📥 IMPORT
  Future<void> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.single.path == null) return;

    File file = File(result.files.single.path!);
    String text = await file.readAsString();

    setState(() {
      controller.text = text;
      editing = true;
    });
  }

  // 📤 EXPORT (ANDROID - klasör seç + kaydet)
  Future<void> exportFile() async {
    String? folder = await FilePicker.platform.getDirectoryPath();
    if (folder == null) return;

    TextEditingController nameCtrl =
        TextEditingController(text: "note.txt");

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("File name"),
          content: TextField(
            controller: nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "example.txt",
            ),
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

    String fileName = nameCtrl.text.trim();
    if (fileName.isEmpty) return;

    if (!fileName.endsWith(".txt")) {
      fileName += ".txt";
    }

    File file = File("$folder/$fileName");
    await file.writeAsString(controller.text);

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
                    child: Text(
                      "Export file",
                      style: TextStyle(color: buttonText),
                    ),
                  ),
                  TextButton(
                    onPressed: importFile,
                    style: TextButton.styleFrom(backgroundColor: buttonBg),
                    child: Text(
                      "Import file",
                      style: TextStyle(color: buttonText),
                    ),
                  ),
                ],
              ),
            ),

            // 📄 MAIN AREA
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
