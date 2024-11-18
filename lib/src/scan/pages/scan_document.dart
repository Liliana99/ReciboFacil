import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class DocumentScannerPage extends StatefulWidget {
  static const routeName = '/document_scanner';

  const DocumentScannerPage({super.key});
  @override
  _DocumentScannerPageState createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  String scannedText = "";

  Future<void> _scanDocument() async {
    try {
      final List<String>? imagePath = await CunningDocumentScanner.getPictures(
          noOfPages: 1, isGalleryImportAllowed: true);

      if (imagePath != null && imagePath.isNotEmpty) {
        await _recognizeText(imagePath.first);
      }
    } catch (e) {
      setState(() {
        scannedText = 'Error while scanning document: \$e';
      });
    }
  }

  Future<void> _recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);
      setState(() {
        scannedText = recognizedText.text;
      });
    } catch (e) {
      setState(() {
        scannedText = 'Error while recognizing text: \$e';
      });
    } finally {
      textRecognizer.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Scanner and OCR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _scanDocument,
              child: Text('Scan Document'),
            ),
            SizedBox(height: 20),
            Text(
              scannedText.isEmpty ? 'No text recognized yet.' : scannedText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
