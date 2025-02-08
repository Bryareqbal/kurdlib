import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatingBookView extends StatefulWidget {
  final int bookId;
  const UpdatingBookView({super.key, required this.bookId});

  @override
  State<UpdatingBookView> createState() => _UpdatingBookViewState();
}

class _UpdatingBookViewState extends State<UpdatingBookView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  Map<String, dynamic>? _bookDetails;
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publishDateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _pdfURLController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _fetchBookDetails();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase.from('Categories').select();
      if (mounted) {
        setState(() {
          _categories = List<Map<String, dynamic>>.from(response);
        });
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${error.toString()}'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pdfURLController.dispose();
    _authorController.dispose();
    _publishDateController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookDetails() async {
    try {
      final response = await _supabase
          .from('Books')
          .select()
          .eq('id', widget.bookId)
          .single();

      if (mounted) {
        setState(() {
          _bookDetails = response;
          _nameController.text = _bookDetails?['book_name'] ?? '';
          _authorController.text = _bookDetails?['authorName'] ?? '';
          _publishDateController.text = _bookDetails?['publish_date'] ?? '';
          _descController.text = _bookDetails?['desc'] ?? '';
          _selectedCategoryId = _bookDetails?['categoryID']?.toString();
          _imageController.text = _bookDetails?['image'] ?? '';
          _pdfURLController.text = _bookDetails?['pdfURL'] ?? '';
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load book details: ${error.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBook() async {
    try {
      // Show loading indicator
      if (mounted) {
        setState(() {
          _isLoading = true;
        });
      }

      final Map<String, dynamic> updateData = {
        'book_name': _nameController.text,
        'authorName': _authorController.text,
        'desc': _descController.text,
        'categoryID': int.tryParse(_selectedCategoryId ?? ''),
        'image': _imageController.text,
        'pdfURL': _pdfURLController.text,
        'publish_date': _publishDateController.text.isEmpty
            ? null
            : _publishDateController.text
      };

      await _supabase.from('Books').update(updateData).eq('id', widget.bookId);

      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'کتێبەکە نوێکرایەوە',
              style: TextStyle(fontFamily: myCustomFont),
            ),
          ),
        );

        // Pop only after everything is done
        // Navigator.pop(context, true);
      }
    } catch (error) {
      // Hide loading indicator on error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update book: ${error.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteBook() async {
    try {
      await _supabase.from('Books').delete().eq('id', widget.bookId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'پەڕتووکەکە سڕایەوە.',
              style: TextStyle(fontFamily: myCustomFont),
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete book: ${error.toString()}')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Show a dialog with three options
    String? selection = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'هەڵبژاردنی ڕێکەوت',
            style: TextStyle(fontFamily: myCustomFont),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  'ڕێکەوتی تەواو',
                  style: TextStyle(fontFamily: myCustomFont),
                ),
                onTap: () => Navigator.of(context).pop('full'),
              ),
              ListTile(
                title: Text(
                  'تەنها ساڵ',
                  style: TextStyle(fontFamily: myCustomFont),
                ),
                onTap: () => Navigator.of(context).pop('year'),
              ),
              ListTile(
                title: Text(
                  'بەتاڵ',
                  style: TextStyle(fontFamily: myCustomFont),
                ),
                onTap: () => Navigator.of(context).pop('null'),
              ),
            ],
          ),
        );
      },
    );

    if (selection == null) return;

    switch (selection) {
      case 'full':
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1800),
          lastDate: DateTime(2100),
          locale: const Locale('en', 'US'),
        );

        if (pickedDate != null) {
          if (mounted) {
            setState(() {
              _publishDateController.text =
                  "${pickedDate.toLocal()}".split(' ')[0];
            });
          }
        }
        break;

      case 'year':
        // int currentYear = DateTime.now().year;
        int? selectedYear = await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'هەڵبژاردنی ساڵ',
                style: TextStyle(fontFamily: myCustomFont),
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  itemCount: 101, // Years from 2000 to 2100
                  itemBuilder: (context, index) {
                    int year = 2000 + index;
                    return ListTile(
                      title: Text(
                        year.toString(),
                        style: TextStyle(fontFamily: myCustomFont),
                      ),
                      onTap: () => Navigator.of(context).pop(year),
                    );
                  },
                ),
              ),
            );
          },
        );

        if (selectedYear != null) {
          if (mounted) {
            setState(() {
              _publishDateController.text = selectedYear.toString();
            });
          }
        }
        break;

      case 'null':
        if (mounted) {
          setState(() {
            _publishDateController.text = '';
          });
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired color
        ),
        centerTitle: true,
        title: Text('نوێکردنەوەی پەڕتووک ',
            style: TextStyle(
                fontFamily: myCustomFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_bookDetails != null) ...[
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            style: TextStyle(fontFamily: myCustomFont),
                            decoration: InputDecoration(
                              labelText: 'ناوی پەڕتووک',
                              labelStyle: TextStyle(fontFamily: myCustomFont),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _authorController,
                            style: TextStyle(fontFamily: myCustomFont),
                            decoration: InputDecoration(
                              labelText: 'ناوی خاوەن',
                              labelStyle: TextStyle(fontFamily: myCustomFont),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _publishDateController,
                                style: TextStyle(fontFamily: myCustomFont),
                                decoration: InputDecoration(
                                  labelText: 'ڕێکەوتی بڵاوکردنەوە',
                                  labelStyle: TextStyle(
                                    fontFamily: myCustomFont,
                                  ), // Adjust font name
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _descController,
                            style: TextStyle(fontFamily: myCustomFont),
                            decoration: InputDecoration(
                              labelText: 'ڕوونکردنەوە',
                              labelStyle: TextStyle(fontFamily: myCustomFont),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),

                          //Convert Category TextField into DropdownButton
                          DropdownButtonFormField<String>(
                            value: _selectedCategoryId,
                            style: TextStyle(
                                fontFamily: myCustomFont, color: Colors.black),
                            decoration: InputDecoration(
                              labelText: 'پۆل',
                              labelStyle: TextStyle(fontFamily: myCustomFont),
                              border: OutlineInputBorder(),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category['id'].toString(),
                                child: Text(
                                  category['name'] ?? '',
                                  style: TextStyle(fontFamily: myCustomFont),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (mounted) {
                                setState(() {
                                  _selectedCategoryId = newValue;
                                });
                              }
                            },
                          ),

                          const SizedBox(height: 16),
                          TextField(
                            controller: _pdfURLController,
                            style: TextStyle(fontFamily: myCustomFont),
                            decoration: InputDecoration(
                              labelText: 'بەستەری PDF',
                              labelStyle: TextStyle(fontFamily: myCustomFont),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (_bookDetails!['image'] != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                _bookDetails!['image'],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Text('Failed to load image'),
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          TextField(
                            controller: _imageController,
                            style: TextStyle(fontFamily: myCustomFont),
                            decoration: InputDecoration(
                              labelText: 'بەستەری وێنە',
                              labelStyle: TextStyle(fontFamily: myCustomFont),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (_bookDetails!['image_url'] != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Image.network(
                                _bookDetails!['image_url'],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Text('Failed to load image'),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .teal, // Change button color to match the theme
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 5,
                                  ),
                                  onPressed: _updateBook,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('نوێکردنەوە',
                                        style: TextStyle(
                                          fontFamily: myCustomFont,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ),
                              ),
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: _deleteBook,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors
                                        .teal, // Change button color to match the theme
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 40, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    elevation: 5,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('سڕینەوە',
                                        style: TextStyle(
                                          fontFamily: myCustomFont,
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        )),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
