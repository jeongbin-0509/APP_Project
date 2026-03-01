import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'planner_screen.dart';
import 'stats_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  DateTime _selectedDate = DateTime.now();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _changeDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return HomeScreen(selectedDate: _selectedDate);
      case 1:
        return PlannerScreen(selectedDate: _selectedDate);
      case 2:
        return StatsScreen(selectedDate: _selectedDate);
      default:
        return PlannerScreen(selectedDate: _selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText =
        "${_selectedDate.year}.${_selectedDate.month}.${_selectedDate.day}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("성적설계"),
        actions: [
          TextButton(
            onPressed: _changeDate,
            child: Text(dateText, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _buildCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_calendar),
            label: "플래너",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "통계"),
        ],
      ),
    );
  }
}
