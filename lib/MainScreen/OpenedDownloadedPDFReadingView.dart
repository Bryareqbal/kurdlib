import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:kurdlib/main.dart';

class OpenedDownloadedPDFReadingView extends StatefulWidget {
  final String pdfPath;
  final String bookName;

  const OpenedDownloadedPDFReadingView(
      {super.key, required this.pdfPath, required this.bookName});

  @override
  State<OpenedDownloadedPDFReadingView> createState() =>
      _OpenedDownloadedPDFReadingViewState();
}

class _OpenedDownloadedPDFReadingViewState
    extends State<OpenedDownloadedPDFReadingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        widget.bookName,
        style: TextStyle(fontFamily: myCustomFont),
      )),
      body: PDFView(
        filePath: widget.pdfPath, // Pass the file path to the PDFView widget
      ),
    );
  }
}
