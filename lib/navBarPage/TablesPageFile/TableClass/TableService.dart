import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nargilem/navBarPage/TablesPageFile/TableClass/Table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nargilem/Global/SabitDegiskenler.dart';

class TableService {
  // Admin masa getir
  Future<List<RestaurantTable>> fetchTables() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/table/self/get'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => RestaurantTable.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tables');
    }
  }

  Future<RestaurantTable> addTable(String tableNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.put(
      Uri.parse('${SabitD.URL}/api/terminal/management/table/self/add'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'table_number': tableNumber,
      }),
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data']['table'];
      return RestaurantTable.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception('Failed to add table: ${error['message']}');
    }
  }

  Future<void> deleteTable(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('${SabitD.URL}/api/terminal/management/table/self/destroy/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception('Failed to delete table: ${error['message']}');
    }
  }

  Future<RestaurantTable> fetchTableDetails(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/management/table/self/show/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body)['data']['table'];
      return RestaurantTable.fromJson(data);
    } else {
      final error = json.decode(response.body);
      throw Exception('Failed to fetch table details: ${error['message']}');
    }
  }
}
