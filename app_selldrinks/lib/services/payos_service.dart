import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

class PayOSService {
  static const String _clientId = '28089082-eca2-4e4d-9fe8-9b15ac275c10';
  static const String _apiKey = 'd3a30542-d496-4e23-9533-054ac2601efe';
  static const String _checksumKey =
      'd3bf2929d07be8703432379775f636875707c2f8d9ce9c46f1f702255ca14ffc';
  static const String _baseUrl = 'https://api-merchant.payos.vn';

  final Dio _dio = Dio();

  PayOSService() {
    _dio.options.headers = {
      'x-client-id': _clientId,
      'x-api-key': _apiKey,
      'Content-Type': 'application/json',
    };
  }

  /// Tạo link thanh toán PayOS
  Future<Map<String, dynamic>> createPaymentLink({
    required int orderCode,
    required int amount,
    required String description,
    String? buyerName,
    String? buyerPhone,
    String? buyerAddress,
  }) async {
    try {
      // Tạo items array đúng format
      final items = [
        {'name': description, 'quantity': 1, 'price': amount},
      ];

      final Map<String, dynamic> paymentData = {
        'orderCode': orderCode,
        'amount': amount,
        'description': description,
        'items': items,
        'cancelUrl': 'https://shopsellshoes4.live/cancel',
        'returnUrl': 'https://shopsellshoes4.live/success',
      };

      // Thêm thông tin buyer nếu có
      if (buyerName != null && buyerName.isNotEmpty) {
        paymentData['buyerName'] = buyerName;
      }
      if (buyerPhone != null && buyerPhone.isNotEmpty) {
        paymentData['buyerPhone'] = buyerPhone;
      }
      if (buyerAddress != null && buyerAddress.isNotEmpty) {
        paymentData['buyerAddress'] = buyerAddress;
      }

      // Tạo signature
      final signature = _createSignature(paymentData);
      paymentData['signature'] = signature;

      print('PayOS Request: ${jsonEncode(paymentData)}');

      final response = await _dio.post(
        '$_baseUrl/v2/payment-requests',
        data: paymentData,
      );

      print('PayOS Response: ${response.data}');

      // ✅ SỬA LỖI: Kiểm tra đúng field 'code' thay vì 'error'
      if (response.statusCode == 200 &&
          (response.data['code'] == '00' || response.data['code'] == 0)) {
        return {
          'success': true,
          'data': response.data['data'],
          'qrCode': response.data['data']['qrCode'],
          'checkoutUrl': response.data['data']['checkoutUrl'],
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['desc'] ??
              response.data['message'] ??
              'Lỗi tạo thanh toán',
        };
      }
    } catch (e) {
      print('PayOS Error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  /// Kiểm tra trạng thái thanh toán
  Future<Map<String, dynamic>> getPaymentStatus(int orderCode) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/v2/payment-requests/$orderCode',
      );

      // ✅ SỬA LỖI: Kiểm tra đúng field 'code' thay vì 'error'
      if (response.statusCode == 200 &&
          (response.data['code'] == '00' || response.data['code'] == 0)) {
        return {
          'success': true,
          'data': response.data['data'],
          'status': response.data['data']['status'], // PENDING, PAID, CANCELLED
        };
      } else {
        return {
          'success': false,
          'message':
              response.data['desc'] ??
              response.data['message'] ??
              'Lỗi kiểm tra thanh toán',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  /// Tạo signature cho PayOS - FIXED VERSION
  String _createSignature(Map<String, dynamic> data) {
    // PayOS yêu cầu format cụ thể cho signature
    final dataToSign = <String, dynamic>{};

    // Chỉ lấy các field cần thiết cho signature theo thứ tự
    if (data.containsKey('amount')) dataToSign['amount'] = data['amount'];
    if (data.containsKey('cancelUrl'))
      dataToSign['cancelUrl'] = data['cancelUrl'];
    if (data.containsKey('description'))
      dataToSign['description'] = data['description'];
    if (data.containsKey('orderCode'))
      dataToSign['orderCode'] = data['orderCode'];
    if (data.containsKey('returnUrl'))
      dataToSign['returnUrl'] = data['returnUrl'];

    // Sắp xếp theo thứ tự alphabet
    final sortedKeys = dataToSign.keys.toList()..sort();
    final queryParams = <String>[];

    for (final key in sortedKeys) {
      final value = dataToSign[key];
      if (value != null) {
        queryParams.add('$key=$value');
      }
    }

    final queryString = queryParams.join('&');
    print('Signature Query String: $queryString');

    // Tạo HMAC SHA256
    final key = utf8.encode(_checksumKey);
    final bytes = utf8.encode(queryString);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    final signature = digest.toString();
    print('Generated Signature: $signature');

    return signature;
  }

  /// Generate order code ngẫu nhiên
  static int generateOrderCode() {
    final random = Random();
    return 100000 + random.nextInt(900000); // Tạo số từ 100000-999999
  }
}
