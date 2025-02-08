import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileView extends StatefulWidget {
  const UserProfileView({super.key});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  String? userID;
  String? username;
  String? age;
  String? region;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details from SharedPreferences and Supabase
  Future<void> _fetchUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedUserID = prefs.getString('loggedUserID');

    if (loggedUserID != null) {
      setState(() {
        userID = loggedUserID;
      });

      // Fetch the user details from Supabase
      try {
        final response = await Supabase.instance.client
            .from('Users')
            .select('name, age, region')
            .eq('id', loggedUserID)
            .single();

        setState(() {
          username = response['name'] as String?;
          age = response['age']?.toString();
          region = response['region'] as String?;
        });
      } catch (e) {
        print('Error during Supabase query: $e');
      }
    } else {
      print('User ID not found in SharedPreferences.');
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
        centerTitle: true, // Center the AppBar title
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : const Color.fromARGB(255, 0, 166, 150),
        title: Text(
          'هەژماری بەکارهێنەر',
          style: rudawFontStyle.copyWith(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              // Center all content
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
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Center content horizontally
                  children: [
                    if (userID != null)
                      Text(
                        "ئایدی: $userID",
                        style: rudawFontStyle.copyWith(fontSize: 16),
                      ),
                    const SizedBox(height: 8),
                    if (username != null)
                      Text(
                        "ناوی بەکارهێنەر: $username",
                        style: rudawFontStyle.copyWith(fontSize: 16),
                      )
                    else
                      Text(
                        "Username: Not found",
                        style: rudawFontStyle.copyWith(
                            fontSize: 16, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    if (age != null)
                      Text(
                        "تەمەن: $age",
                        style: rudawFontStyle.copyWith(fontSize: 16),
                      )
                    else
                      Text(
                        "Age: Not found",
                        style: rudawFontStyle.copyWith(
                            fontSize: 16, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    if (region != null)
                      Text(
                        "ناوچە: $region",
                        style: rudawFontStyle.copyWith(fontSize: 16),
                      )
                    else
                      Text(
                        "Region: Not found",
                        style: rudawFontStyle.copyWith(
                            fontSize: 16, color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
