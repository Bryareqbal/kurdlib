import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kurdlib/Drawer/AccountCredentialsView.dart';
import 'package:kurdlib/MainScreen/OpenedDownloadedPDFReadingView.dart';
import 'package:kurdlib/MainScreen/OpenedPDFReadingView.dart';
import 'package:kurdlib/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookDetailsView extends StatefulWidget {
  final Map<String, dynamic> book;

  const BookDetailsView({super.key, required this.book});

  @override
  State<BookDetailsView> createState() => _BookDetailsViewState();
}

class _BookDetailsViewState extends State<BookDetailsView> {
  // Change the type to be non-nullable and initialize it
  late Stream<List<Map<String, dynamic>>> comments;
  final _supabase = Supabase.instance.client;
  StreamSubscription? _subscription;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoggedUser = false;
  bool isDownloaded = false;
  late StreamSubscription DownloadedBooksStatusSubscription;
  List<FileSystemEntity> downloadedBooks = [];
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    comments = _fetchCommentsStream(widget.book['id']);
    _checkLoggedUser();
    _checkIfDownloaded();
    _loadDownloadedBooks();

    DownloadedBooksStatusSubscription =
        eventBus.on<DownloadedBooksStatusUpdatedEvent>().listen((event) {
      if (mounted) {
        setState(() {
          _checkIfDownloaded();
        });
      }
    });
  }

  Future<void> _checkLoggedUser() async {
    String? loggedUser = await _getLoggedUser();
    if (loggedUser == 'user') {
      if (mounted) {
        setState(() {
          _isLoggedUser = true;
        });
      }
    }
  }

  Future<String?> _getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedUser');
  }

  Future<String?> _getLoggedUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedUserID');
  }

  Future<String?> _getLoggedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedUsername');
  }

  // Don't forget to cancel the subscription
  @override
  void dispose() {
    _subscription?.cancel();
    DownloadedBooksStatusSubscription.cancel(); // Added this line
    _commentController.dispose();
    super.dispose();
  }

  Stream<List<Map<String, dynamic>>> _fetchCommentsStream(int bookID) {
    return _supabase
        .from('Comments')
        .stream(primaryKey: ['id'])
        .eq('bookID', bookID)
        .map((event) => event.map((e) => e).toList());
  }

  Future<void> _deleteComment(int id) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سڕینەوەی لێدوان'),
        content: const Text('لە سڕینەوەی ئەم لێدوانە دڵنیایت؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('نەخێر'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('سڕینەوە'),
          ),
        ],
      ),
    );
    if (confirmation == true) {
      try {
        await _supabase.from('Comments').delete().eq('id', id);

        if (mounted) {
          setState(() {
            comments = _fetchCommentsStream(widget.book['id']);
          });
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('لێدوانەکە سڕایەوە')));
      } catch (error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $error')));
      }
    }
  }

  // Function to check if the file is already downloaded
  Future<void> _checkIfDownloaded() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath =
        '${directory.path}/${widget.book['book_name']}_${widget.book['id']}.pdf';

    // Check if the file exists
    bool exists = await File(filePath).exists();

    if (mounted) {
      setState(() {
        isDownloaded = exists;
      });
    }
  }

  void downloadPDF(
      String url, int bookID, String bookName, BuildContext context) async {
    double currentProgress = 0.0;
    late BuildContext dialogContext;

    try {
      // Show loading dialog with StatefulBuilder
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: currentProgress,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "پەڕتووکی '$bookName' لە دابەزیندایە...: ${(currentProgress * 100).toStringAsFixed(0)}%",
                      style: TextStyle(fontFamily: myCustomFont),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      // Get the document directory
      final directory = await getApplicationDocumentsDirectory();
      final savePath = '${directory.path}/${bookName}_$bookID.pdf';

      // Download the file
      final dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Calculate progress
            final newProgress = received / total;

            // Update dialog state if the dialog is still shown
            if (dialogContext.mounted) {
              (dialogContext as Element).markNeedsBuild();
              // Update the dialog using correct context
              (dialogContext as Element).visitChildren((element) {
                if (element.widget is StatefulBuilder) {
                  (element as StatefulElement).markNeedsBuild();
                }
              });
            }

            // Update the progress value
            currentProgress = newProgress;
          }
        },
      );

      // Close loading dialog
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }

      // Reset progress in parent widget
      if (mounted) {
        setState(() {
          progress = 0.0;
          isDownloaded = true;
        });
      }

      // Notify that download is complete
      eventBus.fire(DownloadedBooksStatusUpdatedEvent());

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$bookName دابەزێنرا', style: rudawFontStyle),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Handle errors
      if (dialogContext.mounted) {
        Navigator.of(dialogContext).pop();
      }

      // Reset progress
      if (mounted) {
        setState(() {
          progress = 0.0;
        });
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print("Error downloading file: $e");
    }
  }

  Future<void> _loadDownloadedBooks() async {
    final directory = await getApplicationDocumentsDirectory();
    final files = directory.listSync();

    setState(() {
      downloadedBooks =
          files.where((file) => file.path.endsWith('.pdf')).toList();
    });
  }

  void _showOptionsDialog(File file) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('پەڕتووکی دابەزێنراو',
              style: TextStyle(fontFamily: myCustomFont)),
          content: Text(
            'ئایا دەتەوێت پەڕتووکەکە بکەیتەوە یان بیسڕیتەوە؟',
            style: TextStyle(fontFamily: myCustomFont),
          ),
          actions: [
            TextButton(
              onPressed: () {
                print(file.path);

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

  String extractSubstring(String input) {
    final parts = input.split('_');
    return parts.isNotEmpty ? parts[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired color
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        title: Text(
          book['book_name'] ?? 'Unknown Book',
          style: TextStyle(
            fontFamily: myCustomFont,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: book['image'] != null
                        ? Image.network(
                            book['image'],
                            fit: BoxFit.cover,
                            width: 100,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.book, size: 100);
                            },
                          )
                        : const Icon(Icons.book, size: 100),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ناوی کتێب: ${book['book_name'] ?? 'ناو نەزانراوە'}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: myCustomFont,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'خاوەن: ${book['authorName'] ?? 'خاوەن نەزانراوە'}',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: myCustomFont,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'بڵاوکردنەوە: ${book['publish_date'] ?? 'زانیاری نییە'}',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: myCustomFont,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          OpenedPDFReadingView(
                                        pdfUrl: book['pdfURL'],
                                        bookName: book['book_name'],
                                      ),
                                    ),
                                  );
                                },
                                // icon: const Icon(Icons.chrome_reader_mode_outlined),
                                label: Text('خوێندنەوە',
                                    style: TextStyle(
                                      fontFamily: myCustomFont,
                                      color: Colors.teal,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    )),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: isDownloaded
                                  ? TextButton.icon(
                                      onPressed: () async {
                                        // Wait for the directory to resolve
                                        final dir =
                                            await getApplicationDocumentsDirectory();
                                        final filePath =
                                            '${dir.path}/${book['book_name']}_${book['id']}.pdf';

                                        // Call _showOptionsDialog with the resolved file path
                                        _showOptionsDialog(File(filePath));
                                      },
                                      icon: const Icon(Icons.folder_open),
                                      label: Text(
                                        'کرانەوە',
                                        style:
                                            TextStyle(fontFamily: myCustomFont),
                                      ),
                                    )
                                  : TextButton.icon(
                                      onPressed: () {
                                        downloadPDF(
                                          book['pdfURL'],
                                          book['id'],
                                          book['book_name'],
                                          context,
                                        );
                                      },
                                      // icon: const Icon(Icons.download),
                                      label: Text('دابەزاندن',
                                          style: TextStyle(
                                            fontFamily: myCustomFont,
                                            color: Colors.teal,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'سەبارەت بە کتێب:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: myCustomFont,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book['desc'] ?? 'ڕوونکردنەوەی نییە',
                style: TextStyle(fontSize: 14, fontFamily: myCustomFont),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 20),

              // Display comment input field only if user is logged in as 'user'
              if (_isLoggedUser)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دانانی لێدوان:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: myCustomFont,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _commentController,
                      style: TextStyle(fontFamily: myCustomFont),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .teal), // Color when the TextField is enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .teal), // Color when the TextField is focused
                        ),
                        hintText: 'لێدوان بنووسە...',
                        hintStyle: TextStyle(fontFamily: myCustomFont),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            onPressed: () async {
                              // Add the comment to Supabase when pressed
                              final commentText =
                                  _commentController.text.trim();
                              if (commentText.isNotEmpty) {
                                final userID =
                                    await _getLoggedUserID(); // Or use the user ID logic from your app
                                final userName =
                                    await _getLoggedUsername(); // Or use the user ID logic from your app

                                await _supabase.from('Comments').insert({
                                  'bookID':
                                      int.parse(widget.book['id'].toString()),
                                  'commentText': commentText,
                                  'userID': userID,
                                  'usersName':
                                      userName, // Or fetch actual user name
                                });
                                _commentController.clear();
                              }
                            },
                            child: Text(
                              'دانانی لێدوان',
                              style: TextStyle(
                                  fontFamily: myCustomFont, color: Colors.teal),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              StreamBuilder<List<Map<String, dynamic>>>(
                stream: comments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'هیچ لێدوانێک نەدراوە.',
                        style: TextStyle(fontFamily: myCustomFont),
                      ),
                    );
                  }

                  return FutureBuilder<Map<String, String?>>(
                    // Changed to return both userID and userName in one Future
                    future: Future.wait([
                      _getLoggedUserID(),
                      _getLoggedUser(),
                    ]).then(
                      (results) => {
                        'userID': results[0],
                        'loggedUser': results[1],
                      },
                    ),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (userSnapshot.hasError) {
                        return const Center(
                          child: Text('Error fetching user data.'),
                        );
                      }

                      final userID = userSnapshot.data?['userID'];
                      final userName = userSnapshot.data?['loggedUser'];
                      final isAdmin = userName == 'admin';

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final comment = snapshot.data![index];

                          final isCommentOwner =
                              comment['userID'].toString() == userID;

                          print(userID);

                          return ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              comment['usersName'] ?? 'بەکارهێنەر نەزانراوە',
                              style: TextStyle(fontFamily: myCustomFont),
                            ),
                            subtitle: Text(
                              comment['commentText'] ?? 'لێدوان نییە',
                              style: TextStyle(fontFamily: myCustomFont),
                            ),
                            trailing: isCommentOwner || isAdmin
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        _deleteComment(comment['id']),
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
