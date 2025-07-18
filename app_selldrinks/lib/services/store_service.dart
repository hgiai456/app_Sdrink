import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/store.dart';

class StoreService {
  static const String apiUrl = 'http://10.0.2.2:3000/api/stores';

  Future<List<Store>> fetchStores() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List storesJson = data['data'];
      return storesJson.map((json) => Store.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stores');
    }
  }
}
