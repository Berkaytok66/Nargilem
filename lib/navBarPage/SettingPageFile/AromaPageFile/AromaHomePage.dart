import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/MixBrandPageFile/TobaccoBlendsPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/TobaccoManagementFile/AromaPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/TobaccoManagementFile/AromaPageType.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/TobaccoManagementFile/TobaccoManagementPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/MixBrandPageFile/MixBrandPage.dart';


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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
     //  automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        title: Text('Stok Yönetimi',style: TextStyle(color: HexColor("#f3f4f6")),),
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Her satırda iki kart olacak
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
                          case 0:{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AromaPageType()));
                          }
                          case 1:{
                            Navigator.push(context, MaterialPageRoute(builder: (context)=> AromaPage()));
                          }
                          case 2:{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TobaccoManagementPage()));
                          }
                          case 3:{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MixBrandPage()));
                          }
                          case 4:{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TobaccoBlendsPage()));
                          }
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
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
                                color: HexColor("#f3f4f6")
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
        return CupertinoIcons.arrow_3_trianglepath;
      case 1:
        return CupertinoIcons.arrow_swap;
      case 2:
        return CupertinoIcons.ant;
      case 3:
        return CupertinoIcons.alt;
      case 4:
        return CupertinoIcons.app_badge;
      default:
        return CupertinoIcons.question_circle;
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
        return 'Aroma Type';
      case 1:
        return 'Aroma Yönetici';
      case 2:
        return 'Tütün Yönetici';
      case 3:
        return 'Karışm Markası';
      case 4:
        return 'Tütün Karışımları';
      default:
        return 'Unknown';
    }
  }
}
