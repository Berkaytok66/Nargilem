import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/Global/ToastHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryManagementPage extends StatefulWidget {
  final int blendId;
  final String blendName;

  const CategoryManagementPage({required this.blendId, required this.blendName, Key? key}) : super(key: key);

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<String> CatagoryList = <String>[];
  String selectedCategory = '';
  List<dynamic> blendCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _fetchBlendCategory(widget.blendId);
  }

  Future<void> _fetchCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/menu/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List categories = data['data'];
      setState(() {
        CatagoryList = categories.map((category) => category['label'].toString()).toList();
        if (CatagoryList.isNotEmpty) {
          selectedCategory = CatagoryList.first;
        }
      });
    } else {
      ToastHelper.showToast(
        message: "Admin İle İletişime Geçin ${response.statusCode}",
        backgroundColor: HexColor("#dc2626"),
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to load categories');
    }
  }

  Future<void> _fetchBlendCategory(int blendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/show/$blendId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      setState(() {
        blendCategories = data['menu_categories'];
      });
    } else {
      ToastHelper.showToast(
        message: "Admin İle İletişime Geçin ${response.statusCode}",
        backgroundColor: HexColor("#dc2626"),
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to load blend category');
    }
  }

  Future<void> _addBlendToCategory(int blendId, int categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/category/attach/$blendId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'category_id': categoryId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result_type'] == 'success') {
        _fetchBlendCategory(blendId);
        ToastHelper.showToast(
          message: "Kategoriye başarıyla eklendi",
          backgroundColor: HexColor("#4ade80"),
          gravity: ToastGravity.TOP,
        );
      }
    } else {
      ToastHelper.showToast(
        message: "Admin İle İletişime Geçin ${response.statusCode}",
        backgroundColor: HexColor("#dc2626"),
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to add blend to category');
    }
  }

  Future<void> _removeBlendFromCategory(int blendId, int categoryId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/category/detach/$blendId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'category_id': categoryId}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['result_type'] == 'success') {
        setState(() {
          blendCategories = blendCategories.where((category) => category['id'] != categoryId).toList();
        });
        ToastHelper.showToast(
          message: "Kategoriden başarıyla kaldırıldı",
          backgroundColor: HexColor("#4ade80"),
          gravity: ToastGravity.TOP,
        );
      }
    } else {
      ToastHelper.showToast(
        message: "Admin İle İletişime Geçin ${response.statusCode}",
        backgroundColor: HexColor("#dc2626"),
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to remove blend from category');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        title: const Text("Kategori Yönetimi", style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.blendName} için Kategori Yönetimi',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10.0),
            customTextWidget("Ekli Olduğu Kategori",18,HexColor("#334155")),
            Text(
              blendCategories.isNotEmpty
                  ? '${blendCategories.map((category) => category['label']).join(', ')}'
                  : 'Kategori yok',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20.0),
            if (blendCategories.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  final categoryId = blendCategories[0]['id'];
                  _removeBlendFromCategory(widget.blendId, categoryId);
                },
                child: Text(
                  'Kategoriden Kaldır',
                  style: TextStyle(color: HexColor("#f1f5f9")),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#ef4444"),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
              ),
            const SizedBox(height: 20.0),
            customTextWidget("Yeni Kategori Ekle",18,HexColor("#334155")),
            const SizedBox(height: 20.0),
            Card(
              color: HexColor("#e2e8f0"), // Kartın arka plan rengi
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: SizedBox.shrink(),
                    alignment: Alignment.center,
                    value: selectedCategory,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue!;
                      });
                    },
                    items: CatagoryList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedCategory.isNotEmpty) {
                  final categoryId = CatagoryList.indexOf(selectedCategory) + 1;
                  _addBlendToCategory(widget.blendId, categoryId);
                }
              },
              child: Text(
                'Ekle',
                style: TextStyle(color: HexColor("#f1f5f9")),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor("#16a34a"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget customTextWidget(String text, double fontSize, Color color) {
    return Padding(
      padding: EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(text, style: TextStyle(color: color, fontSize: fontSize)),
          ),
          const Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }
}
