import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAccountView extends StatefulWidget {
  const AdminAccountView({super.key});

  @override
  State<AdminAccountView> createState() => _AdminAccountViewState();
}

class _AdminAccountViewState extends State<AdminAccountView> {
  String? adminID;
  String? username;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdminDetails();
  }

  // Fetch Admin details from SharedPreferences and Supabase
  Future<void> _fetchAdminDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedAdminID = prefs.getString('loggedAdminID');

    if (loggedAdminID != null) {
      setState(() {
        adminID = loggedAdminID;
      });

      try {
        final response = await Supabase.instance.client
            .from('Admins')
            .select('username')
            .eq('id', loggedAdminID)
            .single();

        setState(() {
          username = response['username'] as String?;
        });
      } catch (e) {
        print('Error during Supabase query: $e');
      }
    } else {
      print('Admin ID not found in SharedPreferences.');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
    color: Colors.white, // Change this to your desired color
  ),
        centerTitle: true, // Center the text in the AppBar
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : const Color.fromARGB(255, 0, 166, 150),
        title: Text(
          'هەژماری بەڕێوەبەر',
          style: rudawFontStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center( // Center everything in the body
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E1E1E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    if (Theme.of(context).brightness == Brightness.light)
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Center content vertically
                  crossAxisAlignment: CrossAxisAlignment.center, // Center text horizontally
                  children: [
                    if (adminID != null)
                      Text(
                        "ئایدی: $adminID",
                        style: rudawFontStyle.copyWith(fontSize: 16),
                      ),
                    const SizedBox(height: 8),
                    if (username != null)
                      Text(
                        "ناوی بەڕێوەبەر: $username",
                        style: rudawFontStyle.copyWith(fontSize: 16),
                      ),
                    if (username == null)
                      Text(
                        "ناوی بەڕێوەبەر: نەدۆزرایەوە.",
                        style: rudawFontStyle.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey
                              : Colors.redAccent,
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
