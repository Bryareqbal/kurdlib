import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:kurdlib/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountCredentialsView extends StatefulWidget {
  const AccountCredentialsView({super.key});

  @override
  State<AccountCredentialsView> createState() => _AccountCredentialsViewState();
}

EventBus eventBus = EventBus();

class UserStatusUpdatedEvent {}

class DownloadedBooksStatusUpdatedEvent {}

class _AccountCredentialsViewState extends State<AccountCredentialsView> {
  String _role = 'User'; // Default role
  String _action = 'Login'; // Default role
  bool _obscureText = true; // To control password visibility
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _regionController = TextEditingController();

  // Initialize Supabase
  final supabase = Supabase.instance.client;

  // Helper functions for showing dialogs
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white,

          // Change this to your desired color
        ),
        title: Text('هەژمار',
            style: TextStyle(
                fontFamily: myCustomFont,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Show Name, Age, and Region fields only if role is not 'Admin'
              if (_role != 'Admin' && _action != 'Login')
                Column(
                  children: [
                    const SizedBox(height: 15),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'ناو',
                        labelStyle: TextStyle(
                            fontFamily: myCustomFont, color: Colors.teal),
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF333333)
                                : Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.teal), // Border color when enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.teal), // Border color when focused
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number, // Numeric input only
                      decoration: InputDecoration(
                        labelText: 'تەمەن',
                        labelStyle: TextStyle(
                            fontFamily: myCustomFont, color: Colors.teal),
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF333333)
                                : Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.teal), // Border color when enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.teal), // Border color when focused
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _regionController,
                      decoration: InputDecoration(
                        labelText: 'ناوچە',
                        labelStyle: TextStyle(
                            fontFamily: myCustomFont, color: Colors.teal),
                        fillColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF333333)
                                : Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.teal), // Border color when enabled
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color: Colors.teal), // Border color when focused
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),

              // TextFields for Username and Password
              const SizedBox(height: 20),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'ناوی بەکارهێنەر',
                  labelStyle:
                      TextStyle(fontFamily: myCustomFont, color: Colors.teal),
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF333333)
                      : Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors.teal), // Border color when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors.teal), // Border color when focused
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'تێپەڕەوشە',
                  labelStyle:
                      TextStyle(fontFamily: myCustomFont, color: Colors.teal),
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF333333)
                      : Colors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors.teal), // Border color when enabled
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                        color: Colors.teal), // Border color when focused
                  ),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText; // Toggle visibility
                      });
                    },
                  ),
                ),
                obscureText: _obscureText,
              ),

              // Radio Buttons for User or Admin
              const SizedBox(height: 15),
              Row(
                children: [
                  Radio<String>(
                    value: 'Login',
                    groupValue: _action,
                    activeColor: Colors.teal,
                    onChanged: (String? value) {
                      setState(() {
                        _action = value!;
                      });
                    },
                  ),
                  Text(
                    'چوونەژوورەوە',
                    style: TextStyle(
                      fontFamily: myCustomFont,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Register',
                    groupValue: _action,
                    activeColor: Colors.teal,
                    onChanged: (String? value) {
                      setState(() {
                        _action = value!;
                      });
                    },
                  ),
                  Text(
                    'خۆتۆمارکردن',
                    style: TextStyle(
                      fontFamily: myCustomFont,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              // Radio Buttons for User or Admin
              const SizedBox(height: 15),
              Row(
                children: [
                  Radio<String>(
                    value: 'User',
                    activeColor: Colors.teal,
                    groupValue: _role,
                    onChanged: (String? value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  Text(
                    'بەکارهێنەر',
                    style: TextStyle(fontFamily: myCustomFont),
                  ),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'Admin',
                    activeColor: Colors.teal,
                    groupValue: _role,
                    onChanged: (String? value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  Text(
                    'بەڕێوەبەر',
                    style: TextStyle(fontFamily: myCustomFont),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      if (_role == 'Admin') {
                        // Check credentials for Admin
                        final username = _usernameController.text;
                        final password = _passwordController.text;

                        try {
                          final response = await supabase
                              .from('Admins')
                              .select()
                              .eq('username', username)
                              .eq('password', password)
                              .single();

                          // Success case - response exists
                          print('Credentials of Admin are met');

                          // Save 'admin' in SharedPreferences after successful login
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('loggedUser', 'admin');
                          await prefs.setString(
                              'loggedAdminID', response['id'].toString());
                          print('Logged in as Admin');

                          eventBus.fire(UserStatusUpdatedEvent());

                          Navigator.pop(context);
                        } catch (e) {
                          // Show alert if credentials are not met
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'کێشە',
                                style: TextStyle(fontFamily: myCustomFont),
                              ),
                              content: Text(
                                'هەڵەیەک هەیە.',
                                style: TextStyle(fontFamily: myCustomFont),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        //USER ROLE
                        final username = _usernameController.text;
                        final password = _passwordController.text;

                        try {
                          final response = await supabase
                              .from('Users')
                              .select('id, name')
                              .eq('username', username)
                              .eq('password', password)
                              .single();

                          // Success case - response exists
                          print('Credentials of User are met');

                          // Save 'user' in SharedPreferences after successful login
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setString('loggedUser', 'user');
                          await prefs.setString(
                              'loggedUserID', response['id'].toString());
                          await prefs.setString(
                              'loggedUsername', response['name'].toString());
                          print('Logged in as User');

                          eventBus.fire(UserStatusUpdatedEvent());

                          Navigator.pop(context);
                        } catch (e) {
                          // Show alert if credentials are not met
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(
                                'کێشە',
                                style: TextStyle(fontFamily: myCustomFont),
                              ),
                              content: Text(
                                'هەڵەیەک هەیە.',
                                style: TextStyle(fontFamily: myCustomFont),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'باشە',
                                    style: TextStyle(fontFamily: myCustomFont),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: Text('چوونەژوورەوە',
                        style: TextStyle(
                          fontFamily: myCustomFont,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? const Color.fromARGB(255, 0, 166, 150)
                              : const Color.fromARGB(
                                  255, 0, 166, 150), // matching color
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 30,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  if (_role != 'Admin' && _action == 'Register')
                    ElevatedButton(
                      onPressed: () async {
                        // Retrieve values
                        String name = _nameController.text.trim();
                        String username = _usernameController.text.trim();
                        String password = _passwordController.text;
                        String region = _regionController.text.trim();
                        String ageText = _ageController.text.trim();

                        // Validation checks
                        if (name.isEmpty ||
                            username.isEmpty ||
                            password.isEmpty ||
                            region.isEmpty ||
                            ageText.isEmpty) {
                          _showErrorDialog(
                              context, "هەموو فیڵدەکان پێویستە پڕ بکرێنەوە.");
                          return;
                        }

                        if (username.length < 4) {
                          _showErrorDialog(context,
                              "ناوی بەکارهێنەر بەلایەنی کەمەوە پێویستە چوار پیت بێت.");
                          return;
                        }

                        if (password.length < 6) {
                          _showErrorDialog(context,
                              "تێپەڕەوشە پێویستە بەلایەنی کەمەوە شەش پیت بێت.");
                          return;
                        }

                        int? age = int.tryParse(ageText);
                        if (age == null || age < 18) {
                          _showErrorDialog(
                              context, "تەمەن پێویستە لەسەروو هەژدەوە بێت.");
                          return;
                        }

                        // Insert into Supabase if all validations pass
                        await supabase.from('Users').insert({
                          'name': name,
                          'username': username,
                          'password': password,
                          'region': region,
                          'age': ageText,
                        });

                        _showSuccessDialog(
                            context, "خۆتۆمارکردن سەرکەوتوو بوو!");
                      },
                      child: Text(
                        'خۆتۆمارکردن',
                        style: TextStyle(
                          fontFamily: myCustomFont,
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromARGB(255, 0, 166, 150)
                                : const Color.fromARGB(255, 0, 166, 150),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
