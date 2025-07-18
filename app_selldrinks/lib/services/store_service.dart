import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import 'package:app_selldrinks/services/port.dart';

class StoreService {
  Future<List<Store>> fetchStores() async {
    final response = await http.get(Uri.parse('${Port.baseUrl}/stores'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List storesJson = data['data'];
      return storesJson.map((json) => Store.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stores');
    }
  }
}
