class Cart {
  final int id;
  final String? sessionId;
  final String? userId;

  Cart({required this.id, this.sessionId, this.userId});

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
    );
  }
}
