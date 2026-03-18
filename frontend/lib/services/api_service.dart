import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api';
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ─── Categories ───

  Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/categories/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is List) return data;
      if (data is Map && data.containsKey('results')) return data['results'];
      return [];
    }
    throw Exception('فشل تحميل الأقسام: ${response.statusCode}');
  }

  // ─── Products ───

  Future<Map<String, dynamic>> getProducts({
    int? category,
    String? search,
    String? stockStatus,
    String? nextUrl,
  }) async {
    Uri uri;
    if (nextUrl != null) {
      uri = Uri.parse(nextUrl);
    } else {
      final params = <String, String>{};
      if (category != null) params['category'] = category.toString();
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (stockStatus != null && stockStatus.isNotEmpty) {
        params['stock_status'] = stockStatus;
      }
      uri = Uri.parse('$_baseUrl/products/').replace(queryParameters: params);
    }

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) return data;
      return {'results': data, 'count': (data as List).length, 'next': null, 'previous': null};
    }
    throw Exception('فشل تحميل المنتجات: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getProduct(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/$id/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل تحميل المنتج: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products/'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل إنشاء المنتج: ${response.statusCode} ${utf8.decode(response.bodyBytes)}');
  }

  Future<Map<String, dynamic>> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await http.patch(
      Uri.parse('$_baseUrl/products/$id/'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل تعديل المنتج: ${response.statusCode} ${utf8.decode(response.bodyBytes)}');
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/products/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('فشل حذف المنتج: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> updateStock(int id, String action, int quantity, String note) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/products/$id/update-stock/'),
      headers: _headers,
      body: json.encode({
        'action': action,
        'quantity': quantity,
        'note': note,
      }),
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل تعديل المخزون: ${response.statusCode} ${utf8.decode(response.bodyBytes)}');
  }

  Future<List<dynamic>> getProductStockLogs(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/$id/stock-logs/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is List) return data;
      if (data is Map && data.containsKey('results')) return data['results'];
      return [];
    }
    throw Exception('فشل تحميل سجل المخزون: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getProductsSummary() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/products/summary/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل تحميل الملخص: ${response.statusCode}');
  }

  // ─── Prescriptions ───

  Future<Map<String, dynamic>> getPrescriptions({String? search, String? nextUrl}) async {
    Uri uri;
    if (nextUrl != null) {
      uri = Uri.parse(nextUrl);
    } else {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;
      uri = Uri.parse('$_baseUrl/prescriptions/').replace(queryParameters: params.isNotEmpty ? params : null);
    }

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) return data;
      return {'results': data, 'count': (data as List).length, 'next': null, 'previous': null};
    }
    throw Exception('فشل تحميل الروشتات: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> getPrescription(int id) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/prescriptions/$id/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل تحميل الروشتة: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createPrescription(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/prescriptions/'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل إنشاء الروشتة: ${response.statusCode} ${utf8.decode(response.bodyBytes)}');
  }

  Future<void> deletePrescription(int id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/prescriptions/$id/'),
      headers: _headers,
    );
    if (response.statusCode != 204) {
      throw Exception('فشل حذف الروشتة: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> addPrescriptionItem(int prescriptionId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/prescriptions/$prescriptionId/add-item/'),
      headers: _headers,
      body: json.encode(data),
    );
    if (response.statusCode == 201) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل إضافة العنصر: ${response.statusCode} ${utf8.decode(response.bodyBytes)}');
  }

  Future<Map<String, dynamic>> removePrescriptionItem(int prescriptionId, int itemId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/prescriptions/$prescriptionId/remove-item/$itemId/'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('فشل حذف العنصر: ${response.statusCode}');
  }
}
