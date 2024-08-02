import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/AppLocalizations/AppLocalizations.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TableClass/OrderDetailsScreen.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TablesPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TablesViewInfo extends StatelessWidget {
  final String uuid;
  final String tableNumber;

  const TablesViewInfo({super.key, required this.uuid, required this.tableNumber});

  Future<void> closeSession(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/table/close-session/$uuid'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result_type'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
     //   Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TablesPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${AppLocalizations.of(context).translate("TablesViewInfo.Error")}: ${data['message']}')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).translate("TablesViewInfo.Failed_to_close_session"))));
    }
  }

  Future<Map<String, dynamic>> fetchTableDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/table/show-detail/$uuid'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['result_type'] == 'success') {
        return data['data'];
      } else {
        throw Exception('Failed to load details');
      }
    } else {
      throw Exception('Failed to load details');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        title: Text(AppLocalizations.of(context).translate("TablesViewInfo.Table_Details"), style: TextStyle(color: HexColor("#f3f4f6"))),
        leading: IconButton(
          icon:FaIcon(FontAwesomeIcons.arrowLeft,color:HexColor("#f3f4f6"),),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchTableDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('${AppLocalizations.of(context).translate("TablesViewInfo.Error")} : ${snapshot.error}'));
          } else {
            final tableDetails = snapshot.data!;
            final activeSession = tableDetails['active_session'];
            final customers = tableDetails['customers'];
            final orders = tableDetails['orders'];

            final orderIds = orders.map<int>((order) => order['id'] as int).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).translate("TablesViewInfo.Table")}: $tableNumber',
                              style: TextStyle(
                                color: HexColor("#f3f4f6"),
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 15,),
                            Row(
                              children: [
                                const FaIcon(FontAwesomeIcons.clock,color: Colors.white,),
                                SizedBox(width:10),
                                Text(
                                '${activeSession != null ? activeSession['start_time'] : 'Yok'}',
                                  style: TextStyle(
                                    color: HexColor("#f3f4f6"),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            const Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(AppLocalizations.of(context).translate("TablesViewInfo.Orders")),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        // Siparişleri çift sütun olarak göstermek için grid yapı kullanıyoruz.
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1, // Kartların kare olması için
                          ),
                          itemCount: orderIds.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SingleOrderDetailScreen(orderId: orderIds[index])),
                              ),
                              child: Card(
                                color: HexColor("#1f2937"),
                                elevation: 20,
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Image.asset(
                                        'images/table_view_info_image.png', // Default image path
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        color: Colors.black54,
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        child: Text(
                                          '${AppLocalizations.of(context).translate("TablesViewInfo.Order_ID")}: ${orderIds[index]}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                         Row(
                          children: <Widget>[
                            const Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(AppLocalizations.of(context).translate("TablesViewInfo.Customers")),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Colors.black,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...customers.map<Widget>((customer) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: const FaIcon(FontAwesomeIcons.person),
                            title: Text('ID: ${customer['id']}'),
                            subtitle: Text('${AppLocalizations.of(context).translate("TablesViewInfo.Last_Visit")}: ${customer['last_visit']}'),
                          ),
                        )).toList(),

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
            ]
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: (){
                    closeSession(context);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width/1.09,

                    padding: EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                        color: HexColor("#6b7280"),
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: Center(
                      child: Text(
                          AppLocalizations.of(context).translate("TablesViewInfo.Close_Session"),style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
