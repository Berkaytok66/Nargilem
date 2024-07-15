import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'dart:convert';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TablesViewInfo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<RestaurantTableClass> tables = [];
  List<RestaurantTableClass> filteredTables = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    fetchTables();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Masaları getiren fonksiyon
  Future<void> fetchTables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/table/get'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result_type'] == 'success') {
        setState(() {
          tables = (data['data'] as List)
              .map((json) => RestaurantTableClass.fromJson(json))
              .toList();
          tables.sort((a, b) => b.isBusy.compareTo(a.isBusy)); // Dolu masaları listenin üstüne taşır
          filteredTables = tables;
        });
      } else {
        // Handle error
      }
    } else {
      // Handle error
    }
  }

  // Arama işlemi için filtreleme fonksiyonu
  void filterTables(String query) {
    final filtered = tables.where((table) {
      final tableNumber = table.tableNumber.toLowerCase();
      final input = query.toLowerCase();
      return tableNumber.contains(input);
    }).toList();

    setState(() {
      filteredTables = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        title: Text(AppLocalizations.of(context).translate("TablesPage.Tables"), style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate("TablesPage.Search"),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (query) => filterTables(query),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Her satırda kaç masa olacağı
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  return GestureDetector(
                    onTap: () {
                      table.isBusy == 0
                          ? AwesomeDialog(
                        context: context,
                        dialogType: DialogType.info,
                        animType: AnimType.rightSlide,
                        title: AppLocalizations.of(context).translate("TablesPage.TableInformation"),
                        desc:
                          AppLocalizations.of(context).translate("TablesPage.TableInformationDialog"),
                        btnOkOnPress: () {},
                      ).show()
                          : Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              TablesViewInfo(uuid: table.uuid,tableNumber:table.tableNumber ,),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: table.isBusy == 0
                            ? HexColor("#94a3b8")
                            : HexColor("#0891b2"),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.3,
                              child: Image.asset(
                                'images/home_dome_image.png', // Masa resmi için URL
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: EdgeInsets.all(4),
                              child: Text(
                                '${table.tableNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
}

class RestaurantTableClass {
  final String uuid;
  final String tableNumber;
  final int isBusy;

  RestaurantTableClass({
    required this.uuid,
    required this.tableNumber,
    required this.isBusy,
  });

  factory RestaurantTableClass.fromJson(Map<String, dynamic> json) {
    return RestaurantTableClass(
      uuid: json['uuid'],
      tableNumber: json['table_number'],
      isBusy: json['is_busy'],
    );
  }
}
