import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/Global/ToastHelper.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/MixBrandPageFile/TobaccoBlendsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AddBrandToTheMix extends StatefulWidget {
  final String name; // Önceki sayfadan alınan name

  const AddBrandToTheMix({super.key, required this.name});

  @override
  State<AddBrandToTheMix> createState() => _AddBrandToTheMixState();
}

class _AddBrandToTheMixState extends State<AddBrandToTheMix> {
  List<dynamic> brands = [];
  List<dynamic> filteredBrands = [];
  bool isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBrands();
    _searchController.addListener(_filterBrands);
  }

  Future<void> _fetchBrands() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/brand/get'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        brands = responseData['data'];
        filteredBrands = brands;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ToastHelper.showToast(
        message: "Markaları getirirken hata oluştu ${response.statusCode}",
        backgroundColor: HexColor("#dc2626"),
        gravity: ToastGravity.TOP,
      );
    }
  }

  void _filterBrands() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      filteredBrands = brands.where((brand) {
        return brand['name'].toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  Future<void> _addBlend(int tobaccoBrandId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': widget.name, 'tobacco_brand_id': tobaccoBrandId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TobaccoBlendsPage(),
          ),
        );
      });
    } else {
      ToastHelper.showToast(
        message: "Admin İle İletişime Geçin ${response.statusCode}",
        backgroundColor: HexColor("#dc2626"),
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to add blend');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        title: Text('Marka Ekle', style: TextStyle(color: HexColor("#f3f4f6"))),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: HexColor("#374151"),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(-30.0),
              ),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Eklenilecek Karışımın Markasını seçerek devam edin',
                  style: TextStyle(
                    color: HexColor("#f3f4f6"),
                    fontSize: 16,
                  ),
                  softWrap: true,
                  maxLines: 2,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Marka Ara',
                    hintStyle: TextStyle(color: HexColor("#f3f4f6")),
                    fillColor: HexColor("#1F2937"),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.search, color: HexColor("#f3f4f6")),
                  ),
                  style: TextStyle(color: HexColor("#f3f4f6")),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: filteredBrands.length,
              itemBuilder: (context, index) {
                final brand = filteredBrands[index];
                return ListTile(
                  title: Text(brand['name']),
                  onTap: () {
                    _addBlend(brand['id']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
