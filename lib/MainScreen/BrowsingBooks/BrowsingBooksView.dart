import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurdlib/MainScreen/BrowsingBooks/AddingBookView.dart';
import 'package:kurdlib/MainScreen/BrowsingBooks/UpdatingBookView.dart';
import 'package:kurdlib/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BrowsingBooksView extends StatefulWidget {
  const BrowsingBooksView({super.key});

  @override
  State<BrowsingBooksView> createState() => _BrowsingBooksViewState();
}

class _BrowsingBooksViewState extends State<BrowsingBooksView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _booksStream;
  List<Map<String, dynamic>> _filteredBooks = [];
  List<Map<String, dynamic>> _books = [];
  Map<String, bool> _selectedCategories = {};
  List<Map<String, dynamic>> _categories = [];
  StreamSubscription? _booksSubscription;
  StreamSubscription? _categoriesSubscription;
  final TextEditingController _searchController = TextEditingController();
  String _searchType = 'name';

  @override
  void initState() {
    super.initState();
    _initializeCategories();
    _initializeBooksStream();
  }

  void _initializeBooksStream() {
    _booksStream = _fetchBooksStream();
    _booksSubscription = _booksStream.listen((books) {
      if (mounted) {
        setState(() {
          _books = books;
          _filterBooks();
        });
      }
    });
  }

  Stream<List<Map<String, dynamic>>> _fetchBooksStream() {
    return _supabase
        .from('Books')
        .stream(primaryKey: ['id'])
        .order('publish_date', ascending: false)
        .map((event) => event.map((e) => e).toList().reversed.toList());
  }

  Future<void> _initializeCategories() async {
    try {
      final data = await _supabase
          .from('Categories')
          .select()
          .order('id', ascending: false);

      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(data);
          _selectedCategories = {
            for (var item in _categories) item['id'].toString(): false,
          };
        });

        _categoriesSubscription = _supabase
            .from('Categories')
            .stream(primaryKey: ['id']).listen((data) {
          if (mounted) {
            setState(() {
              _categories = data;
            });
          }
        });
      }
    } catch (error) {
      debugPrint('Error fetching categories: $error');
    }
  }

  void _filterBooks() {
    setState(() {
      _filteredBooks = _books.where((book) {
        bool matchesCategories = !_selectedCategories.containsValue(true) ||
            _selectedCategories[book['categoryID'].toString()] == true;

        bool matchesSearch = _searchController.text.isEmpty ||
            (book[_searchType == 'name' ? 'book_name' : 'authorName']
                    ?.toLowerCase()
                    .contains(_searchController.text.toLowerCase()) ??
                false);

        return matchesCategories && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _booksSubscription?.cancel();
    _categoriesSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired color
        ),
        title: Center(
          child: Text(
            'بەڕێوەبردنی پەڕتووکەکان',
            style: TextStyle(
                fontFamily: myCustomFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddingBookView()),
              );
            },
            child: Text(
              'زیادکردن',
              style: TextStyle(color: Colors.white, fontFamily: myCustomFont),
            ),
          ),
        ],
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontFamily: myCustomFont),
              decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontFamily: myCustomFont, color: Colors.teal),
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF333333)
                    : Colors.white,
                filled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.teal), // Color when the TextField is enabled
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.teal), // Color when the TextField is focused
                ),
                hintText: 'گەڕان بەنێو پەڕتووکەکاندا...',
                hintStyle: TextStyle(fontFamily: myCustomFont),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchType = _searchType == 'name' ? 'author' : 'name';
                      _filterBooks();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    _searchType == 'name' ? 'بەپێی ناو' : 'بەپێی خاوەن',
                    style:
                        TextStyle(fontFamily: myCustomFont, color: Colors.teal),
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (query) => _filterBooks(),
            ),
          ),
          ExpansionTile(
            title: Text('پۆلەکان', style: TextStyle(fontFamily: myCustomFont)),
            children: [
              Wrap(
                spacing: 8.0,
                children: _categories.map((category) {
                  bool isSelected =
                      _selectedCategories[category['id'].toString()] ?? false;

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilterChip(
                      label: Text(
                        category['name'],
                        style: TextStyle(
                          fontFamily: myCustomFont,
                          color: isSelected
                              ? Colors.white
                              : Colors
                                  .teal, // Change text color based on selection
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.teal,
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategories[category['id'].toString()] =
                              selected;
                          _filterBooks();
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Expanded(
            child: _books.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      final reversedIndex = _filteredBooks.length - index;

                      return ListTile(
                        leading: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            book['image'] != null
                                ? Image.network(
                                    book['image'],
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(Icons.book, size: 50),
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Text(
                                '$reversedIndex',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontFamily: myCustomFont),
                              ),
                            ),
                          ],
                        ),
                        title: Text(
                          book['book_name'] ?? 'ناو نەزانراوە',
                          style: TextStyle(fontFamily: myCustomFont),
                        ),
                        subtitle: Text(
                          book['authorName'] ?? 'خاوەن نەزانراوە',
                          style: TextStyle(fontFamily: myCustomFont),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  UpdatingBookView(bookId: book['id']),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
