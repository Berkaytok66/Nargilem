import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/Global/ToastHelper.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AromaPageType extends StatefulWidget {
  const AromaPageType({super.key});

  @override
  State<AromaPageType> createState() => _AromaPageState();
}

class _AromaPageState extends State<AromaPageType> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _controllerAromaAdd = TextEditingController();
  final TextEditingController _controllerAromaUpdate = TextEditingController();

  List<dynamic> flavours = []; // Gelen veriyi tutmak için bir liste

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchFlavours(); // Veriyi almak için metodu çağır
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerAromaAdd.dispose();
    super.dispose();
  }

  // Tüm Kayıtları Listeler.
  Future<void> _fetchFlavours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour-type/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        flavours = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load flavours');
    }
  }

  // Yeni aroma eklemek için metod
  Future<void> _addFlavour(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour-type/add'),
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
      throw Exception('Failed to add flavour');
    }
  }

  // Kayıt silmek için metod
  Future<void> _deleteFlavour(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour-type/destroy/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        flavours.removeWhere((flavour) => flavour['id'] == id);
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
      Uri.parse('${SabitD.URL}/api/terminal/management/flavour-type/update/$id'),
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
        title: const Text("Aroma Ekle",style: TextStyle(color: Colors.white),),
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
            width: MediaQuery.of(context).size.width / 1,
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
                              child: Icon(CupertinoIcons.add_circled_solid)),
                          onTap: () {
                            if (_controllerAromaAdd.text.isNotEmpty) {
                              _addFlavour(_controllerAromaAdd.text);
                              _controllerAromaAdd.clear(); //text fled temizler
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
                SizedBox(height: 40,)
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [


                  SizedBox(height: 20,),
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
                  SizedBox(height: 20,),
                  Expanded(
                    child: ListView.builder(
                      itemCount: flavours.length,
                      itemBuilder: (context, index) {
                        final flavour = flavours[index];

                        return GestureDetector(
                          onTap: () {
                            _controllerAromaUpdate.text = '${flavour['name']}';
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
                                        const SizedBox(height: 10,),
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
                                            if(_controllerAromaUpdate.text.isNotEmpty){
                                              _updateFlavour(flavour['id'], _controllerAromaUpdate.text);
                                              _controllerAromaUpdate.text = "";
                                              Navigator.of(context).pop();
                                            }
                                          },
                                          child: Text('Güncelle',style: TextStyle(color: HexColor("#f1f5f9"))),
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
                                          child: Text('İptal Et',style: TextStyle(color: HexColor("#f1f5f9")),),
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
                                  Text(flavour['name'],style: TextStyle(color: HexColor("#f3f4f6")),),
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
                                          _deleteFlavour(flavour['id']);
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
