import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController controller = TextEditingController();
  bool editing = false;

  // 📥 IMPORT
  Future<void> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result == null || result.files.single.path == null) return;

    File file = File(result.files.single.path!);
    String content = await file.readAsString();

    setState(() {
      controller.text = content;
      editing = true;
    });
  }

  // 📤 EXPORT (ANDROID + IOS UYUMLU)
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

    // ANDROID → klasör seç + kaydet
    if (Platform.isAndroid) {
      String? folder = await FilePicker.platform.getDirectoryPath();
      if (folder == null) return;

      File file = File("$folder/$fileName");
      await file.writeAsString(text);
    }

    // IOS → app storage + share
    else if (Platform.isIOS) {
      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/$fileName");

      await file.writeAsString(text);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: "TXT Export",
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color text = isDark ? Colors.white : Colors.black;
    Color button = isDark ? Colors.white : Colors.black;
    Color buttonText = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: exportFile,
                    style: TextButton.styleFrom(backgroundColor: button),
                    child: Text("Export file",
                        style: TextStyle(color: buttonText)),
                  ),
                  TextButton(
                    onPressed: importFile,
                    style: TextButton.styleFrom(backgroundColor: button),
                    child: Text("Import file",
                        style: TextStyle(color: buttonText)),
                  ),
                ],
              ),
            ),

            // MAIN AREA
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => editing = true);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: editing
                      ? TextField(
                          controller: controller,
                          maxLines: null,
                          autofocus: true,
                          style: TextStyle(color: text),
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
                              color: text,
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
