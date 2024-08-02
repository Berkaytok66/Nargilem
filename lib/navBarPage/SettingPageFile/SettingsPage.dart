import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/AromaHomePage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/SettingsPageFile/SettingHomePage.dart';
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
        title: Text(
          AppLocalizations.of(context).translate("SettingsPage.Settings"),
          style: TextStyle(color: HexColor("#f3f4f6")),
        ),
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
                      'En Class',
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
                itemCount: 3, // Toplam kart sayısı
                itemBuilder: (context, index) {
                  return Card(
                    color: HexColor("#374151"),
                    elevation: 15,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: InkWell(
                      onTap: () {
                        // Kart tıklama işlemi
                        switch (index) {
                          case 0:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AromaHomePage()));
                            break;
                          case 1:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TableControlPage()));
                            break;
                          case 2:
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SettingHomePage()));
                            break;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(3.0), // Padding ekleniyor
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Image.asset(
                                _getImageForIndex(index),
                                fit: BoxFit.cover,
                              ),
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

  String _getImageForIndex(int index) {
    switch (index) {
      case 0:
        return 'images/settings/stock_management.png';
      case 1:
        return 'images/settings/table_management.png';
      case 2:
        return 'images/settings/settings.png';
      default:
        return 'images/unknown.png';
    }
  }

  String _getTextForIndex(int index) {
    switch (index) {
      case 0:
        return 'Stok Yönetimi';
      case 1:
        return 'Masa Yönetimi';
      case 2:
        return 'Settings';
      default:
        return 'Unknown';
    }
  }
}
