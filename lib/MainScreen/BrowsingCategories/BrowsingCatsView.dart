import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BrowsingCatsView extends StatefulWidget {
  const BrowsingCatsView({super.key});

  @override
  State<BrowsingCatsView> createState() => _BrowsingCatsViewState();
}

class _BrowsingCatsViewState extends State<BrowsingCatsView> {
  final SupabaseClient _supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = _fetchCategoriesStream();
  }

  Stream<List<Map<String, dynamic>>> _fetchCategoriesStream() {
    return _supabase.from('Categories').stream(
        primaryKey: ['id']).map((event) => event.map((e) => e).toList());
  }

  Future<void> _addCategory() async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('زیادکردنی پۆل',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'ناوی پۆل',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('پاشگەزبوونەوە'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('زیادکردن'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        await _supabase.from('Categories').insert({'name': result});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پۆلەکە زیادکرا')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  Future<void> _deleteCategory(int categoryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دڵنیایت لە سڕینەوە؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('نەخێر'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بەڵێ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _supabase.from('Categories').delete().eq('id', categoryId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('پۆلەکە سڕایەوە')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, // Change this to your desired color
        ),
        title: Text(
          'بەڕێوەبردنی پۆلەکان',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.white,
              fontFamily: myCustomFont),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addCategory,
            tooltip: 'زیادکردن',
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'هیچ پۆلێک بەردەست نییە',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final categories = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                elevation: 2.0,
                child: ListTile(
                  title: Text(
                    category['name'].toString(),
                    style: TextStyle(fontFamily: myCustomFont),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteCategory(category['id']),
                  ),
                  onTap: () {
                    // Add your update logic here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
