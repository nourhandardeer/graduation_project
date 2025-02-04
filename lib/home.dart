import 'package:flutter/material.dart';
import 'package:graduation_project/NavigationBar/home_page.dart';
import 'package:graduation_project/NavigationBar/manage_page.dart';
import 'package:graduation_project/NavigationBar/medications_page.dart';
import 'package:graduation_project/NavigationBar/refills_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Tracks the selected tab

  // List of widgets for the bottom navigation tabs
  final List<Widget> _pages = [
    const HomePage(),
    const RefillsPage(),
    const MedicationsPage() ,
    const ManagePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.account_circle, size: 40),
          onPressed: () {
            // Handle profile button action
          },
        ),
        title: const Text('username', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // Handle notifications action
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Handle add action
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Dynamically changes body content
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_mode),
            label: 'Refills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication_liquid_outlined),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'Manage',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}


