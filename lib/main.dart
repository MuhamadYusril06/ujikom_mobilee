import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/gallery_page.dart';
import 'screens/agenda_page.dart';
import 'screens/info_page.dart';
import 'screens/login_page.dart';
import '../models/user.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.black,
          secondary: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
        ),
        appBarTheme: const AppBarTheme(
          color: Colors.black,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: MainNavigationPage(),
    );
  }
}

class MainNavigationPage extends StatefulWidget {
  @override
  _MainNavigationPageState createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;
  User? _currentUser;

  final List<Widget> _widgetOptions = <Widget>[
    HomePage(user: null),
    GalleryPage(user: null),
    AgendaPage(user: null),
    InfoPage(user: null),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void setLoggedInUser(User user) {
    setState(() {
      _currentUser = user;
      _widgetOptions[0] = HomePage(user: user);
      _widgetOptions[1] = GalleryPage(user: user);
      _widgetOptions[2] = AgendaPage(user: user);
      _widgetOptions[3] = InfoPage(user: user);
    });
  }

  void _handleLoginTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(onLoginSuccess: setLoggedInUser),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App'),
        actions: [
          IconButton(
            icon: Icon(_currentUser != null ? Icons.logout : Icons.login),
            onPressed: _currentUser != null
                ? () {
                    setState(() {
                      _currentUser = null;
                      _widgetOptions[0] = HomePage(user: null);
                      _widgetOptions[1] = GalleryPage(user: null);
                      _widgetOptions[2] = AgendaPage(user: null);
                      _widgetOptions[3] = InfoPage(user: null);
                    });
                  }
                : _handleLoginTap,
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: 'Gallery',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
