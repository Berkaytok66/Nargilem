import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/Global/PusherClient.dart';
import 'package:nargilem/navBarPage/HomePage/HomePage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/SettingsPage.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TablesPage.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _pageIndex = 0;
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  final List<Widget> _pages = [
    const HomePage(),
    const TablesPage(),
    const SettingsPage(),

  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        index: 0,
        height: 60.0,
        items: const <Widget>[
          Icon(CupertinoIcons.news_solid, size: 30, color: Colors.white),
          Icon(CupertinoIcons.circle_grid_3x3_fill, size: 30, color: Colors.white),
          Icon(CupertinoIcons.settings, size: 30, color: Colors.white,),
        ],
        color: HexColor("#334155"),
        buttonBackgroundColor: HexColor("#334155"), // Button bacgrount color
        backgroundColor: HexColor("#fafaf9"), // bacgrount color
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
        letIndexChange: (index) => true,
      ),
      body: _pages[_pageIndex],
    );
  }
}
