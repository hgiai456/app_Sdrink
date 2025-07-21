import 'dart:convert';
import 'package:app_selldrinks/services/port.dart';
import 'package:http/http.dart' as http;
import '../models/store.dart';
import 'package:app_selldrinks/services/port.dart';

class StoreService {
<<<<<<< HEAD
  static const String apiUrl = 'http://10.0.2.2:3003/api/stores';
=======
  static const String apiUrl = '${Port.baseUrl}/stores';
>>>>>>> f06df51d2dea33a30df7823e3efe698b1488235c

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
