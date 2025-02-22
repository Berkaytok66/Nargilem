import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'package:nargilem/Global/PusherClient.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/navBarPage/HomePage/HomeClass/ApiService.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TableClass/OrderDetailsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _enabledPersonController = false;
  bool _enabledAdminController = false;
  bool _personalController = false;
  List<dynamic> _orders = [];
  int? _expandedOrderId;
  String _selectedStatus = '1'; // Başlangıçta "Beklemede" durumu seçili
  final PusherClientManager pusherClientManager = PusherClientManager();

  final List<Map<String, String>> _statusOptions = [
    {'value': '1', 'label': 'Beklemede'},
    {'value': '2', 'label': 'Hazırlanıyor'},
    {'value': '3', 'label': 'Teslim Edildi'},
    {'value': '4', 'label': 'İptal Edildi'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _Pref();
    _fetchOrders(_selectedStatus);

    _TokenClientManage();
  }

  Future<void> _TokenClientManage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      // Token bulunamadıysa hata yönetimi
      print("Token bulunamadı");
      return;
    }

    // PusherClientManager'ı sadece ilk başlatmada initialize ediyoruz
    if (!pusherClientManager.isInitialized) {
      pusherClientManager.initialize(token, (eventData) {
        // Gelen veriyi parse ediyoruz
        try {
          final parsedData = jsonDecode(eventData);

          // Parse edilmiş veriyi loga yazıyoruz
          print("Parsed Data: $parsedData");

          // "order_status" anahtarını kontrol ediyoruz
          if (parsedData.containsKey('data') && parsedData['data'].containsKey('order_status')) {
            if (parsedData['data']['order_status'] < 5) {
              if (mounted) {
                setState(() {
                  _fetchOrders(_selectedStatus); // Sipariş listesini güncelle
                });
              }
            }
          }
        } catch (e) {
          // JSON parse hatası varsa hata mesajı
          print("JSON parse hatası: $e");
        }
      });
    } else {
      // PusherClient zaten başlatılmışsa, sadece mevcut bağlantıyı kullanıyoruz
      pusherClientManager.connect();
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _Pref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabledPersonController = prefs.getBool('is_employee') ?? false;
      _enabledAdminController = prefs.getBool('is_admin') ?? false;
      if (_enabledPersonController || _enabledAdminController) {
        _personalController = true;
      } else {
        _personalController = false;
      }
    });
  }

  Future<void> _fetchOrders(String status) async {
    try {
      final orders = await ApiService().fetchOrders(int.parse(status));
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _updateOrderStatus(int id, String status) async {
    try {
      await ApiService().updateOrderStatus(id, status);
      _fetchOrders(_selectedStatus); // Durum güncellendikten sonra sipariş listesini yeniden yükleyin
    } catch (e) {
      print(e);
    }
  }

  void approveOrder(int orderId) {
    _updateOrderStatus(orderId, "2"); // Hazırlanıyor durumu
  }

  void cancelOrder(int orderId) {
    _updateOrderStatus(orderId, "4"); // İptal Edildi durumu
  }

  void pendingOrder(int orderId) {
    _updateOrderStatus(orderId, "1"); // Beklemede durumu
  }

  void wasDeliveredOrder(int orderId) {
    _updateOrderStatus(orderId, "3"); // Teslim Edildi
  }
  String _formatTime(String dateTime) {
    // Datetime stringini parse ediyoruz
    DateTime parsedDateTime = DateTime.parse(dateTime);
    // Saat ve dakikayı almak için DateFormat kullanıyoruz
    DateFormat formatter = DateFormat('HH:mm');
    return formatter.format(parsedDateTime);
  }
  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        automaticallyImplyLeading: false,

        title: Text(AppLocalizations.of(context).translate("HomePage.Orders"),style: TextStyle(color: HexColor("#f3f4f6")),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: DropdownButton2(
              isExpanded: true,
              value: _selectedStatus,
              items: _statusOptions
                  .map((status) => DropdownMenuItem<String>(
                value: status['value'],
                child: Text(status['label']!),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  _fetchOrders(_selectedStatus);
                });
              },
            ),
          ),
          Expanded(
            child: _orders.isEmpty
                ? Center(
                child: Text(AppLocalizations.of(context)
                    .translate("HomePage.No_order")))
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  children: _orders.map((order) {
                    bool isExpanded = _expandedOrderId == order['id'];
                    String formattedTime = _formatTime(order['created_at']);
                    final orderStatus = _statusOptions.firstWhere(
                          (status) =>
                      status['value'] == order['status'],
                      orElse: () => {
                        'value': 'unknown',
                        'label': 'Bilinmiyor'
                      },
                    );
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _expandedOrderId = isExpanded
                              ? null
                              : order['id'];
                        });
                      },
                      child: Card(
                        color: HexColor("#374151"),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius:
                                    BorderRadius.circular(8.0),
                                    child: Image.asset(
                                      "images/home_dome_image.png",
                                      height: 80.0,
                                      width: 60.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${AppLocalizations.of(
                                              context)
                                              .translate(
                                              "HomePage.Order")} : ${order['id']}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: HexColor(
                                                  "#f5f5f5")),
                                        ),
                                        Text(
                                          "${order['table']['table_number']}",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight:
                                              FontWeight.bold,
                                              color: HexColor(
                                                  "#f5f5f5")),
                                        ),
                                        Row(
                                          children: [
                                            FaIcon(
                                                FontAwesomeIcons
                                                    .clock,
                                                color: HexColor(
                                                    "#e2e8f0"),
                                                size: 12),
                                            const SizedBox(
                                              width: 7,
                                            ),
                                            Text(
                                              "${formattedTime}",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: HexColor(
                                                      "#d4d4d4")),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // Dikeyde ortalamak için eklendi
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: HexColor("#e4e4e7"), // Arka plan rengi
                                          border: Border.all(
                                            color: HexColor("#27272a"), // Çerçeve rengi
                                            width: 2.0, // Çerçeve kalınlığı
                                          ),
                                          borderRadius: BorderRadius.circular(8.0), // Köşe yuvarlaklığı
                                        ),
                                        child: Center(
                                          child: IconButton(
                                            onPressed: () {
                                              // Butonun tıklanma olayı
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => SingleOrderDetailScreen(orderId: order['id'])),
                                              );
                                            },
                                            icon: FaIcon(FontAwesomeIcons.eye, color: HexColor("#475569"), size: 25),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isExpanded)
                                Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    const Divider(),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenSize.width * 0.35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              pendingOrder(order['id']);

                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.success,
                                                animType: AnimType.rightSlide,
                                                title: AppLocalizations.of(context).translate("HomePage.Order_Status"),
                                                desc: AppLocalizations.of(context).translate("HomePage.Order_Status_Updated_to_Pending"),
                                                btnOkOnPress: () {},
                                              ).show();
                                            },
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              HexColor(
                                                  "#a3a3a3"),
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .zero,
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                  context)
                                                  .translate(
                                                  "HomePage.On_hold"),
                                              style:
                                              const TextStyle(
                                                  color: Colors
                                                      .white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: screenSize.width *
                                              0.35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              approveOrder(
                                                  order['id']);
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType
                                                    .success,
                                                animType: AnimType
                                                    .rightSlide,
                                                title: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "HomePage.Order_Status"),
                                                desc: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "HomePage.Order_Status_Updated_to_Preparing"),
                                                btnOkOnPress: () {},
                                              ).show();
                                            },
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              HexColor(
                                                  "#fbbf24"),
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .zero,
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                  context)
                                                  .translate(
                                                  "HomePage.Preparing"),
                                              style:
                                              const TextStyle(
                                                  color: Colors
                                                      .white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: screenSize.width *
                                              0.35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              wasDeliveredOrder(
                                                  order['id']);
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType
                                                    .success,
                                                animType: AnimType
                                                    .rightSlide,
                                                title: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "HomePage.Order_Status"),
                                                desc: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "HomePage.Order_Status_Updated_As_Delivered"),
                                                btnOkOnPress: () {},
                                              ).show();
                                            },
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              Colors.green,
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .zero,
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                  context)
                                                  .translate(
                                                  "HomePage.Delivered"),
                                              style:
                                              const TextStyle(
                                                  color: Colors
                                                      .white),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          width: screenSize.width *
                                              0.35,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              cancelOrder(
                                                  order['id']);
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType
                                                    .success,
                                                animType: AnimType
                                                    .rightSlide,
                                                title: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "HomePage.Order_Status"),
                                                desc: AppLocalizations.of(
                                                    context)
                                                    .translate(
                                                    "HomePage.Order_Status_Updated_to_Canceled"),
                                                btnOkOnPress: () {},
                                              ).show();
                                            },
                                            style: ElevatedButton
                                                .styleFrom(
                                              backgroundColor:
                                              Colors.red,
                                              shape:
                                              const RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius
                                                    .zero,
                                              ),
                                            ),
                                            child: Text(
                                              AppLocalizations.of(
                                                  context)
                                                  .translate(
                                                  "HomePage.Cancel"),
                                              style:
                                              const TextStyle(
                                                  color: Colors
                                                      .white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
