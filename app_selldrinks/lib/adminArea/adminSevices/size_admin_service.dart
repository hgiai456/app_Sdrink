import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/adminArea/adminModels/size_admin.dart';
import 'package:app_selldrinks/services/port.dart';

class SizeAdminService {
  static Future<Map<String, dynamic>> fetchSizes(String token, int page) async {
    final response = await http.get(
      Uri.parse('${Port.baseUrl}/sizes?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'sizes':
            (data['data'] as List)
                .map((json) => SizeAdmin.fromJson(json))
                .toList(),
        'currentPage': data['currentPage'] ?? 1,
        'totalPage': data['totalPage'] ?? 1,
        'totalSizes': data['totalSizes'] ?? 0,
      };
    } else {
      throw Exception('Không lấy được danh sách size');
    }
  }

  static Future<bool> addSize(SizeAdmin size, String token) async {
    final response = await http.post(
      Uri.parse('${Port.baseUrl}/sizes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(size.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Thêm size thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> updateSize(SizeAdmin size, String token) async {
    if (size.id == null) return false;
    final response = await http.put(
      Uri.parse('${Port.baseUrl}/sizes/${size.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(size.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Cập nhật size thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> deleteSize(int id, String token) async {
    final response = await http.delete(
      Uri.parse('${Port.baseUrl}/sizes/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
