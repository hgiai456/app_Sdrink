class SimpleProductDetail {
  final int price;

  SimpleProductDetail({required this.price});

  factory SimpleProductDetail.fromJson(Map<String, dynamic> json) {
    try {
      return SimpleProductDetail(
        price:
            json['price'] is int
                ? json['price']
                : int.parse(json['price'].toString()),
      );
    } catch (e) {
      print('Error parsing SimpleProductDetail from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {'price': price};
  }

  @override
  String toString() {
    return 'SimpleProductDetail{price: $price}';
  }
}
