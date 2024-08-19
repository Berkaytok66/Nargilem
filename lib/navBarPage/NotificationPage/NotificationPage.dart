import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/Global/PusherClient.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'NotificationHelper.dart';
import 'NotificationModel.dart';
import 'package:http/http.dart' as http;

class NotiPage extends StatefulWidget {
  const NotiPage({super.key});

  @override
  State<NotiPage> createState() => _NotiPageState();
}

class _NotiPageState extends State<NotiPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<NotificationModel> notifications = [];
  List<int> originalIndices = []; // Bildirimlerin orijinal indexleri
  final PusherClientManager pusherClientManager = PusherClientManager();
  bool isLoading = true; // Ekran yüklendiğinde göstermek için

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _TokenClientManage();
    _loadNotifications();
  }

  Future<void> _TokenClientManage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token == null) {
      // Token bulunamadıysa hata yönetimi
      print("Token bulunamadı");
      return;
    }
    if (!pusherClientManager.isInitialized) {
      pusherClientManager.initialize(token, (eventData) {
        try {
          final parsedData = jsonDecode(eventData);

          // Önce parsedData'nın tipini kontrol edin
          if (parsedData is Map<String, dynamic>) {
            // Eğer parsedData bir Map ise burada işleyin
            if (parsedData.containsKey("data")) {
              final data = parsedData["data"];

              // data'nın tipini kontrol edelim
              if (data is List) {
                for (var item in data) {
                  if (item is Map<String, dynamic>) {
                    // item bir Map olduğunda containsKey çağrılabilir
                    if (item.containsKey("order_status")) {
                      // "order_status" anahtarını işleyin
                      if (item["order_status"] < 5) {
                        setState(() {
                          isLoading = true;
                        });
                        _loadNotifications(); // Bildirimleri tekrar yükleyin ve güncelleyin
                      }
                    } else {
                      print("Status: ${item["status"]}");
                    }
                  } else {
                    print("List içindeki öğe beklenmedik bir türde: ${item.runtimeType}");
                  }
                }
              } else {
                print("Data beklenmedik bir türde: ${data.runtimeType}");
              }
            } else {
              print("Status: ${parsedData["status"]}");
            }
          } else {
            print("Beklenmedik veri tipi: ${parsedData.runtimeType}");
          }
        } catch (e) {
          print("JSON parse hatası: $e");
        }
      });






    }else{
      // PusherClient zaten başlatılmışsa, sadece mevcut bağlantıyı kullanıyoruz
      pusherClientManager.connect();
    }

  }

  Future<void> _loadNotifications() async {

    List<NotificationModel> newNotifications = await NotificationHelper.getNotifications();
    if (mounted) {
      setState(() {
        // Yeni bildirimleri mevcut listeye ekleyin
        this.notifications = newNotifications; // Listeyi yeni bildirimlerle güncelleyiyoruz
        this.originalIndices = List<int>.generate(this.notifications.length, (i) => i).reversed.toList();
        isLoading = false; // Yükleme tamamlandı

        print("Notifications length: ${notifications.length}");
      });
    }
  }


  Future<void> _markAsRead(int index) async {
    int originalIndex = originalIndices[index];
    await NotificationHelper.markAsRead(originalIndex);
    if (mounted) {
      setState(() {
        notifications[index].isRead = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTimestamp(DateTime timestamp) {
    final String formattedDate = "${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}";
    final String formattedTime = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
    return "$formattedDate\n$formattedTime";
  }

  Future<void> sendNotification({String? tableUuid,String? urlApi}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final url = Uri.parse('${SabitD.URL}/$urlApi');
    final body = tableUuid != null ? {'table_uuid': tableUuid} : {'table_uuid': null};

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Token'ı burada kullanıyoruz
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      // İstek başarılı
      print('Bildirim gönderildi.');
    } else {
      // İstek başarısız
      print('Bildirim gönderilemedi. Hata: ${response.body}');
    }
  }
  void showBlendDetails(BuildContext context,String tableName,String uuid,String text,String titleText,String url) {
    showModalBottomSheet(
      backgroundColor: HexColor("#f5f5f5"),
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(16.0),
                height: MediaQuery.of(context).size.height * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.black, size: 22),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                         Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(titleText, style: TextStyle(fontSize: 18, color: Colors.black)),
                        ),
                        const SizedBox(width: 48), // Geri butonu ile başlık arasındaki hizalamayı sağlamak için.
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: HexColor("#f8fafc"),
                          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                        ),
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Açıklama Metni
                            Text(
                              text,
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            SizedBox(height: 20),
                            // Diğer içeriği buraya ekleyebilirsiniz.
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Buton
                    ElevatedButton(
                      onPressed: () {
                        // Buton tıklandığında yapılacak işlemler
                        sendNotification(tableUuid: uuid,urlApi: url);
                        Navigator.of(context).pop();
                      },
                      child: Text("($tableName) Sadece Bu masaya Bildir",style: TextStyle(color: Colors.white),),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        backgroundColor: HexColor("#475569"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Buton tıklandığında yapılacak işlemler
                        sendNotification(urlApi: url);
                        Navigator.of(context).pop();
                      },
                      child: Text("Tüm Masalara Bildir",style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        backgroundColor: HexColor("#94a3b8"),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        automaticallyImplyLeading: false,
        title: Text(
          "Bildirim Geçmişi",
          style: TextStyle(color: HexColor("#f3f4f6")),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Yükleme göstergesi
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Column(
            children: [
              InkWell(
                onTap: () => {
                  _markAsRead(index),
                  print("----------------------${notification.body.length}"),
                  if (notification.body.length == 31) {
                    showBlendDetails(context, notification.title, notification.uuid,
                    "Müşteriye közlerin hazırlandığı ve yola çıktığı hakkında bilgi vermek ister misiniz? Bildirimleri tüm masalara aynı anda gönderebilir veya sadece ilgili masaya özel bildirim yapabilirsiniz. Tercihinize göre, müşterilerinizi bilgilendirmek için en uygun yöntemi seçebilirsiniz.",
                     "Köz isteği",
                      "api/terminal/personal/other/deal-ember"
                    )
                  }else if (notification.body.length == 25){
                    showBlendDetails(context, notification.title, notification.uuid,
                        "Müşteriye masaya en kısa sürede geleceğinizi bildirin.",
                        "Personel İsteği",
                        "api/terminal/personal/other/employee-coming"
                    )
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FaIcon(FontAwesomeIcons.bell, size: 25, color: HexColor("#ca8a04")),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.title, style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(notification.body),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_formatTimestamp(notification.timestamp), style: TextStyle(fontSize: 12)),
                          if (!notification.isRead)
                            Icon(Icons.circle, color: Colors.green, size: 12),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(), // Her bildirimin altına bir ayırıcı ekler
            ],
          );
        },
      ),
    );
  }

}
