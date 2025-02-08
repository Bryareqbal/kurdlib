import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kurdlib/Drawer/AccountCredentialsView.dart';
import 'package:kurdlib/MainScreen/OpenedDownloadedPDFReadingView.dart';
import 'package:kurdlib/main.dart';
import 'package:path_provider/path_provider.dart';

class DownloadedBooksView extends StatefulWidget {
  const DownloadedBooksView({super.key});

  @override
  State<DownloadedBooksView> createState() => _DownloadedBooksViewState();
}

class _DownloadedBooksViewState extends State<DownloadedBooksView> {
  List<FileSystemEntity> downloadedBooks = [];
  late StreamSubscription DownloadedBooksStatusSubscription;

  @override
  void initState() {
    super.initState();
    _loadDownloadedBooks();

    DownloadedBooksStatusSubscription =
        eventBus.on<DownloadedBooksStatusUpdatedEvent>().listen((event) {
      setState(() {
        _loadDownloadedBooks();
      });
    });
  }

  Future<void> _loadDownloadedBooks() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    setState(() {
      downloadedBooks =
          files.where((file) => file.path.endsWith('.pdf')).toList();
    });
  }

  String extractSubstring(String input) {
    final parts = input.split('_');
    return parts.isNotEmpty ? parts[0] : '';
  }

  void _showOptionsDialog(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('پەڕتووک', style: TextStyle(fontFamily: myCustomFont)),
          content: Text(
            'ئایا دەتەوێت پەڕتووکەکە بکەیتەوە یان بیسڕیتەوە؟',
            style: TextStyle(fontFamily: myCustomFont),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OpenedDownloadedPDFReadingView(
                      pdfPath: file.path,
                      bookName: extractSubstring(
                        file.uri.pathSegments.last,
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                'کرانەوە',
                style: TextStyle(fontFamily: myCustomFont),
              ),
            ),
            TextButton(
              onPressed: () {
                file.deleteSync();
                setState(() {
                  downloadedBooks.remove(file);
                });

                eventBus.fire(DownloadedBooksStatusUpdatedEvent());

                Navigator.pop(context);
              },
              child: Text(
                'سڕینەوە',
                style: TextStyle(fontFamily: myCustomFont),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        title: Center(
          child: Text('پەڕتووکەکان',
              style: TextStyle(
                  fontFamily: myCustomFont,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18)),
        ),
        backgroundColor: Colors.teal,
      ),
      body: downloadedBooks.isEmpty
          ? Center(
              child: Text(
                'هیچ پەڕتووکێک دانەبەزێنراوە',
                style: TextStyle(fontFamily: myCustomFont),
              ),
            )
          : ListView.builder(
              itemCount: downloadedBooks.length,
              itemBuilder: (context, index) {
                final file = downloadedBooks[index];
                return ListTile(
                  title: Text(
                    extractSubstring(file.uri.pathSegments.last),
                    style: TextStyle(fontFamily: myCustomFont),
                  ),
                  onTap: () => _showOptionsDialog(file as File),
                  trailing: Icon(Icons.chevron_right),
                );
              },
            ),
    );
  }
}
