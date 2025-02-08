import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kurdlib/Drawer/AboutTheAppView.dart';
import 'package:kurdlib/Drawer/AccountCredentialsView.dart';
import 'package:kurdlib/Drawer/AdminAccountView.dart';
import 'package:kurdlib/Drawer/UserProfileView.dart';
import 'package:kurdlib/MainScreen/BookDetailsView.dart';
import 'package:kurdlib/MainScreen/BrowsingBooks/BrowsingBooksView.dart';
import 'package:kurdlib/MainScreen/BrowsingCategories/BrowsingCatsView.dart';
import 'package:kurdlib/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MainScreenView extends StatefulWidget {
  const MainScreenView({super.key});
  @override
  State<MainScreenView> createState() => _MainScreenViewState();
}

class _MainScreenViewState extends State<MainScreenView> {
  final _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _categories = [];
  StreamSubscription? _subscription;
  List<Map<String, dynamic>> _filteredBooks = [];
  late Future<String> _loggedUserFuture;
  late StreamSubscription UserStatusUpdatedSubscription;

  Map<String, bool> _selectedCategories = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
    _initializeCategories();

    UserStatusUpdatedSubscription =
        eventBus.on<UserStatusUpdatedEvent>().listen((event) {
      _loggedUserFuture = _getLoggedUser();
      setState(() {
        _loggedUserFuture = _getLoggedUser();
      });
    });

    _loggedUserFuture = _getLoggedUser();
  }

  Future<void> _initializeData() async {
    final data =
        await _supabase.from('Books').select().order('id', ascending: false);

    setState(() {
      _books = List<Map<String, dynamic>>.from(data);
    });

    debugPrint('Initial data: $data');
    _subscription = _supabase.from('Books').stream(primaryKey: ['id']).listen((
      List<Map<String, dynamic>> data,
    ) {
      debugPrint('Stream data: $data');
      setState(() {
        _books = data.reversed.toList(); // Reverse the streamed data
        _filteredBooks = _books;
      });
    });
  }

  Future<void> _initializeCategories() async {
    final data = await _supabase
        .from('Categories')
        .select()
        .order('id', ascending: false);

    setState(() {
      _categories = List<Map<String, dynamic>>.from(data);
      _selectedCategories = {
        for (var item in _categories) item['id'].toString(): false,
      };
    });

    debugPrint('Categories Initial data: $data');
    _subscription = _supabase
        .from('Categories')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      debugPrint('Categories Stream data: $data');
      setState(() {
        _categories = data;
      });
    });
  }

  final TextEditingController _searchController = TextEditingController();

  void _filterBooks() {
    setState(() {
      _filteredBooks = _books.where((book) {
        bool matchesCategories = true;
        if (_selectedCategories.containsValue(true)) {
          matchesCategories =
              _selectedCategories[book['categoryID'].toString()] ?? false;
        }

        bool matchesSearch = true;
        if (_searchController.text.isNotEmpty) {
          if (_searchType == 'name') {
            matchesSearch = book['book_name']?.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ) ??
                false;
          } else {
            matchesSearch = book['authorName']?.toLowerCase().contains(
                      _searchController.text.toLowerCase(),
                    ) ??
                false;
          }
        }

        return matchesCategories && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  String _searchType = 'name'; // Track search type (either 'name' or 'author')

  Future<String> _getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('loggedUser') ?? 'regular_user';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 18, 90, 82),
        child: FutureBuilder<String>(
          future: _loggedUserFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading user data'));
            } else if (snapshot.hasData) {
              String loggedUser = snapshot.data!;
              Widget profilePage;

              if (loggedUser == 'regular_user') {
                profilePage = AccountCredentialsView();
              } else if (loggedUser == 'user') {
                profilePage = UserProfileView();
              } else {
                profilePage = AdminAccountView();
              }

              return ListView(
                children: [
                  ListTile(
                    title: Text(
                      'لاپەڕەی من',
                      style: TextStyle(
                          fontFamily: myCustomFont,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    leading: Icon(Icons.account_box_outlined),
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => profilePage),
                      );
                    },
                  ),
                  ListTile(
                    title: Text(
                      'دەربارەی بەرنامە',
                      style: TextStyle(
                          fontFamily: myCustomFont,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    leading: Icon(Icons.info),
                    iconColor: Colors.white,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AboutTheAppView(),
                        ),
                      );
                    },
                  ),
                  if (loggedUser == 'admin' || loggedUser == 'user')
                    ListTile(
                      title: Text(
                        'چوونەدەرەوە',
                        style: TextStyle(
                            fontFamily: myCustomFont,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                      leading: Icon(Icons.logout),
                      iconColor: Colors.white,
                      onTap: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setString('loggedUser', 'regular_user');
                        await prefs.setString('loggedUserID', '0');

                        setState(() {
                          _loggedUserFuture = _getLoggedUser();
                        });

                        Navigator.pop(context);
                      },
                    ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  'No user data',
                  style: TextStyle(fontFamily: myCustomFont),
                ),
              );
            }
          },
        ),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired color
        ),
        title: Text('پەڕتووکەکان',
            style: TextStyle(
                fontFamily: myCustomFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.teal, // Custom AppBar color
        actions: [
          FutureBuilder<String>(
            future: _loggedUserFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                if (snapshot.data == 'admin') {
                  return Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.category),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BrowsingCatsView(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.book),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BrowsingBooksView(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
              }
              return SizedBox.shrink();
            },
          ),
        ],
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
                    ? const Color.fromARGB(255, 51, 51, 51)
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
                prefixIcon: Icon(Icons.search),
                suffixIcon: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _searchType = _searchType == 'name' ? 'author' : 'name';
                      _filterBooks();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      _searchType == 'name' ? 'بەپێی ناو' : 'بەپێی خاوەن',
                      style: TextStyle(
                          fontSize: 12,
                          fontFamily: myCustomFont,
                          color: Colors.teal),
                    ),
                  ),
                ),
              ),
              onChanged: (query) {
                _filterBooks();
              },
            ),
          ),

          // Categories ExpansionTile
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
          // Books Grid
          Expanded(
            child: _filteredBooks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = _filteredBooks[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailsView(book: book),
                            ),
                          );
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 6,
                          shadowColor: Colors.teal
                              .withOpacity(0.3), // Book card shadow color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: book['image'] != null
                                    ? Image.network(
                                        book['image'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                          color: Colors.grey[200],
                                          child: const Icon(
                                            Icons.book,
                                            size: 50,
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.book,
                                          size: 50,
                                        ),
                                      ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ناو: ${book['book_name'] ?? 'ناو نەزانراوە'}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: myCustomFont,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'خاوەن: ${book['authorName'] ?? 'خاوەن نەزانراوە'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: myCustomFont,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book['publish_date'] ??
                                          'ڕێکەوت نەزانراوە',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        fontFamily: myCustomFont,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
