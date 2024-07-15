import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:nargilem/Global/SabitDegiskenler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Future<List<dynamic>> fetchOrders(int status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/order/get/$status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> updateOrderStatus(int id, String status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${SabitD.URL}/api/terminal/personal/order/status/$id/$status'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update order status');
    }
  }
}
