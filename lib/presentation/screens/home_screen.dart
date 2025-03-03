import 'package:attendance_management/core/utils/attandance_utils.dart';
import 'package:attendance_management/core/utils/homescreen_utils.dart';
import 'package:attendance_management/presentation/screens/add_employee.dart';
import 'package:attendance_management/presentation/screens/attandance_screen.dart';
import 'package:attendance_management/presentation/screens/manage_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AttendanceScreen(),
    ManageScreen(),
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
        title: Text('Attendance Manager'),
        actions: [
          IconButton(
              icon: Icon(Icons.info_outline, size: 20), onPressed: () => HomeScreenUtils.showInfoDialog(context)),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt_outlined),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Manage',
          ),
        ],
      ),
    );
  }
}
