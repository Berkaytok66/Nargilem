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

class AromaPage extends StatefulWidget {
  const AromaPage({super.key});

  @override
  State<AromaPage> createState() => _AromaPageState();
}

class _AromaPageState extends State<AromaPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _controllerAromaAdd = TextEditingController();
  final TextEditingController _controllerAromaUpdate = TextEditingController();
  List<bool> _isExpanded = [];
  List<dynamic> flavours = []; // Gelen veriyi tutmak için bir liste
  Map<int, List<dynamic>> flavourTypes = {}; // Genişletilmiş veriyi tutmak için bir harita
  List<dynamic> availableFlavourTypes = []; // Mevcut aromaları tutmak için bir liste

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchFlavours(); // Veriyi almak için metodu çağır
    _fetchAvailableFlavourTypes(); // Mevcut aroma tiplerini almak için metodu çağır
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerAromaAdd.dispose();
    _controllerAromaUpdate.dispose();
    super.dispose();
  }

  // Tüm Kayıtları Listeler.
  Future<void> _fetchFlavours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        flavours = List<dynamic>.from(json.decode(response.body)['data']);
        _isExpanded = List<bool>.filled(flavours.length, false, growable: true);
      });
    } else {
      throw Exception('Failed to load flavours');
    }
  }

  // Mevcut aroma tiplerini almak için metod
  Future<void> _fetchAvailableFlavourTypes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour-type/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        availableFlavourTypes = List<dynamic>.from(json.decode(response.body)['data']);
      });
    } else {
      throw Exception('Failed to load available flavour types');
    }
  }

  // Belirli bir kaydın tiplerini almak için metod
  Future<void> _fetchFlavourTypes(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/type/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body)['data'];
      setState(() {
        if (responseData is List) {
          flavourTypes[id] = responseData;
        } else {
          flavourTypes[id] = [responseData];
        }
      });
    } else {
      throw Exception('Failed to load flavour types');
    }
  }

  // Belirli bir kaydın tipini silmek için metod
  Future<void> _deleteFlavourType(int flavourId, int typeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/type/$flavourId/detach'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'type_id': typeId}),
    );

    if (response.statusCode == 200) {
      setState(() {
        flavourTypes[flavourId] = flavourTypes[flavourId]!.where((type) => type['id'] != typeId).toList();
      });
      ToastHelper.showToast(
        message: "Başarılı",
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to delete flavour type');
    }
  }

  // Belirli bir kayda tip eklemek için metod
  Future<void> _addFlavourType(int flavourId, int typeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/type/$flavourId/attach'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'type_id': typeId}),
    );

    if (response.statusCode == 200) {
      final newFlavourType = json.decode(response.body)['data'];
      setState(() {
        flavourTypes[flavourId]!.add(newFlavourType);
      });
      ToastHelper.showToast(
        message: "Başarılı",
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to add flavour type');
    }
  }

  // Yeni aroma eklemek için metod
  Future<void> _addFlavour(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final newFlavour = json.decode(response.body)['data'];
      setState(() {
        flavours.add(newFlavour);
        _isExpanded.add(false); // Yeni eklenen eleman için expanded durumunu ekle
      });
      _controllerAromaAdd.clear();
      ToastHelper.showToast(
        message: "Başarılı",
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
    }
  }

  // Kayıt silmek için metod
  Future<void> _deleteFlavour(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/destroy/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        final index = flavours.indexWhere((flavour) => flavour['id'] == id);
        if (index != -1) {
          flavours.removeAt(index);
          _isExpanded.removeAt(index); // Silinen eleman için expanded durumunu kaldır
          flavourTypes.remove(id); // Silinen eleman için tipi kaldır
        }
      });
      ToastHelper.showToast(
        message: "Başarılı",
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to delete flavour');
    }
  }

  // Kayıt güncellemek için metod
  Future<void> _updateFlavour(int id, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final updatedFlavour = json.decode(response.body)['data'];
      setState(() {
        final index = flavours.indexWhere((flavour) => flavour['id'] == id);
        if (index != -1) {
          flavours[index] = updatedFlavour;
        }
      });
      ToastHelper.showToast(
        message: "Başarılı",
        backgroundColor: Colors.green,
        gravity: ToastGravity.TOP,
      );
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to update flavour');
    }
  }

  void _toggleExpansion(int index) {
    setState(() {
      if (index >= 0 && index < _isExpanded.length) {
        _isExpanded[index] = !_isExpanded[index];
        if (_isExpanded[index]) {
          _fetchFlavourTypes(flavours[index]['id']); // Expand olduğunda veriyi çek
        }
      }
    });
  }

  void _handleSubmitted(String value) {
    // Enter tuşuna basıldığında yapılacak işlemler buraya yazılır
    if (_controllerAromaAdd.text.isNotEmpty) {
      _addFlavour(_controllerAromaAdd.text);
      _controllerAromaAdd.clear(); // text field temizler
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
        title: const Text("Aroma Ekle", style: TextStyle(color: Colors.white)),
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
                      controller: _controllerAromaAdd,
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
                            if (_controllerAromaAdd.text.isNotEmpty) {
                              _addFlavour(_controllerAromaAdd.text);
                              _controllerAromaAdd.clear(); // text field temizler
                            }
                          },
                        ),
                        hintText: 'Örn. Yaban Mersini',
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
                        child: Text("Ekli Aromalar"),
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
                      itemCount: flavours.length,
                      itemBuilder: (context, index) {
                        if (index >= flavours.length) {
                          return Container(); // Boş bir widget döndürün
                        }
                        final flavour = flavours[index];
                        final flavourId = flavour['id'];
                        return GestureDetector(
                          onTap: () {
                            _toggleExpansion(index);
                          },
                          child: Column(
                            children: [
                              Card(
                                color: HexColor("#374151"),
                                elevation: 4.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        flavour['name'],
                                        style: TextStyle(color: HexColor("#f3f4f6")),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            color: HexColor("#f3f4f6"),
                                            onPressed: () {
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.noHeader,
                                                animType: AnimType.bottomSlide,
                                                title: 'Dikkat',
                                                desc: 'Bu aromayı silmek istediğinizden emin misiniz?',
                                                btnCancelOnPress: () {},
                                                btnOkOnPress: () {
                                                  _deleteFlavour(flavourId);
                                                },
                                              ).show();
                                            },
                                            icon: Icon(CupertinoIcons.delete),
                                          ),
                                          IconButton(
                                            color: HexColor("#f3f4f6"),
                                            onPressed: () {
                                              _controllerAromaUpdate.text = flavour['name'];
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
                                                              '${flavour['name']} isimli aromayı güncelle',
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
                                                            controller: _controllerAromaUpdate,
                                                            decoration: const InputDecoration(
                                                              labelText: 'Yeni Aroma ismini girin',
                                                              border: OutlineInputBorder(),
                                                            ),
                                                          ),
                                                          SizedBox(height: 16.0),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              if (_controllerAromaUpdate.text.isNotEmpty) {
                                                                _updateFlavour(flavourId, _controllerAromaUpdate.text);
                                                                _controllerAromaUpdate.text = "";
                                                                Navigator.of(context).pop();
                                                              }
                                                            },
                                                            child: Text(
                                                              'Güncelle',
                                                              style: TextStyle(color: HexColor("#f1f5f9")),
                                                            ),
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
                                                            child: Text(
                                                              'İptal Et',
                                                              style: TextStyle(color: HexColor("#f1f5f9")),
                                                            ),
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
                                            icon: Icon(Icons.update),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (_isExpanded[index])
                                Padding(
                                  padding: const EdgeInsets.only(left: 5, right: 5, top: 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: HexColor("#374151"),
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(12.0),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 1,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Text("Mevcut Aroma Tipleri", style: TextStyle(color: Colors.white)),
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white,
                                                  thickness: 1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: flavourTypes.containsKey(flavourId)
                                              ? ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: flavourTypes[flavourId]?.length,
                                            itemBuilder: (context, typeIndex) {
                                              if (typeIndex < 0 || typeIndex >= flavourTypes[flavourId]!.length) {
                                                return Container();
                                              }
                                              final flavourType = flavourTypes[flavourId]?[typeIndex];
                                              final typeId = flavourType['id'];
                                              return Card(
                                                color: HexColor("#4B5563"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        flavourType['name'],
                                                        style: TextStyle(color: HexColor("#f3f4f6")),
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            color: HexColor("#f3f4f6"),
                                                            onPressed: () {
                                                              AwesomeDialog(
                                                                context: context,
                                                                dialogType: DialogType.noHeader,
                                                                animType: AnimType.bottomSlide,
                                                                title: 'Dikkat',
                                                                desc: 'Bu aromayı silmek istediğinizden emin misiniz?',
                                                                btnCancelOnPress: () {},
                                                                btnOkOnPress: () {
                                                                  _deleteFlavourType(flavourId, typeId);
                                                                },
                                                              ).show();
                                                            },
                                                            icon: Icon(CupertinoIcons.delete),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                              : CircularProgressIndicator(),
                                        ),
                                        const Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Divider(
                                                color: Colors.white,
                                                thickness: 1,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text("Diğer Aroma Tipleri", style: TextStyle(color: Colors.white)),
                                            ),
                                            Expanded(
                                              child: Divider(
                                                color: Colors.white,
                                                thickness: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: availableFlavourTypes.length,
                                            itemBuilder: (context, typeIndex) {
                                              final flavourType = availableFlavourTypes[typeIndex];
                                              final typeId = flavourType['id'];

                                              // Mevcut aromalar arasında zaten ekli olanları filtrele
                                              final alreadyAdded = flavourTypes[flavourId]?.any((type) => type['id'] == typeId) ?? false;

                                              if (alreadyAdded) {
                                                return Container();
                                              }

                                              return Card(
                                                color: HexColor("#4B5563"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(16.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        flavourType['name'],
                                                        style: TextStyle(color: HexColor("#f3f4f6")),
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            color: HexColor("#f3f4f6"),
                                                            onPressed: () {
                                                              _addFlavourType(flavourId, typeId);
                                                              _toggleExpansion(index);
                                                            },
                                                            icon: Icon(CupertinoIcons.add),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
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
