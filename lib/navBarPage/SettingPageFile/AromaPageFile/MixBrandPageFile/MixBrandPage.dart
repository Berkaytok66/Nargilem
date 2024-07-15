import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/Global/ToastHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MixBrandPage extends StatefulWidget {
  const MixBrandPage({super.key});

  @override
  State<MixBrandPage> createState() => _MixBrandPageState();
}

class _MixBrandPageState extends State<MixBrandPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _controllerBrandAdd = TextEditingController();
  final TextEditingController _controllerBrandUpdate = TextEditingController();
  List<dynamic> brands = []; // Gelen veriyi tutmak için bir liste

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchBrands(); // Veriyi almak için metodu çağır
  }

  // Tüm Kayıtları Listeler.
  Future<void> _fetchBrands() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/brand/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          brands = responseData['data'];
        });
      } else {
        print("Error: ${responseData['message']}");
      }
    } else {
      print("Failed to load brands. Status code: ${response.statusCode}");
    }
  }

  // Yeni marka eklemek için metod
  Future<void> _addBrand(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/brand/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        final newBrand = responseData['data'];
        setState(() {
          brands.add(newBrand);
        });
        _controllerBrandAdd.clear();
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to add brand');

      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.red,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to add brand');
    }
  }

  // Kayıt silmek için metod
  Future<void> _deleteBrand(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/brand/destroy/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          brands.removeWhere((brand) => brand['id'] == id);
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: responseData['message']",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );

        throw Exception('Failed to delete brand');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to delete brand');
    }
  }

  // Kayıt güncellemek için metod
  Future<void> _updateBrand(int id, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/brand/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        final updatedBrand = responseData['data'];
        setState(() {
          final index = brands.indexWhere((brand) => brand['id'] == id);
          if (index != -1) {
            brands[index] = updatedBrand;
            ToastHelper.showToast(
              message: "Başarılı",
              backgroundColor: Colors.green,
              gravity: ToastGravity.TOP,
            );
          }
        });
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to update brand');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to update brand');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerBrandAdd.dispose();
    _controllerBrandUpdate.dispose();
    super.dispose();
  }
  void _handleSubmitted(String value) {
    // Enter tuşuna basıldığında yapılacak işlemler buraya yazılır

    if (_controllerBrandAdd.text.isNotEmpty) {
      _addBrand(_controllerBrandAdd.text).then((_) {
        setState(() {});
      });

      _controllerBrandAdd.clear(); // text field temizler
    }

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
        title: const Text("Marka Ekle", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: HexColor("#374151"),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.0),
                bottomRight: Radius.circular(30.0),
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Card(
                    child: TextField(
                      controller: _controllerBrandAdd,
                      decoration: InputDecoration(
                        prefixIcon: Icon(CupertinoIcons.arrow_right),
                        suffixIcon: GestureDetector(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(CupertinoIcons.add_circled_solid),
                          ),
                          onTap: () {
                            if (_controllerBrandAdd.text.isNotEmpty) {
                              _addBrand(_controllerBrandAdd.text).then((_) {
                                setState(() {});
                              });

                              _controllerBrandAdd.clear(); // text field temizler
                            }
                          },
                        ),
                        hintText: 'Örn. Adalya',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.none,
                      onSubmitted: _handleSubmitted,
                    ),
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
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
                        child: Text("Ekli Markalar"),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.black,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: brands.length,
                      itemBuilder: (context, index) {
                        final brand = brands[index];

                        return GestureDetector(
                          onTap: () {
                            _controllerBrandUpdate.text = brand['name'];
                            showModalBottomSheet(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                              ),
                              isScrollControlled: true,
                              builder: (BuildContext context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(context).viewInsets.bottom,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.all(16.0),
                                    height: MediaQuery.of(context).size.height * 0.4,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        const SizedBox(height: 10),
                                        Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${brand['name']} isimli markayı güncelle',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.0),
                                        Divider(),
                                        SizedBox(height: 16.0),
                                        TextField(
                                          controller: _controllerBrandUpdate,
                                          decoration: const InputDecoration(
                                            labelText: 'Yeni Marka ismini girin',
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                        SizedBox(height: 16.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_controllerBrandUpdate.text.isNotEmpty) {
                                              _updateBrand(brand['id'], _controllerBrandUpdate.text).then((_) {
                                                setState(() {});
                                              });
                                              _controllerBrandUpdate.text = "";
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: Text('Güncelle', style: TextStyle(color: HexColor("#f1f5f9"))),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: HexColor("#16a34a"), // Arka plan rengi
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0), // Dikdörtgen yapmak için
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('İptal Et', style: TextStyle(color: HexColor("#f1f5f9"))),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: HexColor("#ef4444"), // Arka plan rengi
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(0), // Dikdörtgen yapmak için
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
                          child: Card(
                            color: HexColor("#374151"),
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(brand['name'], style: TextStyle(color: HexColor("#f3f4f6"))),
                                  IconButton(
                                    color: HexColor("#f3f4f6"),
                                    onPressed: () {
                                      AwesomeDialog(
                                        context: context,
                                        dialogType: DialogType.noHeader,
                                        animType: AnimType.bottomSlide,
                                        title: 'Dikkat',
                                        desc: 'Bu markayı silmek istediğinizden emin misiniz?',
                                        btnCancelOnPress: () {},
                                        btnOkOnPress: () {
                                          _deleteBrand(brand['id']).then((_) {
                                            setState(() {});
                                          });
                                        },
                                      ).show();
                                    },
                                    icon: Icon(CupertinoIcons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
