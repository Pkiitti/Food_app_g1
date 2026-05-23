import 'order_response.dart';

class OrderHistoryResponse {
  bool? status;
  List<OrderResponse> orders;

  OrderHistoryResponse({
    this.status,
    required this.orders,
  });

  OrderHistoryResponse.buildDefault() : orders = [];

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    List<OrderResponse> orderList = [];

    if (json['orders'] != null) {
      List<dynamic> arrData = json['orders'];
      for (var item in arrData) {
        orderList.add(OrderResponse.fromJson(item));
      }
    }

    return OrderHistoryResponse(
      status: json['status'],
      orders: orderList,
    );
  }
}