import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/MixBrandPageFile/TobaccoBlendsPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/TobaccoManagementFile/AromaPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/TobaccoManagementFile/AromaPageType.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/TobaccoManagementFile/TobaccoManagementPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/MixBrandPageFile/MixBrandPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/SettingsPage.dart';

class AromaHomePage extends StatefulWidget {
  const AromaHomePage({super.key});

  @override
  State<AromaHomePage> createState() => _AromaHomePageState();
}

class _AromaHomePageState extends State<AromaHomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Örneğin, 600 pikselden geniş ekranlar tablet olarak kabul edilir
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        //  automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        title: Text(
          'Stok Yönetimi',
          style: TextStyle(color: HexColor("#f3f4f6")),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // İkona tıklandığında yapılacak işlemler
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: HexColor("#374151"),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(-30.0),
              ),
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EnClass',
                      style: TextStyle(
                        color: HexColor("#f3f4f6"),
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Aroma Yönetim Paneli',
                      style: TextStyle(
                        color: HexColor("#f3f4f6"),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 5 : 2, // Tablet ise 5, değilse 2
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: 5, // Toplam kart sayısı
                itemBuilder: (context, index) {
                  return Card(
                    color: HexColor("#374151"),
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        switch (index) {
                          case 0:
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AromaPageType()));
                              break;
                            }
                          case 1:
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AromaPage()));
                              break;
                            }
                          case 2:
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TobaccoManagementPage()));
                              break;
                            }
                          case 3:
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => MixBrandPage()));
                              break;
                            }
                          case 4:
                            {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TobaccoBlendsPage()));
                              break;
                            }
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            _getIconForIndex(index),
                            size: 50,
                            color: _getColorForIndex(index),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _getTextForIndex(index),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: HexColor("#f3f4f6"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return FontAwesomeIcons.appleWhole;
      case 1:
        return FontAwesomeIcons.hurricane;
      case 2:
        return FontAwesomeIcons.leaf;
      case 3:
        return FontAwesomeIcons.thList;
      case 4:
        return FontAwesomeIcons.blender;
      default:
        return FontAwesomeIcons.question;
    }
  }

  Color _getColorForIndex(int index) {
    switch (index) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.pink;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Aroma Tipi';
      case 1:
        return 'Aroma Yönetici';
      case 2:
        return 'Tütün Yönetici';
      case 3:
        return 'Markalar';
      case 4:
        return 'Tütün Karışımları';
      default:
        return 'Unknown';
    }
  }
}
