import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/AromaHomePage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/TableControlFile/TableControlPage.dart';


class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
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
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context).translate("SettingsPage.Settings"),style: TextStyle(color: HexColor("#f3f4f6")),),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: HexColor("#374151"),
              borderRadius: const BorderRadius.only(
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
                      'Hoqala Cafe',
                      style: TextStyle(
                        color: HexColor("#f3f4f6"),
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Personel Yönetim',
                      style: TextStyle(
                        color: HexColor("#f3f4f6"),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundImage: AssetImage('images/hoqala_icon.png'),
                  radius: 50,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Her satırda iki kart olacak
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemCount: 6, // Toplam kart sayısı
                itemBuilder: (context, index) {
                  return Card(
                    color: HexColor("#374151"),
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Kart tıklama işlemi
                        switch (index) {
                          case 0:{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AromaHomePage()));
                          }


                          case 1:{
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TableControlPage()));
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
        return CupertinoIcons.table_fill;
      case 2:
        return CupertinoIcons.chat_bubble_2_fill;
      case 3:
        return CupertinoIcons.settings_solid;
      case 4:
        return CupertinoIcons.play_arrow_solid;
      case 5:
        return CupertinoIcons.book_solid;
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
        return Colors.purple;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Stok Yönetimi';
      case 1:
        return 'Masa Yönetimi';
      case 2:
        return 'Chat';
      case 3:
        return 'Settings';
      case 4:
        return 'Videos';
      case 5:
        return 'Subjects';
      default:
        return 'Unknown';
    }
  }
}

