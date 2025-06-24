import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:vanphongpham/model/entities/sanPham.dart';

class SanPhamService {
  static const String baseUrl = 'https://localhost:7212';

  Future<List<SanPham>> fetchSanPhams() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sanPham/danhSach'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)['data'];
        return data.map((json) => SanPham.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi API: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}
