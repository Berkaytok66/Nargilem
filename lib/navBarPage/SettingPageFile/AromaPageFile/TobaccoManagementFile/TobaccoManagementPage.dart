import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/Global/ToastHelper.dart';
import 'package:nargilem/navBarPage/SettingPageFile/AromaPageFile/AromaHomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class TobaccoManagementPage extends StatefulWidget {
  const TobaccoManagementPage({super.key});

  @override
  State<TobaccoManagementPage> createState() => _TobaccoManagementPageState();
}

class _TobaccoManagementPageState extends State<TobaccoManagementPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _controllerTobaccoAdd = TextEditingController();
  final TextEditingController _controllerTobaccoUpdate = TextEditingController();
  List<bool> _isExpanded = [];
  List<dynamic> tobaccos = []; // Gelen veriyi tutmak için bir liste
  Map<int, List<dynamic>> tobaccoFlavours = {}; // Genişletilmiş veriyi tutmak için bir harita
  List<dynamic> availableFlavours = []; // Mevcut aromaları tutmak için bir liste

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchTobaccos(); // Veriyi almak için metodu çağır
    _fetchAvailableFlavours(); // Mevcut aroma tiplerini almak için metodu çağır
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerTobaccoAdd.dispose();
    _controllerTobaccoUpdate.dispose();
    super.dispose();
  }

  // Tüm Kayıtları Listeler.
  Future<void> _fetchTobaccos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          tobaccos = responseData['data'];
          _isExpanded = List<bool>.filled(tobaccos.length, false, growable: true);
        });
      }
    } else {
      throw Exception('Failed to load tobaccos');
    }
  }

  // Yeni tütün eklemek için metod
  Future<void> _addTobacco(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        final newTobacco = responseData['data'];
        setState(() {
          tobaccos.add(newTobacco);
          _isExpanded.add(false); // Yeni eklenen eleman için expanded durumunu ekle
        });
        _controllerTobaccoAdd.clear();
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to add tobacco');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to add tobacco');
    }
  }

  // Kayıt silmek için metod
  Future<void> _deleteTobacco(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/destroy/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          final index = tobaccos.indexWhere((tobacco) => tobacco['id'] == id);
          if (index != -1) {
            tobaccos.removeAt(index);
            _isExpanded.removeAt(index); // Silinen eleman için expanded durumunu kaldır
            tobaccoFlavours.remove(id); // Silinen eleman için aromaları kaldır
          }
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to delete tobacco');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to delete tobacco');
    }
  }

  // Kayıt güncellemek için metod
  Future<void> _updateTobacco(int id, String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        final updatedTobacco = responseData['data'];
        setState(() {
          final index = tobaccos.indexWhere((tobacco) => tobacco['id'] == id);
          if (index != -1) {
            tobaccos[index] = updatedTobacco;
          }
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to update tobacco');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to update tobacco');
    }
  }

  // Belirli bir kaydın aromalarını almak için metod
  Future<void> _fetchTobaccoFlavours(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/flavour/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          tobaccoFlavours[id] = responseData['data'];
        });

      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        print("Error: ${responseData['message']}");
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
    }
  }

  // Belirli bir kaydın aromasını silmek için metod
  Future<void> _deleteTobaccoFlavour(int tobaccoId, int flavourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/flavour/$tobaccoId/detach'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'flavour_id': flavourId}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          tobaccoFlavours[tobaccoId] = tobaccoFlavours[tobaccoId]!
              .where((flavour) => flavour['id'] != flavourId)
              .toList();
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to delete tobacco flavour');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to delete tobacco flavour');
    }
  }

  // Belirli bir kayda aroma eklemek için metod
  Future<void> _addTobaccoFlavour(int tobaccoId, int flavourId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/flavour/$tobaccoId/attach'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'flavour_id': flavourId}),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        final newFlavour = responseData['data'];
        setState(() {
          tobaccoFlavours[tobaccoId]!.add(newFlavour);
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: Colors.green,
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: "Hata: ${responseData['message']}",
          backgroundColor: Colors.redAccent,
          gravity: ToastGravity.TOP,
        );
        throw Exception('Failed to add tobacco flavour');
      }
    } else {
      ToastHelper.showToast(
        message: "Hata: ${response.statusCode}",
        backgroundColor: Colors.redAccent,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to add tobacco flavour');
    }
  }

  // Mevcut aromaları almak için metod
  Future<void> _fetchAvailableFlavours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          availableFlavours = responseData['data'];
        });
      } else {
        print("Error: ${responseData['message']}");
      }
    } else {
      print("Failed to load available flavours. Status code: ${response.statusCode}");
    }
  }

  void _toggleExpansion(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
      if (_isExpanded[index]) {
        _fetchTobaccoFlavours(tobaccos[index]['id']); // Expand olduğunda veriyi çek
      }
    });
  }
  void _handleSubmitted(String value) {
    // Enter tuşuna basıldığında yapılacak işlemler buraya yazılır

    if (_controllerTobaccoAdd.text.isNotEmpty) {
      _addTobacco(_controllerTobaccoAdd.text).then((_) {
        setState(() {});
      });

      _controllerTobaccoAdd.clear(); // text field temizler
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
        title: const Text("Tütün Yönetimi", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // İkona tıklandığında yapılacak işlemler
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AromaHomePage(),
              ),
            );
          },
        ),
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
                      controller: _controllerTobaccoAdd,
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
                            if (_controllerTobaccoAdd.text.isNotEmpty) {
                              _addTobacco(_controllerTobaccoAdd.text).then((_) {
                                setState(() {});
                              });

                              _controllerTobaccoAdd.clear(); // text field temizler
                            }
                          },
                        ),
                        hintText: 'Örn. Limon Buz',
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
                        child: Text("Ekli Tütünler"),
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
                      itemCount: tobaccos.length,
                      itemBuilder: (context, index) {
                        final tobacco = tobaccos[index];
                        final tobaccoId = tobacco['id'];
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
                                        tobacco['name'],
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
                                                desc: 'Bu tütünü silmek istediğinizden emin misiniz?',
                                                btnCancelOnPress: () {},
                                                btnOkOnPress: () {
                                                  _deleteTobacco(tobaccoId).then((_) {
                                                    setState(() {});
                                                  });
                                                },
                                              ).show();
                                            },
                                            icon: Icon(CupertinoIcons.delete),
                                          ),
                                          IconButton(
                                            color: HexColor("#f3f4f6"),
                                            onPressed: () {
                                              _controllerTobaccoUpdate.text = tobacco['name'];
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
                                                              '${tobacco['name']} isimli tütünü güncelle',
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
                                                            controller: _controllerTobaccoUpdate,
                                                            decoration: const InputDecoration(
                                                              labelText: 'Yeni tütün ismini girin',
                                                              border: OutlineInputBorder(),
                                                            ),
                                                          ),
                                                          SizedBox(height: 16.0),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              if (_controllerTobaccoUpdate.text.isNotEmpty) {
                                                                _updateTobacco(tobaccoId, _controllerTobaccoUpdate.text).then((_) {
                                                                  setState(() {});
                                                                });
                                                                _controllerTobaccoUpdate.text = "";
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
                                            icon:  FaIcon(FontAwesomeIcons.edit, size: 18, color: Colors.white),
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
                                                child: Text("Ekli Aromalar",style: TextStyle(color: Colors.white)),
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
                                          child: tobaccoFlavours.containsKey(tobaccoId)
                                              ? ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: tobaccoFlavours[tobaccoId]?.length,
                                            itemBuilder: (context, flavourIndex) {
                                              final flavour = tobaccoFlavours[tobaccoId]?[flavourIndex];
                                              final flavourId = flavour['id'];
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
                                                                  _deleteTobaccoFlavour(tobaccoId, flavourId).then((_) {
                                                                    setState(() {});
                                                                  });
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
                                              child: Text("Mevcut Aromalar", style: TextStyle(color: Colors.white)),
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
                                            itemCount: availableFlavours.length,
                                            itemBuilder: (context, flavourIndex) {
                                              final flavour = availableFlavours[flavourIndex];
                                              final flavourId = flavour['id'];

                                              // Mevcut aromalar arasında zaten ekli olanları filtrele
                                              final alreadyAdded = tobaccoFlavours[tobaccoId]?.any((f) => f['id'] == flavourId) ?? false;

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
                                                        flavour['name'],
                                                        style: TextStyle(color: HexColor("#f3f4f6")),
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            color: HexColor("#f3f4f6"),
                                                            onPressed: () {
                                                              _addTobaccoFlavour(tobaccoId, flavourId).then((_) {
                                                                setState(() {});
                                                                _toggleExpansion(index);
                                                              });
                                                            },
                                                            icon:  FaIcon(FontAwesomeIcons.add, size: 18, color: Colors.white),
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
