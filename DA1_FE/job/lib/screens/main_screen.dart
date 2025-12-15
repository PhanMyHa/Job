import 'package:flutter/material.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'message_screen.dart';

class MainScreen extends StatefulWidget {
  final String userEmail;

  const MainScreen({super.key, required this.userEmail});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      SearchScreen(userEmail: widget.userEmail),
      MessageScreen(userEmail: widget.userEmail),
      ProfileScreen(userEmail: widget.userEmail),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('bg.jpg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(child: _screens[_selectedIndex]),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 28),
            activeIcon: Icon(Icons.search, color: Color(0xFFF06292)),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message, size: 28),
            activeIcon: Icon(Icons.message, color: Color(0xFFF06292)),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            activeIcon: Icon(Icons.person, color: Color(0xFFF06292)),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFF06292), // Deep pink for selected item
        unselectedItemColor: Colors.grey,
        backgroundColor: Color(0xFFF8E1E9), // Pastel pink background
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        onTap: _onItemTapped,
        elevation: 10,
      ),
    );
  }
}
