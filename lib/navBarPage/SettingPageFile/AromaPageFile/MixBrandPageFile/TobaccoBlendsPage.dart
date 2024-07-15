
import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:nargilem/Global/ToastHelper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TobaccoBlendsPage extends StatefulWidget {
  const TobaccoBlendsPage({super.key});

  @override
  State<TobaccoBlendsPage> createState() => _TobaccoBlendsPageState();
}

class _TobaccoBlendsPageState extends State<TobaccoBlendsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final TextEditingController _controllerBlendAdd = TextEditingController();
  final TextEditingController _controllerBlendUpdateName = TextEditingController();
  final TextEditingController _controllerBlendUpdateRate = TextEditingController();
  final TextEditingController _controllerIngredientRate = TextEditingController();
  final TextEditingController _controllerIngredientTobaccoId = TextEditingController();
  List<bool> _isExpanded = [];
  List<dynamic> blends = [];
  Map<int, List<dynamic>> blendIngredients = {};
  List<dynamic> availableIngredients = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _fetchBlends();
    _fetchAvailableIngredients();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerBlendAdd.dispose();
    _controllerBlendUpdateName.dispose();
    _controllerBlendUpdateRate.dispose();
    _controllerIngredientRate.dispose();
    _controllerIngredientTobaccoId.dispose();
    super.dispose();
  }

  // Tüm Kayıtları Listeler.
  Future<void> _fetchBlends() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        blends = json.decode(response.body)['data'];
        _isExpanded = List<bool>.filled(blends.length, false, growable: true);
      });
    } else {
      throw Exception('Failed to load blends');
    }
  }

  // Mevcut tütünleri almak için metod
  Future<void> _fetchAvailableIngredients() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/tobacco/get'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        availableIngredients = json.decode(response.body)['data'];
      });
    } else {
      throw Exception('Failed to load available ingredients');
    }
  }

  // Yeni karışım eklemek için metod
  Future<void> _addBlend(String name, int tobaccoBrandId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name, 'tobacco_brand_id': tobaccoBrandId}),
    );

    if (response.statusCode == 200) {
      final newBlend = json.decode(response.body)['data'];
      setState(() {
        blends.add(newBlend);
        _isExpanded.add(false);
      });
      _controllerBlendAdd.clear();
    } else {
      throw Exception('Failed to add blend');
    }
  }


  // Karışım silmek için metod
  Future<void> _deleteBlend(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/destroy/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          final index = blends.indexWhere((blend) => blend['id'] == id);
          if (index != -1) {
            blends.removeAt(index);
            _isExpanded.removeAt(index);
            blendIngredients.remove(id);
          }
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: HexColor("#4ade80"),
          gravity: ToastGravity.TOP,
        );
      }
    } else {
      ToastHelper.showToast(
        message: "Silme işlemi başarısız",
        backgroundColor: Colors.red,
        gravity: ToastGravity.TOP,
      );
      throw Exception('Failed to delete blend');
    }
  }


  // Karışım güncellemek için metod
  Future<void> _updateBlend(int id, String name, int tobaccoBrandId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/update/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'name': name, 'tobacco_brand_id': tobaccoBrandId}),
    );

    if (response.statusCode == 200) {
      final updatedBlend = json.decode(response.body)['data'];
      setState(() {
        final index = blends.indexWhere((blend) => blend['id'] == id);
        if (index != -1) {
          blends[index] = updatedBlend;
        }
      });
    } else {
      throw Exception('Failed to update blend');
    }
  }

  // Belirli bir kaydın içeriklerini almak için metod
  Future<void> _fetchBlendIngredients(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/show/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        blendIngredients[id] = json.decode(response.body)['data']['tobacco_blend_ingredients'];
      });
    } else {
      throw Exception('Failed to load blend ingredients');
    }
  }

  // Karışıma tütün eklemek için metod
  Future<void> _addBlendIngredient(int blendId, int tobaccoId, double rate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest(
        'POST',
        Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/ingredient/add/$blendId')
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['tobacco_id'] = tobaccoId.toString();
    request.fields['rate'] = rate.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      final succsesMesage = json.decode(responseData)['result_type'];

      if (succsesMesage.toString() == 'success') {
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: HexColor("#4ade80"),
          gravity: ToastGravity.TOP,
        );
      }


      final newIngredient = json.decode(responseData)['data']['ingredient'];
      setState(() {
        blendIngredients[blendId]!.add(newIngredient);
      });
    } else {

        var responseData = await response.stream.bytesToString();
        final errorMessage = json.decode(responseData)['message'];
        if (errorMessage.toString() == 'rate_100'){
          ToastHelper.showToast(
            message: "Oran olarak %100 Geçilmemelidir!",
            backgroundColor: Colors.red,
            gravity: ToastGravity.TOP,
          );
        }
      throw Exception('Failed to add blend ingredient');
    }
  }

  // Karışımın tütün oranını güncellemek için metod
  Future<void> _updateBlendIngredient(int ingredientId, int tobaccoId, double rate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    var request = http.MultipartRequest(
        'POST',
        Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/ingredient/update/$ingredientId')
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.fields['tobacco_id'] = tobaccoId.toString();
    request.fields['rate'] = rate.toString();

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      final updatedIngredients = json.decode(responseData)['data']['ingredient'];
      setState(() {
        final blendId = updatedIngredients.first['tobacco_blend_id'];
        blendIngredients[blendId] = updatedIngredients;
      });

    } else {

      throw Exception('Failed to update blend ingredient');
    }
  }

  // Karışımın tütün oranını silmek için metod
  Future<void> _deleteBlendIngredient(int ingredientId, int blendId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/blend/self/ingredient/destroy/$ingredientId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      if (responseData['result_type'] == 'success') {
        setState(() {
          blendIngredients[blendId] = blendIngredients[blendId]!
              .where((ingredient) => ingredient['id'] != ingredientId)
              .toList();
        });
        ToastHelper.showToast(
          message: "Başarılı",
          backgroundColor: HexColor("#4ade80"),
          gravity: ToastGravity.TOP,
        );
      } else {
        ToastHelper.showToast(
          message: responseData['message'] ?? "Silme işlemi başarısız",
          backgroundColor: Colors.red,
          gravity: ToastGravity.TOP,
        );
      }
    } else {
      ToastHelper.showToast(
        message: "Silme işlemi başarısız",
        backgroundColor: Colors.red,
        gravity: ToastGravity.TOP,
      );
      print("Error: ${response.body}");
      throw Exception('Failed to delete blend ingredient');
    }
  }

  void _toggleExpansion(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
      if (_isExpanded[index]) {
        _fetchBlendIngredients(blends[index]['id']);
      }
    });
  }
  void _handleSubmitted(String value) {
    // Enter tuşuna basıldığında yapılacak işlemler buraya yazılır

    if (_controllerBlendAdd.text.isNotEmpty) {
      print('Submitted text: $value');
      _addBlend(value, 1); // tobacco_brand_id olarak 1 gönderildi
      _controllerBlendAdd.clear();
    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HexColor("#374151"),
        iconTheme: IconThemeData(
          color: Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white,
        ),
        title: const Text("Karışım Yönetimi", style: TextStyle(color: Colors.white)),
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
                      controller: _controllerBlendAdd,
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
                            if (_controllerBlendAdd.text.isNotEmpty) {
                              _addBlend(_controllerBlendAdd.text, 1); // tobacco_brand_id olarak 1 gönderildi
                              _controllerBlendAdd.clear();
                            }
                          },
                        ),
                        hintText: 'Örn. Limon',
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
                        child: Text("Ekli Karışımlar"),
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
                      itemCount: blends.length,
                      itemBuilder: (context, index) {
                        final blend = blends[index];
                        final blendId = blend['id'];
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
                                        blend['name'],
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
                                                desc: 'Bu karışımı silmek istediğinizden emin misiniz?',
                                                btnCancelOnPress: () {},
                                                btnOkOnPress: () {
                                                  _deleteBlend(blendId);
                                                },
                                              ).show();
                                            },
                                            icon: Icon(CupertinoIcons.delete),
                                          ),
                                          IconButton(
                                            color: HexColor("#f3f4f6"),
                                            onPressed: () {
                                              _controllerBlendUpdateName.text = blend['name'];
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
                                                              '${blend['name']} isimli karışımı güncelle',
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
                                                            controller: _controllerBlendUpdateName,
                                                            decoration: const InputDecoration(
                                                              labelText: 'Yeni karışım ismini girin',
                                                              border: OutlineInputBorder(),
                                                            ),
                                                          ),
                                                          SizedBox(height: 16.0),
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              if (_controllerBlendUpdateName.text.isNotEmpty) {
                                                                _updateBlend(blendId, _controllerBlendUpdateName.text, 1); // tobacco_brand_id olarak 1 gönderildi
                                                                _controllerBlendUpdateName.clear();
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
                                                child: Text("Mevcut Tütünler", style: TextStyle(color: Colors.white)),
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
                                          child: blendIngredients.containsKey(blendId)
                                              ? ListView.builder(
                                            shrinkWrap: true,
                                            physics: NeverScrollableScrollPhysics(),
                                            itemCount: blendIngredients[blendId]?.length,
                                            itemBuilder: (context, ingredientIndex) {
                                              final ingredient = blendIngredients[blendId]?[ingredientIndex];
                                              final ingredientId = ingredient['id'];
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
                                                        'Tütün Adı: ${ingredient['tobacco_id']} - Oran: ${ingredient['rate']}',
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
                                                                desc: 'Bu tütünü karışımdan silmek istediğinizden emin misiniz?',
                                                                btnCancelOnPress: () {},
                                                                btnOkOnPress: () {
                                                                  _deleteBlendIngredient(ingredientId, blendId);
                                                                },
                                                              ).show();
                                                            },
                                                            icon: Icon(CupertinoIcons.delete),
                                                          ),
                                                          IconButton(
                                                            color: HexColor("#f3f4f6"),
                                                            onPressed: () {
                                                              _controllerIngredientTobaccoId.text = ingredient['tobacco_id'].toString();
                                                              _controllerIngredientRate.text = ingredient['rate']?.toString() ?? '';
                                                              showModalBottomSheet(
                                                                context: context,
                                                                backgroundColor: HexColor("#d1d5db"),
                                                                shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(35.0)),
                                                                ),
                                                                isScrollControlled: true,
                                                                builder: (BuildContext context) {
                                                                  return Padding(
                                                                    padding: EdgeInsets.only(
                                                                      bottom: MediaQuery.of(context).viewInsets.bottom,
                                                                    ),
                                                                    child: Container(
                                                                      padding: EdgeInsets.all(16.0),
                                                                      height: MediaQuery.of(context).size.height * 0.5,
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                                                        children: [
                                                                          const SizedBox(height: 10),
                                                                          Align(
                                                                            alignment: Alignment.center,
                                                                            child: Text(
                                                                              'Tütün ID: ${ingredient['tobacco_id']} oranını güncelle',
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
                                                                            controller: _controllerIngredientTobaccoId,
                                                                            decoration: const InputDecoration(
                                                                              labelText: 'Tütün ID',
                                                                              border: OutlineInputBorder(),
                                                                            ),
                                                                          ),
                                                                          SizedBox(height: 16.0),
                                                                          TextField(
                                                                            controller: _controllerIngredientRate,
                                                                            decoration: const InputDecoration(
                                                                              labelText: 'Yeni oranı girin',
                                                                              border: OutlineInputBorder(),
                                                                            ),
                                                                            keyboardType: TextInputType.number,
                                                                          ),
                                                                          SizedBox(height: 16.0),
                                                                          ElevatedButton(
                                                                            onPressed: () {
                                                                              if (_controllerIngredientRate.text.isNotEmpty && _controllerIngredientTobaccoId.text.isNotEmpty) {
                                                                                final newRate = double.tryParse(_controllerIngredientRate.text);
                                                                                final newTobaccoId = int.tryParse(_controllerIngredientTobaccoId.text);
                                                                                if (newRate != null && newTobaccoId != null) {
                                                                                  _updateBlendIngredient(ingredientId, newTobaccoId, newRate);
                                                                                  _controllerIngredientRate.text = "";
                                                                                  _controllerIngredientTobaccoId.text = "";
                                                                                  Navigator.of(context).pop();
                                                                                }
                                                                              }
                                                                            },
                                                                            child: Text(
                                                                              'Güncelle',
                                                                              style: TextStyle(color: HexColor("#f1f5f9")),
                                                                            ),
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: HexColor("#4d7c0f"), // Arka plan rengi
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
                                                                              backgroundColor: HexColor("#b45309"), // Arka plan rengi
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
                                              child: Text("Diğer Tütünler", style: TextStyle(color: Colors.white)),
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
                                            itemCount: availableIngredients.length,
                                            itemBuilder: (context, ingredientIndex) {
                                              final ingredient = availableIngredients[ingredientIndex];
                                              final ingredientId = ingredient['id'];

                                              // Mevcut tütünler arasında zaten ekli olanları filtrele
                                              final alreadyAdded = blendIngredients[blendId]?.any((type) => type['tobacco_id'] == ingredientId) ?? false;

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
                                                        'Tütün ID: $ingredientId',
                                                        style: TextStyle(color: HexColor("#f3f4f6")),
                                                      ),
                                                      Row(
                                                        children: [
                                                          IconButton(
                                                            color: HexColor("#d1d5db"),
                                                            onPressed: () {
                                                              _controllerIngredientRate.text = '';
                                                              _controllerIngredientTobaccoId.text = ingredientId.toString();
                                                              showModalBottomSheet(
                                                                backgroundColor: HexColor("#a3a3a3"),
                                                                context: context,
                                                                isScrollControlled: true,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
                                                                ),
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
                                                                           Text(
                                                                            "${ingredientId.toString()} İçin Eklenecek Oranı Belirtin",
                                                                            style: const TextStyle(
                                                                              fontSize: 16.0,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                             textAlign: TextAlign.center,
                                                                             softWrap: true,
                                                                             overflow: TextOverflow.visible,
                                                                          ),
                                                                          SizedBox(height: 16.0),
                                                                          TextField(
                                                                            controller: _controllerIngredientRate,
                                                                            decoration: InputDecoration(
                                                                              labelText: "Oranı girin",
                                                                              border: OutlineInputBorder(),
                                                                            ),
                                                                            keyboardType: TextInputType.number,
                                                                          ),
                                                                          SizedBox(height: 16.0),
                                                                          ElevatedButton(
                                                                            onPressed: () {

                                                                              final rate = double.tryParse(_controllerIngredientRate.text);
                                                                              final tobaccoId = int.tryParse(_controllerIngredientTobaccoId.text);
                                                                              if (rate != null && tobaccoId != null) {
                                                                                _addBlendIngredient(blendId, tobaccoId, rate);
                                                                                Navigator.of(context).pop();
                                                                                setState(() {});
                                                                                _toggleExpansion(index);
                                                                              }
                                                                            },
                                                                            child: Text("Ekle"),
                                                                            style: ElevatedButton.styleFrom(
                                                                              foregroundColor: HexColor("#f1f5f9"), backgroundColor: HexColor("#16a34a"), // Metin rengi
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          TextButton(

                                                                            onPressed: () {
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            style: ElevatedButton.styleFrom(
                                                                              backgroundColor: HexColor("#b45309"), // Arka plan rengi
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(5), // Dikdörtgen yapmak için
                                                                              ),
                                                                            ),
                                                                            child: Text("İptal",style: TextStyle(color: Colors.white),),

                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
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
