import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/navBarPage/HomePage/HomePage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/SettingsPage.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TablesPage.dart';
import 'package:nargilem/navBarPage/NotificationPage/NotificationPage.dart';
import 'package:hexcolor/hexcolor.dart';

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
    const NotiPage(),
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
          FaIcon(FontAwesomeIcons.bagShopping,size: 25,color:Colors.white),
          FaIcon(FontAwesomeIcons.bell,size: 25,color:Colors.white),
          FaIcon(FontAwesomeIcons.table,size: 25,color:Colors.white),
          FaIcon(FontAwesomeIcons.gear,size: 25,color:Colors.white),
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
