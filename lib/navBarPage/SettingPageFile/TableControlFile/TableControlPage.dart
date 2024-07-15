import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TableClass/Table.dart';
import 'package:nargilem/navBarPage/TablesPageFile/TableClass/TableService.dart';

class TableControlPage extends StatefulWidget {
  const TableControlPage({super.key});

  @override
  State<TableControlPage> createState() => _TableControlPageState();
}

class _TableControlPageState extends State<TableControlPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<RestaurantTable> tables = [];
  List<RestaurantTable> filteredTables = [];
  final TableService tableService = TableService();
  final TextEditingController _controllerTableNumber = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    fetchTables();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerTableNumber.dispose();
    super.dispose();
  }

  Future<void> fetchTables() async {
    try {
      List<RestaurantTable> fetchedTables = await tableService.fetchTables();
      setState(() {
        tables = fetchedTables;
        filteredTables = tables;
      });
    } catch (e) {
      print(e);
    }
  }

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

  Future<void> _addTable() async {
    String tableNumber = "Table ${_controllerTableNumber.text}";
    if (tableNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Masa numarası boş olamaz"),
          backgroundColor: HexColor("#ef4444"),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 50), // Snackbar'ın görünürlüğünü artırmak için güncellendi
        ),
      );
      return;
    }

    try {
      RestaurantTable newTable = await tableService.addTable(tableNumber);
      setState(() {
        tables.add(newTable);
        filteredTables = tables;
      });
      _controllerTableNumber.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masa başarıyla eklendi"),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 50), // Snackbar'ın görünürlüğünü artırmak için güncellendi
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 50), // Snackbar'ın görünürlüğünü artırmak için güncellendi
        ),
      );
    }
  }

  Future<void> _deleteTable(int id) async {
    try {
      await tableService.deleteTable(id);
      setState(() {
        tables.removeWhere((table) => table.id == id);
        filteredTables = tables;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Masa başarıyla silindi"),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 50),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 50),
        ),
      );
    }
  }

  Future<void> _showTableDetails(int id) async {
    try {
      RestaurantTable tableDetails = await tableService.fetchTableDetails(id);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Masa Detayları'),
            content: Text('Masa Numarası: ${tableDetails.tableNumber}\nDurum: ${tableDetails.status}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Kapat'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 50),
        ),
      );
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
        title: const Text("Masa Yönetim Paneli", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ara...',
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
                  crossAxisCount: 4, // Her satırda kaç masa olacağı
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: filteredTables.length,
                itemBuilder: (context, index) {
                  final table = filteredTables[index];
                  return GestureDetector(
                    onTap: () {
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
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _showTableDetails(table.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: HexColor("#f1f5f9"),
                                      backgroundColor: HexColor("#16a34a"), // Metin rengi
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text("Görüntüle"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteTable(table.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: HexColor("#f1f5f9"),
                                      backgroundColor: HexColor("#dc2626"), // Silme rengi
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    child: const Text("Masayı Kaldır"),
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
                                    child: const Text("İptal", style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: HexColor("#94a3b8"),
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
      floatingActionButton: FloatingActionButton.extended(
        foregroundColor: HexColor("#1f2937"),
        onPressed: () {
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
                      const Text(
                        "Yeni Masa Ekle",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _controllerTableNumber,
                        decoration: const InputDecoration(
                          labelText: "Masa Numarası",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: (){
                          _addTable;
                          Navigator.of(context).pop();
                        },
                        child: Text("Masa Ekle"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: HexColor("#f1f5f9"),
                          backgroundColor: HexColor("#16a34a"), // Metin rengi
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
                        child: const Text("İptal", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        label: const Text('Masa Ekle'),
        icon: const Icon(CupertinoIcons.add_circled_solid),
      ),
    );
  }
}
