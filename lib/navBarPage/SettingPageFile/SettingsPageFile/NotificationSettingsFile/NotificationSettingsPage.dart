import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool switchValue1 = true;
  bool switchValue2 = true;

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
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        title: Text(
          "Bildirim Ayarları",
          style: TextStyle(color: HexColor("#f3f4f6")),
        ),

      ),
      body: Column(
        children: <Widget>[
          SwitchListTile(
            value: switchValue1,
            onChanged: (bool? value) {
              setState(() {
                switchValue1 = value!;
              });
            },
            title: const Text('Tüm Bildirimler'),
            subtitle: const Text('Bu Seçeneği Kapatmanız durumunda hiçbir bildirim almayacaksınız.'),
          ),
          const Divider(height: 0),
          SwitchListTile(
            value: switchValue2,
            onChanged: (bool? value) {
              setState(() {
                switchValue2 = value!;
              });
            },
            title: const Text('Spariş Durum Güncelleme'),
            subtitle: const Text(
                "Personeller tarafından güncellenen içeriklerin bildirimlerini açabilir ve ya kapatabilirsiniz."),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
