import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../main.dart';
import 'subjects_screen.dart';
import 'quiz_screen.dart';
import 'progress_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _page = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _screens = [
    const HomePage(),
    const SubjectsScreen(),
    const QuizScreen(),
    const ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF3FB),
      body: _screens[_page],
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: const Color(0xFFEFF3FB),
        color: Colors.white,
        buttonBackgroundColor: Colors.indigo,
        height: 60,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.grey),
          Icon(Icons.menu_book, size: 30, color: Colors.grey),
          Icon(Icons.quiz, size: 30, color: Colors.grey),
          Icon(Icons.analytics, size: 30, color: Colors.grey),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }
}
