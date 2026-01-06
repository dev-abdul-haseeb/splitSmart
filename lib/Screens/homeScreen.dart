import 'package:flutter/material.dart' hide Divider;
import 'package:split_smart/Screens/groupsScreen.dart';
import 'package:split_smart/Screens/statsScreen.dart';
import 'package:split_smart/Screens/userSettingsScreen.dart';
import 'package:split_smart/Widgets/TextStyles.dart';
import 'package:split_smart/Widgets/colors.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});
  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    groupsScreen(),
    statsScreen(),
    userSettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Background(context),
      appBar: AppBar(
        backgroundColor: Primary(context),
        title: Text(
          'SplitSmart',
          style: appBarText(screenHeight, context),
        ),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: DividerColor(context),
        selectedItemColor: Primary(context),
        unselectedItemColor: Accent(context),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
