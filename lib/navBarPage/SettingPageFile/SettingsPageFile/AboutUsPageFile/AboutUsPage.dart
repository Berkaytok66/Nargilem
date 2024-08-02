import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with SingleTickerProviderStateMixin {
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
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        title: Text(
          "Hakkımızda",
          style: TextStyle(color: HexColor("#f3f4f6")),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ME BU Yazılım Bilişim Teknoloji Sanayi Ve Ticaret Limited Şirketi",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Kuruluş: 08.01.2024",
                style: TextStyle(
                  fontSize: 18,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Misyon ve Vizyon",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "ME BU olarak misyonumuz, müşteri ve kafeterya arasındaki sipariş ve iletişimi güncelleyerek daha verimli hale getirmektir. Vizyonumuz ise, dijital dönüşümü hızlandırarak sektörün öncü firmalarından biri olmaktır.",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Projemiz: NargileHup",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "NargileHup, kafeteryalar ve müşteriler için özel olarak geliştirilmiş bir yazılım projesidir. Bu proje sayesinde kafeteryalarda oturan müşteriler, QR kodlarını okutarak web sitemiz üzerinden verdikleri siparişleri doğrudan garsona iletebilirler. Ayrıca, müşteriler siparişlerinin durumunu anlık olarak takip edebilirler.",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Ürün ve Hizmetlerimiz",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "ME BU olarak, NargileHup projemiz ile kafeterya ve nargile sipariş hizmetlerini dijitalleştirerek, hem işletmelerin hem de müşterilerin deneyimini iyileştirmeyi hedefliyoruz.",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Hedef Kitlemiz",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Başlıca hedef kitlemiz, kafeteryalar ve bu kafeteryaların müşterileridir. Kafeterya sahiplerine sunduğumuz dijital çözümler ile işlerini daha kolay ve verimli hale getirmeyi amaçlıyoruz.",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "İletişim Bilgilerimiz",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "Daha fazla bilgi ve iş birlikleri için bizimle iletişime geçebilirsiniz:",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#1e293b"),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "E-posta: info@mebu.com.tr",
                style: TextStyle(
                  fontSize: 16,
                  color: HexColor("#1e293b"),
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
