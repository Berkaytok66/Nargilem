
class RestaurantTable {
  final int id;
  final String tableNumber;
  final int status;

  RestaurantTable({required this.id, required this.tableNumber, required this.status});

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] ?? 0,
      tableNumber: json['table_number'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}
