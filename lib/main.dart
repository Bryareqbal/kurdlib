import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kurdlib/MainScreen/DownloadedBooksView.dart';
import 'package:kurdlib/MainScreen/MainScreenView.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final TextStyle rudawFontStyle = TextStyle(
  fontFamily: 'Rudaw',
);

String myCustomFont = 'Rudaw';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ggzqkbsjwsqmwymkafjz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdnenFrYnNqd3NxbXd5bWthZmp6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzQ2MDU2MTYsImV4cCI6MjA1MDE4MTYxNn0.8rj9InYg6Qlt0CBAf1N3wmUxVleC3oOrA5j5mRhQBGk',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
      ),
      supportedLocales: const [Locale('ar', 'AE')],
      routes: {
        '/': (context) => BottomNav(),
      },
    );
  }
}

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final List<Widget> _pages = [MainScreenView(), DownloadedBooksView()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages.map((page) {
          return Navigator(
            onGenerateRoute: (routeSettings) {
              return MaterialPageRoute(
                builder: (context) => page,
              );
            },
          );
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : Colors.white,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle:
            rudawFontStyle.copyWith(fontWeight: FontWeight.bold),
        unselectedLabelStyle: rudawFontStyle.copyWith(color: Colors.grey),
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.teal
            : const Color.fromARGB(255, 0, 166, 150),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _currentIndex == 0
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.book_sharp),
            ),
            label: 'پەڕتووکەکان',
          ),
          BottomNavigationBarItem(
            icon: Container(
              decoration: BoxDecoration(
                color: _currentIndex == 1
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.amber.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.download_for_offline_outlined),
            ),
            label: 'دابەزێنراوەکان',
          ),
        ],
      ),
    );
  }
}
