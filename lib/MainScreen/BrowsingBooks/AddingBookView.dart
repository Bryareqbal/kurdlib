import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddingBookView extends StatefulWidget {
  const AddingBookView({super.key});

  @override
  State<AddingBookView> createState() => _AddingBookViewState();
}

class _AddingBookViewState extends State<AddingBookView> {
  final SupabaseClient _supabase = Supabase.instance.client;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _publishDateController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _pdfURLController = TextEditingController();

  String? _selectedCategoryId;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();

    _imageController.text =
        "https://marketplace.canva.com/EAFfSnGl7II/2/0/1003w/canva-elegant-dark-woods-fantasy-photo-book-cover-vAt8PH1CmqQ.jpg";
  }

  Future<void> _fetchCategories() async {
    try {
      final response = await _supabase.from('Categories').select();
      setState(() {
        _categories = List<Map<String, dynamic>>.from(response);
        // Set the initial value only after categories are loaded
        if (_categories.isNotEmpty && _selectedCategoryId == null) {
          _selectedCategoryId = _categories[0]['id'].toString();
        }
      });
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
    _imageController.dispose();
    super.dispose();
  }

  Future<void> _addBook() async {
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    try {
      await _supabase.from('Books').insert({
        'book_name': _nameController.text,
        'authorName': _authorController.text,
        'publish_date': _publishDateController.text,
        'desc': _descController.text,
        'categoryID': int.parse(_selectedCategoryId!),
        'image': _imageController.text,
        'pdfURL': _pdfURLController.text
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('پەڕتووکەکە زیادکرا',
                  style: TextStyle(fontFamily: myCustomFont))),
        );
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to insert book: ${error.toString()}')),
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
        title: Text('زیادکردنی پەڕتووک',
            style: TextStyle(
                fontFamily: myCustomFont,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              if (_categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  style:
                      TextStyle(fontFamily: myCustomFont, color: Colors.teal),
                  decoration: InputDecoration(
                    labelText: 'پۆل',
                    labelStyle: TextStyle(fontFamily: myCustomFont),
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    final id = category['id'].toString();
                    return DropdownMenuItem<String>(
                      value: id,
                      child: Text(
                        category['name'] ?? '',
                        style: TextStyle(fontFamily: myCustomFont),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                    });
                  },
                ),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _addBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.teal, // Change button color to match the theme
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 5,
                ),
                child: Text('زیادکردنی پەڕتووک',
                    style: TextStyle(
                      fontFamily: myCustomFont,
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
