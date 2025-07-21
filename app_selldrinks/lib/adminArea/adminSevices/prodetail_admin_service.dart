import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_selldrinks/adminArea/adminModels/prodetail_admin.dart';
import 'package:app_selldrinks/services/port.dart';

class ProdetailAdminService {
  static Future<Map<String, dynamic>> fetchProdetails(
    String token,
    int page,
  ) async {
    final response = await http.get(
      Uri.parse('${Port.baseUrl}/prodetails?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'prodetails':
            (data['data'] as List)
                .map((json) => ProdetailAdmin.fromJson(json))
                .toList(),
        'currentPage': data['currentPage'] ?? 1,
        'totalPage': data['totalPage'] ?? 1,
        'totalProdetails': data['totalProdetails'] ?? 0,
      };
    } else {
      throw Exception('Không lấy được danh sách prodetails');
    }
  }

  static Future<bool> addProdetail(
    ProdetailAdmin prodetail,
    String token,
  ) async {
    final response = await http.post(
      Uri.parse('${Port.baseUrl}/prodetails'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(prodetail.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      print('Thêm prodetail thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> updateProdetail(
    ProdetailAdmin prodetail,
    String token,
  ) async {
    if (prodetail.id == null) return false;
    final response = await http.put(
      Uri.parse('${Port.baseUrl}/prodetails/${prodetail.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(prodetail.toJson()),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print('Cập nhật prodetail thất bại: ${response.body}');
      return false;
    }
  }

  static Future<bool> deleteProdetail(int id, String token) async {
    final response = await http.delete(
      Uri.parse('${Port.baseUrl}/prodetails/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }
}
