import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool switchValue1 = true;
  bool switchValue2 = true;
  bool switchValue3 = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      switchValue1 = prefs.getBool('all_notifications') ?? true;
      switchValue2 = prefs.getBool('order_updates') ?? true;
      switchValue3 = prefs.getBool('emberPage_updates') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('all_notifications', switchValue1);
    prefs.setBool('order_updates', switchValue2);
    prefs.setBool('emberPage_updates', switchValue3);
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
                if (!switchValue1) {
                  switchValue2 = false;
                  switchValue3 = false;
                }
                _saveSettings();
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
                if (switchValue1) {
                  switchValue2 = value!;
                }
                _saveSettings();
              });
            },
            title: const Text('Spariş Durum Güncelleme'),
            subtitle: const Text(
                "Personeller tarafından güncellenen içeriklerin bildirimlerini açabilir ve ya kapatabilirsiniz."),
          ),
          const Divider(height: 0),
          SwitchListTile(
            value: switchValue3,
            onChanged: (bool? value) {
              setState(() {
                if (switchValue1) {
                  switchValue3 = value!;
                }
                _saveSettings();
              });
            },
            title: const Text('Köz Bildirimlerini Göster'),
            subtitle: const Text(
                "Müşteriler tarafından gelen istekler bildirim olarak iletilir. Kapatılması durumunda bu istekler mesajlar listesine düşer, ancak bildirim alamazsınız."),
          ),
        ],
      ),
    );
  }
}
