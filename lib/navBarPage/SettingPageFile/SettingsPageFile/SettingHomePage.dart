import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'package:nargilem/navBarPage/SettingPageFile/SettingsPageFile/AboutUsPageFile/AboutUsPage.dart';
import 'package:nargilem/navBarPage/SettingPageFile/SettingsPageFile/NotificationSettingsFile/NotificationSettingsPage.dart';

class SettingHomePage extends StatefulWidget {
  const SettingHomePage({super.key});

  @override
  State<SettingHomePage> createState() => _SettingHomePageState();
}

class _SettingHomePageState extends State<SettingHomePage> with SingleTickerProviderStateMixin {
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

  void _onMenuTap(String menuName) {
    // Burada menü öğesine tıklanınca yapılacak işlemleri belirleyebilirsiniz.
    // Örneğin, ilgili ayarlar sayfasına yönlendirme yapabilirsiniz.

    switch (menuName) {
      //case 'Dil' :
      //  //Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
      //  print('$menuName tıklandı');
      //  break;
      //case 'Tema' :
      //  print('$menuName tıklandı');
      //  break;
      case 'Bildirim':
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationSettingsPage()));
        break;
      case 'Hakkımızda' :
        print('$menuName tıklandı');
        Navigator.push(context, MaterialPageRoute(builder: (context) => AboutUsPage()));
        break;
    }
  }

  Widget _buildMenuItem(IconData icon, String text, IconData trailingIcon, String menuName) {
    return InkWell(
      onTap: () => _onMenuTap(menuName),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: HexColor("#6b7280")),
                SizedBox(width: 16.0),
                Text(
                  text,
                  style: TextStyle(
                    color: HexColor("#6b7280"),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Icon(trailingIcon, color: HexColor("#6b7280")),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
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
                bottomRight: Radius.circular(0.0),
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
                      'Uygulama Ayarları',
                      style: TextStyle(
                        color: HexColor("#f3f4f6"),
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 4.0),
                    Text(
                      'Uygulama içi ayarları buradan yapabilirsiniz.',
                      style: TextStyle(
                        color: HexColor("#f3f4f6"),
                        fontSize: 16,
                      ),

                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height:24.0),
         // _buildMenuItem(Icons.language, 'Dil Ayarları', Icons.arrow_forward_ios, 'Dil'),
         // Divider(),
         // _buildMenuItem(Icons.palette, 'Tema Ayarları', Icons.arrow_forward_ios, 'Tema'),
       //   Divider(),
          _buildMenuItem(Icons.notifications, 'Bildirim Ayarları', Icons.arrow_forward_ios, 'Bildirim'),
       //   Divider(),
        //  _buildMenuItem(Icons.lock, 'Güvenlik Ayarları', Icons.arrow_forward_ios, 'Güvenlik'),
          Divider(),
          _buildMenuItem(Icons.info, 'Hakkımızda', Icons.arrow_forward_ios, 'Hakkımızda'),
        ],
      ),
    );
  }
}
