
class RestaurantTableClass {
  final String uuid;
  final String tableNumber;
  final int isBusy;

  RestaurantTableClass({
    required this.uuid,
    required this.tableNumber,
    required this.isBusy,
  });

  factory RestaurantTableClass.fromJson(Map<String, dynamic> json) {
    return RestaurantTableClass(
      uuid: json['uuid'],
      tableNumber: json['table_number'],
      isBusy: json['is_busy'],
    );
  }
}
