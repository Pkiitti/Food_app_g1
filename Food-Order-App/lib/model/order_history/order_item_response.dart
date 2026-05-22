class OrderItemResponse {
  String? id;
  String? foodId;
  String? title;
  String? description;
  int? price;
  String? image;

  OrderItemResponse({
    this.id,
    this.foodId,
    this.title,
    this.description,
    this.price,
    this.image,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) {
    return OrderItemResponse(
      id: json['_id'],
      foodId: json['foodId'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      image: json['image'],
    );
  }
}