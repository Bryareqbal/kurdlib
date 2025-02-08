import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:kurdlib/main.dart';
import 'package:path_provider/path_provider.dart';

class OpenedPDFReadingView extends StatefulWidget {
  final String pdfUrl; // Pass the URL of the PDF
  final String bookName; // Pass the name of the book
  const OpenedPDFReadingView(
      {super.key, required this.pdfUrl, required this.bookName});

  @override
  State<OpenedPDFReadingView> createState() => _OpenedPDFReadingViewState();
}

class _OpenedPDFReadingViewState extends State<OpenedPDFReadingView> {
  String _filePath = ""; // Variable to store the path of the downloaded PDF

  @override
  void initState() {
    super.initState();
    _loadPdfFromUrl();
  }

  Future<void> _loadPdfFromUrl() async {
    try {
      // Download the PDF from the URL
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      // Get temporary directory to store the file
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/temp.pdf';

      // Write the downloaded bytes to the file
      final file = await File(filePath).writeAsBytes(bytes);

      setState(() {
        _filePath = file.path;
      });
    } catch (e) {
      // Handle errors like failed download
      print("Error loading PDF: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,

          // Change this to your desired color
        ),
        title: Text("خوێندنەوەی '${widget.bookName}'",
            style: TextStyle(
                fontFamily: myCustomFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
      ),
      body: _filePath.isEmpty
          ? Center(child: CircularProgressIndicator()) // Show a loading spinner
          : PDFView(
              filePath: _filePath, // Pass the file path to the PDFView widget
            ),
    );
  }
}
