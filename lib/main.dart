import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  String text = "";
  bool editing = false;
  TextEditingController controller = TextEditingController();

  Future<void> importFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String content = await file.readAsString();
      setState(() {
        text = content;
        controller.text = content;
        editing = true;
      });
    }
  }

  Future<void> exportFile() async {
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save TXT File',
      fileName: 'note.txt',
    );

    if (outputPath != null) {
      File file = File(outputPath);
      await file.writeAsString(controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = isDark ? Colors.white : Colors.black;
    Color buttonColor = isDark ? Colors.white : Colors.black;
    Color buttonText = isDark ? Colors.black : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: exportFile,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                    child: Text(
                      "Export file",
                      style: TextStyle(color: buttonText),
                    ),
                  ),
                  TextButton(
                    onPressed: importFile,
                    style: TextButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                    child: Text(
                      "Import file",
                      style: TextStyle(color: buttonText),
                    ),
                  ),
                ],
              ),
            ),

            // MAIN AREA
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
                          style: TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        )
                      : Center(
                          child: Text(
                            "Open a file or create a file.",
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
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
