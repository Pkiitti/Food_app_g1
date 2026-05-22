import 'order_item_response.dart';

class OrderResponse {
  String? id;
  List<OrderItemResponse> items;
  int? totalPrice;
  String? status;
  String? createdAt;

  OrderResponse({
    this.id,
    required this.items,
    this.totalPrice,
    this.status,
    this.createdAt,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    List<OrderItemResponse> orderItems = [];

    if (json['items'] != null) {
      List<dynamic> arrData = json['items'];
      for (var item in arrData) {
        orderItems.add(OrderItemResponse.fromJson(item));
      }
    }

    return OrderResponse(
      id: json['_id'],
      items: orderItems,
      totalPrice: json['totalPrice'],
      status: json['status'],
      createdAt: json['createdAt'],
    );
  }
}