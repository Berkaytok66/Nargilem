import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SingleOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const SingleOrderDetailScreen({super.key, required this.orderId});

  @override
  _SingleOrderDetailScreenState createState() => _SingleOrderDetailScreenState();
}

class _SingleOrderDetailScreenState extends State<SingleOrderDetailScreen> {
  late Future<Map<String, dynamic>> orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    orderDetailsFuture = fetchOrderDetails();
  }

  Future<Map<String, dynamic>> fetchOrderDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/order/show-detail/${widget.orderId}'),
      headers: {
        'Authorization': 'Bearer $token',
      },

    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result_type'] == 'success') {
        return data['data'];
      } else {
        throw Exception('Failed to load order details');
      }
    } else {
      throw Exception('Failed to load order details');
    }
  }

  Future<void> updateOrderStatus(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/order/status/${widget.orderId}/$status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result_type'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        setState(() {
          orderDetailsFuture = fetchOrderDetails();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update order status')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update order status')));
    }
  }

  String formatDateTime(String dateTime) {
    final DateTime parsedDateTime = DateTime.parse(dateTime);
    final DateFormat formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(parsedDateTime);
  }

  double getProgressValue(String ratio) {
    switch (double.parse(ratio)) {
      case 1.0:
        return 0.3;
      case 2.0:
        return 0.6;
      case 3.0:
        return 1.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        title: Text('Sipariş Detayları', style: TextStyle(color: HexColor("#f3f4f6"))),
        leading: IconButton(
          icon: FaIcon(FontAwesomeIcons.arrowLeft, color: HexColor("#f3f4f6")),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else {
            final orderDetails = snapshot.data!;
            final order = orderDetails['order'];
            final customBlend = orderDetails['custom_blend'] ?? [];
            final tobaccoBlend = orderDetails['tobacco_blend'];
            final orderExtras = orderDetails['order_extras'] ?? [];
            String Durum;
            Color DurumRenk;

            switch (order['status']) {
              case 1:
                Durum = "Beklemede";
                DurumRenk = Colors.orange;
                break;
              case 2:
                Durum = "Hazırlanıyor";
                DurumRenk = Colors.blue;
                break;
              case 3:
                Durum = "Teslim Edildi";
                DurumRenk = Colors.green;
                break;
              case 4:
                Durum = "İptal Edildi";
                DurumRenk = Colors.red;
                break;
              default:
                Durum = "Bilinmiyor";
                DurumRenk = Colors.grey;
                break;
            }

            bool isMixtureTitleController = false;
            if (tobaccoBlend != null) {
              isMixtureTitleController = true;
            }
            if (customBlend.isNotEmpty) {
              isMixtureTitleController = false;
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: HexColor("#374151"),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30.0),
                        bottomRight: Radius.circular(-30.0),
                      ),
                    ),
                    padding: EdgeInsets.all(26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sipariş ID: ${order['id']}',
                              style: TextStyle(
                                color: HexColor("#f3f4f6"),
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              '$Durum',
                              style: TextStyle(
                                color: DurumRenk,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          children: [
                            const FaIcon(FontAwesomeIcons.clock, color: Colors.white,),
                            const SizedBox(width: 10),
                            Text(
                              formatDateTime(order['created_at']),
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
                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                isMixtureTitleController ? "Hazır Karışım" : "Özel Karışım",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width, // Yatayda sabit genişlik
                          decoration: BoxDecoration(
                            color: HexColor("#f1f5f9"),
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(10.0), // Metni daha iyi göstermek için padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isMixtureTitleController)
                                Row(
                                  children: [
                                    FaIcon(FontAwesomeIcons.arrowRight, color: HexColor("#6b7280"),size: 10,),
                                    SizedBox(width: 8,),
                                    Text(
                                      '${tobaccoBlend['tobacco_name']} (${tobaccoBlend['brand_name']})',
                                      style: TextStyle(
                                        color: HexColor("#1e293b"),
                                        fontSize: 16,
                                      ),
                                      maxLines: null,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    for (var blend in customBlend)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${blend['tobacco_name']}',
                                              style: TextStyle(
                                                color: HexColor("#1e293b"),
                                                fontSize: 16,
                                              ),
                                              maxLines: null,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: getProgressValue(blend['ratio']),
                                              backgroundColor: Colors.grey[300],
                                              color: HexColor("#1e293b"),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("Extralar", style: TextStyle(fontSize: 18),),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width, // Yatayda sabit genişlik
                          decoration: BoxDecoration(
                            color: HexColor("#f1f5f9"),
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(10.0), // Metni daha iyi göstermek için padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (orderExtras.isNotEmpty) ...[
                                ...orderExtras.map<Widget>((extra) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          FaIcon(FontAwesomeIcons.arrowRight, color: HexColor("#6b7280"),size: 10,),
                                          SizedBox(width: 8,),
                                          Text('${extra['extra_name']} (${extra['extra_type_name']})', style: TextStyle(fontSize: 16)),
                                        ],
                                      ),
                                      Divider(),
                                    ],
                                  ),
                                )).toList(),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Row(
                          children: <Widget>[
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("Müşteri Notu", style: TextStyle(fontSize: 18),),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: MediaQuery.of(context).size.width, // Yatayda sabit genişlik
                          decoration: BoxDecoration(
                            color: HexColor("#f1f5f9"),
                            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                          ),
                          padding: const EdgeInsets.all(10.0), // Metni daha iyi göstermek için padding
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${order['note']}',
                                style: TextStyle(
                                  color: HexColor("#1e293b"),
                                  fontSize: 16,
                                ),
                                maxLines: null,
                                overflow: TextOverflow.visible,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(15),
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext context) {
                        int? selectedStatus;
                        return StatefulBuilder(
                          builder: (BuildContext context, StateSetter setState) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.4,
                              minChildSize: 0.2,
                              maxChildSize: 0.8,
                              builder: (BuildContext context, ScrollController scrollController) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Text(
                                          'Sipariş Durumunu Güncelle',
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: DropdownButtonFormField<int>(
                                          decoration: InputDecoration(
                                            labelText: 'Durum Seçin',
                                            border: OutlineInputBorder(),
                                          ),
                                          items: const [
                                            DropdownMenuItem(value: 1, child: Text('Beklemede')),
                                            DropdownMenuItem(value: 2, child: Text('Hazırlanıyor')),
                                            DropdownMenuItem(value: 3, child: Text('Teslim Edildi')),
                                            DropdownMenuItem(value: 4, child: Text('İptal Edildi')),
                                          ],
                                          onChanged: (int? value) {
                                            setState(() {
                                              selectedStatus = value;
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16,right: 16),
                                            child: Container(
                                              width: double.infinity, // Ekranın yatayda %100'ünü kaplar
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: HexColor("#ef4444"), // Butonun arka plan rengi
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.zero, // Köşeleri düz yapmak için
                                                  ),
                                                ),
                                                child: const Text('İptal',style: TextStyle(color: Colors.white),),
                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.only(left: 16,right: 16),
                                            child: Container(
                                              width: double.infinity, // Ekranın yatayda %100'ünü kaplar
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  if (selectedStatus != null) {
                                                    updateOrderStatus(selectedStatus!);
                                                    Navigator.of(context).pop();
                                                  }else{
                                                    QuickAlert.show(
                                                      context: context,
                                                      type: QuickAlertType.info,
                                                      title: "Oops..",
                                                      confirmBtnText: 'Geri',
                                                      text: 'Güncel Durumu Belirtmediniz!',
                                                    );
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: HexColor("#16a34a"), // Butonun arka plan rengi
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.zero, // Köşeleri düz yapmak için
                                                  ),
                                                ),
                                                child: const Text('Güncelle',style: TextStyle(color: Colors.white),),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.09,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                        color: HexColor("#6b7280"),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Center(
                      child: Text(
                        "Durum Güncelle", style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
